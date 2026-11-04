import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_cancel_bottom_sheet.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_ktp_guide_bottom_sheet.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_photo_capture_section.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_selfie_ktp_guide_bottom_sheet.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_success_bottom_sheet.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_verifying_document_bottom_sheet.dart';

enum _KycStage { ktp, selfieKtp, identity }

/// UI preview after paid verification and liveness. No KYC submission API exists
/// yet, so the final screen explicitly states that nothing was sent.
class KycSubmissionPage extends StatefulWidget {
  const KycSubmissionPage({
    super.key,
    this.startWithKtpCamera = false,
  });

  final bool startWithKtpCamera;

  @override
  State<KycSubmissionPage> createState() => _KycSubmissionPageState();
}

class _KycSubmissionPageState extends State<KycSubmissionPage> {
  final _ktpCameraKey = GlobalKey<KycPhotoCaptureSectionState>();
  final _selfieCameraKey = GlobalKey<KycPhotoCaptureSectionState>();
  final _formKey = GlobalKey<FormState>();
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
  bool _capturing = false;
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
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
        navigator.pop(); // Liveness result page.
      },
    );
  }

  Future<void> _next() async {
    switch (_stage) {
      case _KycStage.ktp:
        if (_ktpPath == null) {
          _ktpCameraKey.currentState?.takePhoto();
          return;
        }
        setState(() => _stage = _KycStage.selfieKtp);
        if (_selfieKtpPath == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showPhotoGuide(selfie: true);
          });
        }
        return;
      case _KycStage.selfieKtp:
        if (_selfieKtpPath == null) {
          _selfieCameraKey.currentState?.takePhoto();
          return;
        }
        setState(() => _stage = _KycStage.identity);
        // UI-only preview: the OCR endpoint has not been connected yet.
        KycVerifyingDocumentBottomSheet.show<void>(context);
        await Future<void>.delayed(const Duration(milliseconds: 800));
        if (mounted) Navigator.of(context).pop();
        return;
      case _KycStage.identity:
        if (!_formKey.currentState!.validate() || !_confirmed) {
          if (!_confirmed) _message('Setujui pemeriksaan data identitas.');
          return;
        }
        _showPreviewResult();
        return;
    }
  }

  void _showPreviewResult() {
    KycSuccessBottomSheet.show<void>(
      context,
      title: 'Pratinjau Pengajuan Verifikasi KTP',
      subtitle: 'Alur UI selesai. Foto dan data belum dikirim ke server; '
          'status verifikasi akun belum berubah.',
      imagePath: 'assets/images/ilustrated-success.svg',
      buttonText: 'Selesai',
      onButtonPressed: () {
        final navigator = Navigator.of(context);
        navigator.pop(); // Preview result sheet.
        navigator.pop(); // Form page.
        navigator.pop(); // Liveness result page.
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
        appBar: DsAppBar(
          title: title,
          onBackPressed: _back,
          backgroundColor: AppColors.alwaysWhite,
        ),
        body: isPhotoStage ? _photoPage() : _identityPage(canContinue),
      ),
    );
  }

  Widget _photoPage() {
    final selfie = _stage == _KycStage.selfieKtp;
    final path = selfie ? _selfieKtpPath : _ktpPath;
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
                color: path == null
                    ? const Color(0xFFFFE8D9)
                    : const Color(0xFFF1FAF5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                Icon(
                    path == null
                        ? Icons.info_outline
                        : Icons.check_circle_outline,
                    size: 18,
                    color: path == null
                        ? AppColors.black
                        : const Color(0xFF249A67)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    path != null
                        ? selfie
                            ? 'Foto Selfie & KTP berhasil diambil. Lanjutkan proses verifikasi identitas.'
                            : 'Foto KTP berhasil diambil. Lanjutkan proses verifikasi identitas.'
                        : selfie
                            ? 'Pastikan KTP dan wajah terlihat di dalam bingkai dan pencahayaan yang cukup terang.'
                            : 'Pastikan KTP terlihat di dalam bingkai dan pencahayaan yang cukup terang.',
                    style: AppTypography.bodySmRegular.copyWith(
                        color: path == null
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
                  onCaptured: (value) => setState(() {
                    if (selfie) {
                      _selfieKtpPath = value;
                    } else {
                      _ktpPath = value;
                    }
                  }),
                  onBusyChanged: (value) => setState(() => _capturing = value),
                  onError: _message,
                ),
              ),
            ),
          ),
          if (path != null)
            TextButton(
              onPressed: () {
                unawaited(_deleteTemporaryPhoto(path));
                setState(() {
                  if (selfie) {
                    _selfieKtpPath = null;
                  } else {
                    _ktpPath = null;
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
              text: path == null ? 'Ambil Gambar' : 'Selanjutnya',
              borderRadius: 8,
              state:
                  _capturing ? DsButtonState.disabled : DsButtonState.enabled,
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: _identityForm(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: TextButton(
                onPressed: _showDraftPreview,
                child: const Text('Simpan sebagai Draft',
                    style: TextStyle(color: AppColors.primaryBase)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: DsButton(
                text: 'Ajukan Verifikasi',
                state: canContinue
                    ? DsButtonState.enabled
                    : DsButtonState.disabled,
                onPressed: _next,
              ),
            ),
          ],
        ),
      );

  void _showDraftPreview() {
    KycSuccessBottomSheet.show<void>(
      context,
      title: 'Pratinjau Draft',
      subtitle: 'Draft belum disimpan ke server. Data pada halaman ini '
          'tetap tersedia selama halaman masih terbuka.',
      imagePath: 'assets/images/ilustrated-success.svg',
      buttonText: 'Mengerti',
    );
  }

  Widget _identityForm() => Form(
        key: _formKey,
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8D9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(children: [
              SizedBox(
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
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Informasi Data Partner',
                        style: AppTypography.bodyMdSemiBold),
                    Text(
                      'Pastikan dokumen yang di-upload sama persis dengan informasi data partner yang akan mengajukan verifikasi identitas.',
                      style: AppTypography.bodySmRegular,
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
        child: DsTextField(
          controller: controller,
          hintText: 'Masukkan $label',
          textStyle: AppTypography.bodyMdRegular,
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
