import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/DI/injection.dart';
import 'package:komtim_partner/common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import 'package:komtim_partner/features/superapp/features/kyc/data/repositories/ml_kit_ktp_ocr_repository.dart';
import 'package:komtim_partner/features/superapp/features/kyc/data/services/kyc_upload_image_preparer.dart';
import 'package:komtim_partner/features/superapp/features/kyc/domain/entities/ktp_ocr_data.dart';
import 'package:komtim_partner/features/superapp/features/kyc/domain/entities/kyc_history.dart';
import 'package:komtim_partner/features/superapp/features/kyc/domain/repositories/ktp_ocr_repository.dart';
import 'package:komtim_partner/features/superapp/features/kyc/domain/repositories/kyc_verification_repository.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_cancel_bottom_sheet.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_ktp_guide_bottom_sheet.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_photo_capture_section.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_selfie_ktp_guide_bottom_sheet.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_success_bottom_sheet.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_verifying_document_bottom_sheet.dart';

enum _KycStage { ktp, selfieKtp, identity }

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
  bool _capturing = false;
  bool _preparingPhoto = false;
  bool _uploading = false;
  String _submitProgress = 'Mengirim pengajuan...';
  bool _confirmed = false;
  Future<KtpOcrData?>? _ocrFuture;

  @override
  void initState() {
    super.initState();
    if (widget.history?.hasCompleteImages == true) {
      _stage = _KycStage.identity;
    }
    _ktpUrl = widget.history?.ktpUrl;
    _selfieKtpUrl = widget.history?.selfieKtpUrl;
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
      _rtRw.text = previous['rt_rw'] ?? '';
      _postalCode.text = previous['pos_code'] ?? '';
    }
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

  void _fillFromOcr(KtpOcrData data) {
    void fill(TextEditingController controller, String? value) {
      if (controller.text.trim().isEmpty && value != null && value.isNotEmpty) {
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
    fill(_rtRw, data.rtRw);
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
    if (_stage != _KycStage.ktp) {
      setState(() => _stage = _KycStage.values[_stage.index - 1]);
      return;
    }
    KycCancelBottomSheet.show<void>(
      context,
      onCancelSubmission: () {
        final navigator = Navigator.of(context);
        navigator.pop(); // Confirmation sheet.
        navigator.pop(); // Photo or form page.
        if (widget.history == null) navigator.pop(); // Liveness result page.
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
        final data = await _ocrFuture;
        if (!mounted || _stage != _KycStage.identity) return;
        Navigator.of(context).pop();
        if (data != null && data.hasRecognizedFields) {
          _fillFromOcr(data);
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
    // A complete saved draft already has the three images on the server.
    // Submitting its form must not require temporary files from an old session.
    if (widget.history?.hasCompleteImages == true &&
        widget.livenessPath == null &&
        _ktpPath == null &&
        _selfieKtpPath == null) {
      return;
    }
    final livenessPath = widget.livenessPath;
    final ktpPath = _ktpUploadPath;
    final selfieKtpPath = _selfieKtpUploadPath;
    if (livenessPath == null || ktpPath == null || selfieKtpPath == null) {
      throw StateError('Foto liveness, KTP, dan selfie harus lengkap.');
    }
    await _verificationRepository.upload(
      livenessPath: livenessPath,
      ktpPath: ktpPath,
      selfieKtpPath: selfieKtpPath,
    );
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
        'rt_rw': _rtRw.text.trim(),
        'pos_code': _postalCode.text.trim(),
      });
      if (!mounted) return;
      locator<SuperappProfileBloc>().add(const FetchSuperappProfileEvent());
      _showSubmissionResult();
    } catch (_) {
      _message('Pengajuan verifikasi gagal. Periksa NIK dan coba lagi.');
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
      title: 'Pengajuan Verifikasi KTP Berhasil',
      subtitle: 'Silakan tunggu konfirmasi lebih lanjut selama 1x24 jam.',
      imagePath: 'assets/images/ilustrated-success.svg',
      buttonText: 'Selesai',
      onButtonPressed: () {
        final navigator = Navigator.of(context);
        navigator.pop(); // Success sheet.
        navigator.pop(); // Form page.
        if (widget.history == null) navigator.pop(); // Liveness result page.
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
    final path = selfie ? _selfieKtpPath : _ktpPath;
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
                      if (selfie) {
                        unawaited(_deleteTemporaryPhoto(_selfieKtpUploadPath));
                        _selfieKtpUploadPath = null;
                        _selfieKtpPath = value;
                        _selfieKtpUrl = null;
                      } else {
                        unawaited(_deleteTemporaryPhoto(_ktpUploadPath));
                        _ktpUploadPath = null;
                        _ktpPath = value;
                        _ktpUrl = null;
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
                  if (selfie) {
                    unawaited(_deleteTemporaryPhoto(_selfieKtpUploadPath));
                    _selfieKtpUploadPath = null;
                    _selfieKtpPath = null;
                    _selfieKtpUrl = null;
                  } else {
                    unawaited(_deleteTemporaryPhoto(_ktpUploadPath));
                    _ktpUploadPath = null;
                    _ktpPath = null;
                    _ktpUrl = null;
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
        title: 'Draft Verifikasi Berhasil Disimpan',
        subtitle: 'Berkas verifikasi berhasil disimpan sebagai draft.',
        imagePath: 'assets/images/ilustrated-success.svg',
        buttonText: 'Selesai',
        onButtonPressed: () {
          final navigator = Navigator.of(context);
          navigator.pop();
          navigator.pop();
          if (widget.history == null && widget.livenessPath != null) {
            navigator.pop();
          }
        },
      );
    } catch (_) {
      _message('Draft belum berhasil disimpan. Pastikan semua foto tersedia.');
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
            _field('RT/RW', _rtRw),
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
