import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/DI/injection.dart';
import 'package:komtim_partner/common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import 'package:komtim_partner/features/superapp/features/kyc/data/datasources/kyc_verification_remote_datasource.dart';
import 'package:komtim_partner/features/superapp/features/kyc/data/repositories/ml_kit_ktp_ocr_repository.dart';
import 'package:komtim_partner/features/superapp/features/kyc/data/services/kyc_server_photo_downloader.dart';
import 'package:komtim_partner/features/superapp/features/kyc/data/services/kyc_upload_image_preparer.dart';
import 'package:komtim_partner/features/superapp/features/kyc/domain/entities/ktp_ocr_data.dart';
import 'package:komtim_partner/features/superapp/features/kyc/domain/entities/kyc_history.dart';
import 'package:komtim_partner/features/superapp/features/kyc/domain/entities/kyc_rt_rw.dart';
import 'package:komtim_partner/features/superapp/features/kyc/domain/repositories/ktp_ocr_repository.dart';
import 'package:komtim_partner/features/superapp/features/kyc/domain/repositories/kyc_verification_repository.dart';
import 'package:komtim_partner/features/superapp/features/kyc/flow/kyc_rejection_prompt.dart';
import 'package:komtim_partner/features/superapp/features/kyc/flow/kyc_resume_flow.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_cancel_bottom_sheet.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_ktp_guide_bottom_sheet.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_photo_capture_section.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_selfie_ktp_guide_bottom_sheet.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_success_bottom_sheet.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_verifying_document_bottom_sheet.dart';

enum _KycStage { ktp, selfieKtp, identity }

/// Orange success illustration used by the KYC result sheets in Figma.
const _successIllustration =
    'assets/images/superapp/topup/ilustration_top_up_success.svg';

/// KTP, selfie with KTP, and partner information after liveness.
class KycSubmissionPage extends StatefulWidget {
  const KycSubmissionPage({
    super.key,
    this.startWithKtpCamera = false,
    this.history,
    this.livenessPath,
  });

  final bool startWithKtpCamera;
  final KycHistory? history;
  final String? livenessPath;

  @override
  State<KycSubmissionPage> createState() => _KycSubmissionPageState();
}

class _KycSubmissionPageState extends State<KycSubmissionPage> {
  final _ktpCameraKey = GlobalKey<KycPhotoCaptureSectionState>();
  final _selfieCameraKey = GlobalKey<KycPhotoCaptureSectionState>();
  final _formKey = GlobalKey<FormState>();
  final _birthDateFieldKey = GlobalKey<FormFieldState<String>>();
  final KtpOcrRepository _ocrRepository = const MlKitKtpOcrRepository();
  final KycVerificationRepository _verificationRepository =
      locator<KycVerificationRepository>();
  final _nik = TextEditingController();
  final _name = TextEditingController();
  final _birthPlace = TextEditingController();
  final _birthDate = TextEditingController();
  final _province = TextEditingController();
  final _city = TextEditingController();
  final _district = TextEditingController();
  final _village = TextEditingController();
  final _address = TextEditingController();
  final _rtRw = TextEditingController();
  final _postalCode = TextEditingController();

  _KycStage _stage = _KycStage.ktp;
  String? _ktpPath;
  String? _selfieKtpPath;
  String? _ktpUploadPath;
  String? _selfieKtpUploadPath;
  String? _ktpUrl;
  String? _selfieKtpUrl;

  /// Local copies of the draft photos from `latest-history`. The signed URLs
  /// expire quickly, so these are used for preview and OCR instead.
  String? _ktpServerPath;
  String? _selfieKtpServerPath;
  String? _livenessServerPath;
  String? _livenessUploadPath;

  /// KTP photo whose OCR result was last written into the form, so a new KTP
  /// photo overwrites the form once but going back and forth does not.
  String? _ocrAppliedPath;
  bool _capturing = false;
  bool _preparingPhoto = false;
  bool _uploading = false;

  /// True while the server already holds the current liveness, KTP and
  /// selfie images, so submit/draft does not upload them again.
  bool _imagesSavedOnServer = false;
  String _submitProgress = 'Mengirim pengajuan...';
  bool _confirmed = false;
  Future<KtpOcrData?>? _ocrFuture;

  @override
  void initState() {
    super.initState();
    final history = widget.history;
    if (history != null && history.isRejected) {
      // Only partner data rejected: the server photos stand, go to the form.
      if (!history.mustRetakeKtp) {
        _stage = _KycStage.identity;
        _imagesSavedOnServer = true;
      }
    } else if (history?.hasCompleteImages == true) {
      _stage = _KycStage.identity;
      _imagesSavedOnServer = true;
    }
    // A photo that must be redone starts empty so the camera opens.
    _ktpUrl = _rejected && history!.mustRetakeKtp ? null : history?.ktpUrl;
    _selfieKtpUrl =
        _rejected && history!.mustRetakeSelfieKtp ? null : history?.selfieKtpUrl;
    final previous = widget.history?.partnerData;
    if (previous != null) {
      _nik.text = previous['nik'] ?? '';
      _name.text = previous['name'] ?? '';
      _birthPlace.text = previous['birth_place'] ?? '';
      _birthDate.text = (previous['birth_date'] ?? '').replaceAll('-', '/');
      _province.text = previous['province'] ?? '';
      _city.text = previous['city'] ?? '';
      _district.text = previous['district'] ?? '';
      _village.text = previous['village'] ?? '';
      _address.text = previous['address'] ?? '';
      final rtRw = previous['rt_rw'] ?? '';
      _rtRw.text = KycRtRw.normalize(rtRw) ?? rtRw;
      _postalCode.text = previous['pos_code'] ?? '';
    }
    unawaited(_restoreServerPhotos());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_stage == _KycStage.identity) return;
      if (_ktpUrl != null) return;
      if (widget.startWithKtpCamera) {
        _ktpCameraKey.currentState?.startCamera();
      } else {
        _showPhotoGuide(selfie: false);
      }
    });
  }

  @override
  void dispose() {
    unawaited(_deleteTemporaryPhoto(_ktpPath));
    unawaited(_deleteTemporaryPhoto(_selfieKtpPath));
    unawaited(_deleteTemporaryPhoto(_ktpUploadPath));
    unawaited(_deleteTemporaryPhoto(_selfieKtpUploadPath));
    unawaited(_deleteTemporaryPhoto(_ktpServerPath));
    unawaited(_deleteTemporaryPhoto(_selfieKtpServerPath));
    unawaited(_deleteTemporaryPhoto(_livenessServerPath));
    unawaited(_deleteTemporaryPhoto(_livenessUploadPath));
    _nik.dispose();
    _name.dispose();
    _birthPlace.dispose();
    _birthDate.dispose();
    _province.dispose();
    _city.dispose();
    _district.dispose();
    _village.dispose();
    _address.dispose();
    _rtRw.dispose();
    _postalCode.dispose();
    super.dispose();
  }

  Future<void> _deleteTemporaryPhoto(String? path) async {
    if (path == null) return;
    try {
      await File(path).delete();
    } on FileSystemException {
      // The camera plugin or OS may already have removed its temporary file.
    }
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<KtpOcrData?> _readKtp(String path) async {
    try {
      return await _ocrRepository.readPhoto(path);
    } catch (_) {
      // Keep the form editable if the camera image cannot be recognized.
      return null;
    }
  }

  /// Resuming a draft: download the server photos while their signed URLs
  /// are still valid, then run OCR on the KTP so the form is filled again
  /// (the draft API stores only the photos, not the form text).
  Future<void> _restoreServerPhotos() async {
    final ktpUrl = _ktpUrl;
    final selfieUrl = _selfieKtpUrl;
    // A kept (not redone) liveness photo is needed again for the upload.
    final livenessUrl = widget.livenessPath == null && _rejected
        ? widget.history?.livenessUrl
        : null;
    if (livenessUrl != null && livenessUrl.isNotEmpty) {
      unawaited(KycServerPhotoDownloader.tryDownload(livenessUrl,
              name: 'liveness')
          .then((file) {
        if (file == null) return;
        if (!mounted) {
          unawaited(_deleteTemporaryPhoto(file.path));
          return;
        }
        _livenessServerPath = file.path;
      }));
    }
    if (ktpUrl == null && selfieUrl == null) return;
    final ktpDownload = ktpUrl == null
        ? Future<File?>.value()
        : KycServerPhotoDownloader.tryDownload(ktpUrl, name: 'ktp');
    final selfieDownload = selfieUrl == null
        ? Future<File?>.value()
        : KycServerPhotoDownloader.tryDownload(selfieUrl, name: 'selfie_ktp');
    final ktpFile = await ktpDownload;
    final selfieFile = await selfieDownload;

    // Drop a download if the page closed or the user retook that photo.
    final keepKtp = mounted && ktpFile != null && _ktpUrl == ktpUrl;
    final keepSelfie =
        mounted && selfieFile != null && _selfieKtpUrl == selfieUrl;
    if (!keepKtp) unawaited(_deleteTemporaryPhoto(ktpFile?.path));
    if (!keepSelfie) unawaited(_deleteTemporaryPhoto(selfieFile?.path));
    if (!mounted) return;
    setState(() {
      if (keepKtp) _ktpServerPath = ktpFile.path;
      if (keepSelfie) _selfieKtpServerPath = selfieFile.path;
    });

    final ktpPath = _ktpServerPath;
    if (ktpPath == null) {
      if (ktpUrl != null && _ktpUrl == ktpUrl) {
        _message(
            'Foto KTP dari draft belum dapat dimuat. Isi data secara manual atau ambil ulang foto KTP.');
      }
      return;
    }
    final ocr = _readKtp(ktpPath);
    _ocrFuture = ocr;
    final data = await ocr;
    debugPrint('[KYC] OCR foto draft: '
        '${data?.hasRecognizedFields == true ? 'terbaca' : 'tidak terbaca'}, '
        'nik=${data?.nik != null}, nama=${data?.name != null}');
    if (!mounted || _ktpServerPath != ktpPath) return;
    if (data != null && data.hasRecognizedFields) {
      setState(() => _fillFromOcr(data));
    }
  }

  bool get _rejected => widget.history?.isRejected == true;

  /// Rejected selfie kept as-is (liveness-only rejection): skip that step.
  bool get _skipSelfie =>
      _rejected && widget.history?.mustRetakeSelfieKtp != true;

  /// Only partner data rejected: the form is the first and only step.
  _KycStage get _firstStage => _rejected && widget.history?.mustRetakeKtp != true
      ? _KycStage.identity
      : _KycStage.ktp;

  /// [overwrite] is used for a newly taken KTP photo: per AC, OCR of a
  /// retaken KTP replaces the form data. Otherwise only empty fields fill.
  void _fillFromOcr(KtpOcrData data, {bool overwrite = false}) {
    void fill(TextEditingController controller, String? value) {
      if (value == null || value.isEmpty) return;
      if (overwrite || controller.text.trim().isEmpty) {
        controller.text = value;
      }
    }

    fill(_nik, data.nik);
    fill(_name, data.name);
    fill(_birthPlace, data.birthPlace);
    fill(_birthDate, data.birthDate);
    if (data.birthDate != null && data.birthDate!.isNotEmpty) {
      _birthDateFieldKey.currentState?.didChange(data.birthDate);
    }
    fill(_province, data.province);
    fill(_city, data.city);
    fill(_district, data.district);
    fill(_village, data.village);
    fill(_address, data.address);
    fill(_rtRw, KycRtRw.normalize(data.rtRw) ?? data.rtRw);
    fill(_postalCode, data.postalCode);
  }

  void _showPhotoGuide({required bool selfie}) {
    void startCamera() {
      Navigator.of(context).pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final key = selfie ? _selfieCameraKey : _ktpCameraKey;
        key.currentState?.startCamera();
      });
    }

    if (selfie) {
      KycSelfieKtpGuideBottomSheet.show<void>(
        context,
        onStartPhoto: startCamera,
        onClose: () {
          Navigator.of(context).pop();
          setState(() => _stage = _KycStage.ktp);
        },
      );
    } else {
      KycKtpGuideBottomSheet.show<void>(
        context,
        onStartPhoto: startCamera,
        onClose: () => Navigator.of(context).pop(),
      );
    }
  }

  Future<String?> _pickBirthDate() async {
    final chosen = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (chosen == null || !mounted) return null;
    final value =
        '${chosen.day.toString().padLeft(2, '0')}/${chosen.month.toString().padLeft(2, '0')}/${chosen.year}';
    _birthDate.text = value;
    return value;
  }

  void _back() {
    if (_uploading || _preparingPhoto || _capturing) return;
    if (_stage != _firstStage) {
      var previous = _KycStage.values[_stage.index - 1];
      if (previous == _KycStage.selfieKtp && _skipSelfie) {
        previous = _KycStage.ktp;
      }
      setState(() => _stage = previous);
      return;
    }
    KycCancelBottomSheet.show<void>(
      context,
      onCancelSubmission: () {
        final navigator = Navigator.of(context);
        navigator.pop(); // Confirmation sheet.
        navigator.pop(); // Photo or form page.
        if (widget.livenessPath != null) navigator.pop(); // Liveness result.
      },
    );
  }

  Future<void> _next() async {
    if (_uploading || _capturing || _preparingPhoto) return;
    switch (_stage) {
      case _KycStage.ktp:
        if (_ktpPath == null && _ktpUrl == null) {
          _ktpCameraKey.currentState?.takePhoto();
          return;
        }
        if (_ktpPath != null && _ktpUploadPath == null) {
          if (!await _prepareCapturedPhoto(selfie: false)) return;
        }
        if (!mounted) return;
        if (_skipSelfie) {
          setState(() => _stage = _KycStage.selfieKtp);
          return _next();
        }
        final history = widget.history;
        // A later rejection popup: "Tutup" stays on the KTP step (AC).
        if (history != null &&
            history.isSelfieKtpRejected &&
            history.rejectedItems.first != KycRejectedItem.selfieKtp) {
          final retry = await KycRejectionPrompt.show(context,
              history: history, item: KycRejectedItem.selfieKtp);
          if (!retry || !mounted) return;
        }
        setState(() => _stage = _KycStage.selfieKtp);
        if (_selfieKtpPath == null && _selfieKtpUrl == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showPhotoGuide(selfie: true);
          });
        }
        return;
      case _KycStage.selfieKtp:
        if (_selfieKtpPath == null && _selfieKtpUrl == null) {
          _selfieCameraKey.currentState?.takePhoto();
          return;
        }
        if (_selfieKtpPath != null && _selfieKtpUploadPath == null) {
          if (!await _prepareCapturedPhoto(selfie: true)) return;
        }
        if (!mounted) return;
        setState(() => _stage = _KycStage.identity);
        KycVerifyingDocumentBottomSheet.show<void>(context);
        // Per AC 6 Nov: entering the OCR step saves the submission as Draft.
        final draftSaved = _autoSaveDraft();
        final data = await _ocrFuture;
        final draftError = await draftSaved;
        if (!mounted || _stage != _KycStage.identity) return;
        Navigator.of(context).pop();
        if (draftError != null) {
          // Show the BE reason so a failed upload (e.g. 400) is not silent.
          _message(
              'Draft belum tersimpan otomatis ($draftError). Tekan "Simpan sebagai Draft" sebelum keluar.');
        }
        if (data != null && data.hasRecognizedFields) {
          final freshKtp = _ktpPath != null && _ocrAppliedPath != _ktpPath;
          _fillFromOcr(data, overwrite: freshKtp);
          if (freshKtp) _ocrAppliedPath = _ktpPath;
          if (data.nik == null || data.name == null) {
            _message(
                'Sebagian data KTP belum terbaca. Periksa hasil atau ambil ulang foto.');
          }
        } else if (_ktpPath != null || widget.history?.hasKtp != true) {
          _message(
              'Data KTP belum terbaca. Isi data secara manual atau ambil ulang foto.');
        }
        return;
      case _KycStage.identity:
        // BE stores RT/RW as 001/002 (7 chars); show the padded value too.
        final rtRw = KycRtRw.normalize(_rtRw.text);
        if (rtRw != null && rtRw != _rtRw.text) _rtRw.text = rtRw;
        if (!_formKey.currentState!.validate() || !_confirmed) {
          if (!_confirmed) _message('Setujui pemeriksaan data identitas.');
          return;
        }
        await _submitVerification();
        return;
    }
  }

  Future<bool> _prepareCapturedPhoto({required bool selfie}) async {
    final sourcePath = selfie ? _selfieKtpPath : _ktpPath;
    if (sourcePath == null) return false;
    setState(() => _preparingPhoto = true);
    try {
      final prepared = await KycUploadImagePreparer.prepare(sourcePath);
      if (!mounted || sourcePath != (selfie ? _selfieKtpPath : _ktpPath)) {
        await prepared.delete();
        return false;
      }
      if (selfie) {
        _selfieKtpUploadPath = prepared.path;
      } else {
        _ktpUploadPath = prepared.path;
      }
      return true;
    } on Exception {
      _message('Foto belum berhasil dikompres. Ambil ulang atau coba lagi.');
      return false;
    } finally {
      if (mounted) setState(() => _preparingPhoto = false);
    }
  }

  Future<void> _uploadDraftImages() async {
    // The server already has the current three images (a resumed complete
    // draft or the automatic draft saved at the OCR step). Submitting must not
    // require temporary files from an old session or upload them twice.
    if (_imagesSavedOnServer) return;
    // The upload API always takes all three files. Photos that were not
    // redone (resumed draft or partial rejection) come from the server copy.
    _ktpUploadPath ??= await _prepareServerCopy(_ktpServerPath);
    _selfieKtpUploadPath ??= await _prepareServerCopy(_selfieKtpServerPath);
    _livenessUploadPath ??= widget.livenessPath == null
        ? await _prepareServerCopy(_livenessServerPath)
        : null;
    final livenessPath = widget.livenessPath ?? _livenessUploadPath;
    final ktpPath = _ktpUploadPath;
    final selfieKtpPath = _selfieKtpUploadPath;
    if (livenessPath == null) {
      throw StateError(
          'Foto verifikasi wajah sebelumnya tidak tersedia dari server. Hubungi CS atau coba lagi nanti.');
    }
    if (ktpPath == null || selfieKtpPath == null) {
      throw StateError(
          'Foto verifikasi belum lengkap. Ambil ulang foto KTP dan selfie.');
    }
    await _verificationRepository.upload(
      livenessPath: livenessPath,
      ktpPath: ktpPath,
      selfieKtpPath: selfieKtpPath,
    );
    _imagesSavedOnServer = true;
    KycResumeFlow.historyChanged.value++;
  }

  Future<String?> _prepareServerCopy(String? path) async {
    if (path == null) return null;
    try {
      return (await KycUploadImagePreparer.prepare(path)).path;
    } on Exception catch (error) {
      debugPrint('[KYC] Foto server gagal disiapkan: $error');
      return null;
    }
  }

  /// Uploads the three photos as a server draft without blocking the flow.
  /// Returns the failure reason, or null when the draft was saved.
  Future<String?> _autoSaveDraft() async {
    try {
      await _uploadDraftImages();
      return null;
    } catch (error) {
      debugPrint('[KYC] Auto draft gagal: $error');
      return _errorMessage(error, fallback: 'gagal mengunggah foto');
    }
  }

  String _errorMessage(Object error, {required String fallback}) {
    if (error is KycApiException) return error.message;
    if (error is StateError) return error.message;
    if (error is DioException) {
      final body = error.response?.data;
      if (body is Map) {
        final meta = body['meta'];
        final message = meta is Map ? meta['message'] : body['message'];
        if (message != null && message.toString().trim().isNotEmpty) {
          return message.toString();
        }
      }
      if (error.response == null) {
        return 'Terjadi kesalahan. Periksa koneksi Anda atau coba lagi.';
      }
    }
    return fallback;
  }

  Future<void> _submitVerification() async {
    final profile = locator<SuperappProfileBloc>().state.displayProfile;
    final email = profile?.email ?? widget.history?.partnerData['email'] ?? '';
    final phone = profile?.noHp ?? widget.history?.partnerData['phone'] ?? '';
    if (email.isEmpty || phone.isEmpty) {
      _message('Email atau nomor HP akun belum tersedia. Muat ulang profil.');
      return;
    }
    setState(() {
      _uploading = true;
      _submitProgress = 'Memeriksa NIK...';
    });
    try {
      await _verificationRepository.checkNik(
          nik: _nik.text.trim(), email: email);
      if (mounted) setState(() => _submitProgress = 'Mengunggah foto...');
      await _uploadDraftImages();
      if (mounted) setState(() => _submitProgress = 'Mengirim pengajuan...');
      await _verificationRepository.submit({
        'nik': _nik.text.trim(),
        'name': _name.text.trim(),
        'email': email,
        'phone': phone,
        'birth_place': _birthPlace.text.trim(),
        'birth_date': _birthDateForApi(_birthDate.text.trim()),
        'province': _province.text.trim(),
        'city': _city.text.trim(),
        'district': _district.text.trim(),
        'village': _village.text.trim(),
        'address': _address.text.trim(),
        'rt_rw': KycRtRw.normalize(_rtRw.text) ?? _rtRw.text.trim(),
        'pos_code': _postalCode.text.trim(),
      });
      if (!mounted) return;
      locator<SuperappProfileBloc>().add(const FetchSuperappProfileEvent());
      KycResumeFlow.historyChanged.value++;
      _showSubmissionResult();
    } catch (error) {
      debugPrint('[KYC] Pengajuan gagal: $error');
      _message(_errorMessage(error,
          fallback: 'Pengajuan verifikasi gagal. Coba lagi.'));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  String _birthDateForApi(String value) {
    final match = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(value);
    if (match == null) return value;
    return '${match.group(1)}-${match.group(2)}-${match.group(3)}';
  }

  void _showSubmissionResult() {
    KycSuccessBottomSheet.show<void>(
      context,
      title: 'Pengajuan Verifikasi KTP\nBerhasil',
      subtitle: 'Silakan tunggu konfirmasi lebih lanjut\nselama 1×24 jam.',
      imagePath: _successIllustration,
      buttonText: 'Selesai',
      onButtonPressed: () {
        final navigator = Navigator.of(context);
        navigator.pop(); // Success sheet.
        navigator.pop(); // Form page.
        if (widget.livenessPath != null) navigator.pop(); // Liveness result.
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (_stage) {
      _KycStage.ktp => 'Ambil Foto KTP',
      _KycStage.identity => 'Informasi Data Partner',
      _KycStage.selfieKtp => 'Ambil Foto Selfie & KTP',
    };
    final isPhotoStage =
        _stage == _KycStage.ktp || _stage == _KycStage.selfieKtp;
    final canContinue = switch (_stage) {
      _KycStage.ktp => true,
      _KycStage.identity => _confirmed,
      _KycStage.selfieKtp => true,
    };
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: AppColors.alwaysWhite,
        appBar: isPhotoStage
            ? DsAppBar(
                title: title,
                onBackPressed: _back,
                backgroundColor: AppColors.alwaysWhite,
              )
            : null,
        body: isPhotoStage ? _photoPage() : _identityPage(canContinue),
      ),
    );
  }

  Widget _photoPage() {
    final selfie = _stage == _KycStage.selfieKtp;
    final path = selfie
        ? _selfieKtpPath ?? _selfieKtpServerPath
        : _ktpPath ?? _ktpServerPath;
    final url = selfie ? _selfieKtpUrl : _ktpUrl;
    final hasPhoto = path != null || url != null;
    final cameraKey = selfie ? _selfieCameraKey : _ktpCameraKey;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: !hasPhoto
                    ? const Color(0xFFFFE8D9)
                    : const Color(0xFFF1FAF5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                Icon(
                    !hasPhoto ? Icons.info_outline : Icons.check_circle_outline,
                    size: 18,
                    color:
                        !hasPhoto ? AppColors.black : const Color(0xFF249A67)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hasPhoto
                        ? selfie
                            ? 'Foto Selfie & KTP berhasil diambil. Lanjutkan proses verifikasi identitas.'
                            : 'Foto KTP berhasil diambil. Lanjutkan proses verifikasi identitas.'
                        : selfie
                            ? 'Pastikan KTP dan wajah terlihat di dalam bingkai dan pencahayaan yang cukup terang.'
                            : 'Pastikan KTP terlihat di dalam bingkai dan pencahayaan yang cukup terang.',
                    style: AppTypography.bodySmRegular.copyWith(
                        color: !hasPhoto
                            ? AppColors.grey700
                            : const Color(0xFF249A67)),
                  ),
                ),
              ]),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Align(
                alignment: Alignment.topCenter,
                child: KycPhotoCaptureSection(
                  key: cameraKey,
                  selfie: selfie,
                  capturedPath: path,
                  capturedUrl: url,
                  onCaptured: (value) {
                    setState(() {
                      _imagesSavedOnServer = false;
                      if (selfie) {
                        unawaited(_deleteTemporaryPhoto(_selfieKtpUploadPath));
                        _selfieKtpUploadPath = null;
                        _selfieKtpPath = value;
                        _selfieKtpUrl = null;
                        unawaited(_deleteTemporaryPhoto(_selfieKtpServerPath));
                        _selfieKtpServerPath = null;
                      } else {
                        unawaited(_deleteTemporaryPhoto(_ktpUploadPath));
                        _ktpUploadPath = null;
                        _ktpPath = value;
                        _ktpUrl = null;
                        unawaited(_deleteTemporaryPhoto(_ktpServerPath));
                        _ktpServerPath = null;
                      }
                    });
                    if (!selfie) {
                      _ocrFuture = _readKtp(value);
                      _ocrFuture!.then((data) {
                        if (!mounted ||
                            _stage != _KycStage.ktp ||
                            _ktpPath != value) {
                          return;
                        }
                        if (data?.nik == null || data?.name == null) {
                          _message(
                            'Teks utama KTP belum terbaca. Dekatkan kartu, tambah cahaya, lalu ambil ulang foto.',
                          );
                        }
                      });
                    }
                  },
                  onBusyChanged: (value) => setState(() => _capturing = value),
                  onError: _message,
                ),
              ),
            ),
          ),
          if (hasPhoto)
            TextButton(
              onPressed: () {
                if (_uploading || _preparingPhoto || _capturing) return;
                unawaited(_deleteTemporaryPhoto(path));
                setState(() {
                  _imagesSavedOnServer = false;
                  if (selfie) {
                    unawaited(_deleteTemporaryPhoto(_selfieKtpUploadPath));
                    _selfieKtpUploadPath = null;
                    _selfieKtpPath = null;
                    _selfieKtpUrl = null;
                    _selfieKtpServerPath = null;
                  } else {
                    unawaited(_deleteTemporaryPhoto(_ktpUploadPath));
                    _ktpUploadPath = null;
                    _ktpPath = null;
                    _ktpUrl = null;
                    _ktpServerPath = null;
                    _ocrFuture = null;
                  }
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) cameraKey.currentState?.startCamera();
                });
              },
              child: const Text('Ambil Ulang',
                  style: TextStyle(color: AppColors.primaryBase)),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
            child: DsButton(
              text: !hasPhoto ? 'Ambil Gambar' : 'Selanjutnya',
              loadingText: 'Menyiapkan foto...',
              borderRadius: 8,
              state: _preparingPhoto
                  ? DsButtonState.loading
                  : _capturing || _uploading
                      ? DsButtonState.disabled
                      : DsButtonState.enabled,
              onPressed: _next,
            ),
          ),
        ],
      ),
    );
  }

  Widget _identityPage(bool canContinue) => SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 72,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(children: [
                  InkWell(
                    onTap: _back,
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.grey200,
                          width: 1,
                        ),
                      ),
                      child: const Icon(Icons.chevron_left_rounded,
                          size: 28, color: AppColors.grey700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Informasi Data Partner',
                      style: AppTypography.headingSm
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ]),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: _identityForm(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: TextButton(
                onPressed: _uploading ? null : _saveDraft,
                child: _uploading
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Memproses...'),
                        ],
                      )
                    : const Text('Simpan sebagai Draft',
                        style: TextStyle(color: AppColors.errorBase)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: DsButton(
                text: 'Ajukan Verifikasi',
                loadingText: _submitProgress,
                height: 44,
                borderRadius: 10,
                disabledBackgroundColor: const Color(0xFFFFAE8C),
                state: _uploading
                    ? DsButtonState.loading
                    : canContinue
                        ? DsButtonState.enabled
                        : DsButtonState.disabled,
                onPressed: _next,
              ),
            ),
          ],
        ),
      );

  Future<void> _saveDraft() async {
    if (_uploading) return;
    setState(() {
      _uploading = true;
      _submitProgress = 'Menyimpan draft...';
    });
    try {
      await _uploadDraftImages();
      if (!mounted) return;
      KycSuccessBottomSheet.show<void>(
        context,
        title: 'Data Disimpan sebagai\nDraft',
        subtitle:
            'Data KTP kamu akan disimpan sebagai draft dan bisa dilanjutkan nanti.',
        imagePath: _successIllustration,
        buttonText: 'Mengerti',
        onButtonPressed: () {
          final navigator = Navigator.of(context);
          navigator.pop();
          navigator.pop();
          if (widget.livenessPath != null) {
            navigator.pop();
          }
        },
      );
    } catch (error) {
      debugPrint('[KYC] Simpan draft gagal: $error');
      _message(_errorMessage(error,
          fallback: 'Draft belum berhasil disimpan. Coba lagi.'));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Widget _identityForm() => Form(
        key: _formKey,
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8D9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              const SizedBox(
                width: 40,
                height: 40,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.alwaysWhite,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.info_outline,
                        color: AppColors.black, size: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Informasi Data Partner',
                        style: AppTypography.bodyMdSemiBold),
                    Text(
                      'Pastikan dokumen yang di-upload sama persis dengan informasi data partner yang akan mengajukan verifikasi identitas.',
                      style: AppTypography.bodySmRegular
                          .copyWith(color: AppColors.textDark),
                    ),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          DsFormCard(children: [
            _field('NIK', _nik,
                maxLength: 16,
                keyboardType: TextInputType.number,
                formatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) =>
                    v?.length == 16 ? null : 'NIK harus 16 digit'),
            _field('Nama', _name),
            _field('Tempat Lahir', _birthPlace),
            FormField<String>(
              key: _birthDateFieldKey,
              initialValue: _birthDate.text,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Wajib diisi' : null,
              builder: (field) => DsPickerField(
                label: 'Tanggal Lahir',
                value: field.value?.isEmpty ?? true ? null : field.value,
                hint: 'Pilih Tanggal Lahir',
                requiredField: true,
                textStyle: AppTypography.bodyMdRegular,
                trailingIcon: Icons.calendar_month_outlined,
                labelFlex: 1,
                valueFlex: 2,
                verticalPadding: 0,
                contentVerticalPadding: 11,
                errorText: field.errorText,
                onTap: () async {
                  final value = await _pickBirthDate();
                  if (value != null) field.didChange(value);
                },
              ),
            ),
            _field('Provinsi', _province),
            _field('Kab/Kota', _city),
            _field('Kecamatan', _district),
            _field('Kel/Desa', _village),
            _field('Alamat', _address, maxLines: 3),
            _field('RT/RW', _rtRw,
                maxLength: 7,
                // Digits plus '/', e.g. 001/002 as printed on the KTP.
                keyboardType: TextInputType.datetime,
                formatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                ],
                validator: (v) => KycRtRw.normalize(v) != null
                    ? null
                    : 'Format RT/RW: 001/002'),
            _field('Kode Pos', _postalCode,
                keyboardType: TextInputType.number,
                formatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 5,
                validator: (v) =>
                    v?.length == 5 ? null : 'Kode pos harus 5 digit'),
          ]),
          const SizedBox(height: 24),
          _agreementSection(),
        ]),
      );

  Widget _agreementSection() => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: 'Setujui kebijakan verifikasi identitas KTP',
            checked: _confirmed,
            child: InkWell(
              onTap: () => setState(() => _confirmed = !_confirmed),
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.only(top: 3),
                decoration: BoxDecoration(
                  color: _confirmed
                      ? AppColors.primaryBase
                      : AppColors.alwaysWhite,
                  border: Border.all(
                    color:
                        _confirmed ? AppColors.primaryBase : AppColors.grey300,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _confirmed
                    ? const Icon(Icons.check,
                        size: 14, color: AppColors.alwaysWhite)
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => setState(() => _confirmed = !_confirmed),
                  child: const Text(
                    'Saya menyetujui kebijakan verifikasi identitas KTP.',
                    style: AppTypography.bodyMdRegular,
                  ),
                ),
                const SizedBox(height: 2),
                InkWell(
                  onTap: () => _message(
                      'Detail kebijakan belum tersedia pada pratinjau UI.'),
                  child: Text(
                    'Lihat detail',
                    style: AppTypography.bodyMdRegular.copyWith(
                      color: const Color(0xFF008DFF),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _field(
    String label,
    TextEditingController controller, {
    int? maxLength,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    FormFieldValidator<String>? validator,
  }) =>
      DsFormRow(
        label: label,
        requiredField: true,
        labelStyle: AppTypography.bodyMdRegular,
        labelFlex: 1,
        valueFlex: 2,
        verticalPadding: 0,
        contentVerticalPadding: 11,
        minHeight: maxLines > 1 ? 119 : null,
        child: DsTextField(
          controller: controller,
          hintText: 'Masukkan $label',
          textStyle: AppTypography.bodyMdRegular,
          contentVerticalPadding: 11,
          maxLength: maxLength,
          lines: maxLines,
          keyboardType: keyboardType ??
              (maxLines > 1 ? TextInputType.multiline : TextInputType.text),
          inputFormatters: formatters,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validator ??
              (v) => v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
        ),
      );
}
