import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';
import '../app_radius.dart';
import '../app_spacing.dart';
import '../app_typography.dart';

// -----------------------------------------------------------------------------
// DS OTP FIELD — Atomic widget
//
// A 6-digit OTP input displayed as two groups of 3 boxes separated by a dash.
// Layout: [_][_][_] — [_][_][_]
//
// Features:
//   - Auto-advance focus to the next field on input
//   - Auto-retreat focus to the previous field on delete
//   - Grouped visual style (3-3 with dash separator)
//   - Error state support
//   - Paste support (auto-distributes 6-digit paste across fields)
//   - Callback with complete OTP string
//   - Fully controlled component via TextEditingController (optional)
// -----------------------------------------------------------------------------

class DsOtpField extends StatefulWidget {
  const DsOtpField({
    super.key,
    this.controller, // Penambahan controller opsional dari parent
    this.onCompleted,
    this.onChanged,
    this.errorText,
    this.isEnabled = true,
    this.autoFocus = false,
    this.length = 6,
  }) : assert(length == 6, 'DsOtpField currently only supports length = 6');

  /// Optional controller to manage the complete OTP value from the parent.
  final TextEditingController? controller;

  /// Called when all [length] digits have been entered.
  final ValueChanged<String>? onCompleted;

  /// Called every time the OTP value changes (may be incomplete).
  final ValueChanged<String>? onChanged;

  /// Displays an error message below the field.
  final String? errorText;

  /// Whether the fields accept input.
  final bool isEnabled;

  /// Whether the first field should be auto-focused.
  final bool autoFocus;

  /// Number of OTP digits. Must be 6.
  final int length;

  @override
  State<DsOtpField> createState() => _DsOtpFieldState();
}

class _DsOtpFieldState extends State<DsOtpField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late final List<FocusNode> _keyboardNodes;

  bool get _hasError => widget.errorText != null && widget.errorText!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    _keyboardNodes = List.generate(widget.length, (_) => FocusNode());

    // Dengarkan perubahan dari parent controller jika ada
    widget.controller?.addListener(_syncFromParent);
    
    // Inisialisasi value awal jika controller parent sudah memiliki teks saat halaman di-load
    if (widget.controller != null && widget.controller!.text.isNotEmpty) {
       _syncFromParent();
    }
  }

  @override
  void dispose() {
    // Bersihkan listener saat komponen dihancurkan
    widget.controller?.removeListener(_syncFromParent);
    
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    for (final k in _keyboardNodes) {
      k.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String get _currentOtp => _controllers.map((c) => c.text).join();

  /// Menyinkronkan 6 kotak internal jika controller dari luar diubah (misal di-clear)
  void _syncFromParent() {
    final parentText = widget.controller?.text ?? '';
    if (parentText != _currentOtp) {
      for (int i = 0; i < widget.length; i++) {
        final char = i < parentText.length ? parentText[i] : '';
        if (_controllers[i].text != char) {
          _controllers[i].text = char;
        }
      }
    }
  }

  void _notifyChanged() {
    final otp = _currentOtp;
    
    // Update parent controller jika berbeda (hindari infinite loop)
    if (widget.controller != null && widget.controller!.text != otp) {
      widget.controller!.text = otp;
    }

    widget.onChanged?.call(otp);
    if (otp.length == widget.length) {
      widget.onCompleted?.call(otp);
    }
  }

  void _handleChanged(int index, String value) {
    // Handle paste: if user pastes a multi-character string
    if (value.length > 1) {
      _handlePaste(value);
      return;
    }

    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    _notifyChanged();
  }

  void _handlePaste(String pastedText) {
    // Only keep digits
    final digits = pastedText.replaceAll(RegExp(r'[^0-9]'), ''); 
    for (int i = 0; i < widget.length; i++) {
      if (i < digits.length) {
        _controllers[i].text = digits[i];
      }
    }
    // Focus the last filled field or the next empty one
    final focusIndex =
        digits.length >= widget.length ? widget.length - 1 : digits.length;
    _focusNodes[focusIndex.clamp(0, widget.length - 1)].requestFocus();
    _notifyChanged();
  }

  void _handleKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _controllers[index - 1].clear();
        _focusNodes[index - 1].requestFocus();
        _notifyChanged();
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- First group (indices 0, 1, 2) ---
            _buildGroup(0, 3),

            // --- Dash separator ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: SizedBox(
                width: 16,
                child: Divider(
                  color: AppColors.grey400,
                  thickness: 2,
                ),
              ),
            ),

            // --- Second group (indices 3, 4, 5) ---
            _buildGroup(3, 6),
          ],
        ),

        // --- Error text ---
        if (_hasError) ...[
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Text(
              widget.errorText!,
              style: AppTypography.bodySmRegular.copyWith(
                color: AppColors.errorBase,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Builds a group of OTP digit boxes wrapped in a single rounded container.
  Widget _buildGroup(int startIndex, int endIndex) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.grey300,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = startIndex; i < endIndex; i++) ...[
            if (i != startIndex)
              Container(
                width: 1,
                height: 48,
                color: AppColors.grey200,
              ),
            _buildDigitBox(i),
          ],
        ],
      ),
    );
  }

  Widget _buildDigitBox(int index) {
    return SizedBox(
      width: 48,
      height: 48,
      child: KeyboardListener(
        focusNode: _keyboardNodes[index], // managed focus node to prevent memory leak
        onKeyEvent: (event) => _handleKeyEvent(index, event),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          enabled: widget.isEnabled,
          autofocus: widget.autoFocus && index == 0,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          obscureText: true,
          obscuringCharacter: '*',
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _OtpInputFormatter(maxLength: widget.length),
          ],
          style: AppTypography.headingMd.copyWith(
            color: widget.isEnabled ? AppColors.grey800 : AppColors.grey400,
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) => _handleChanged(index, value),
        ),
      ),
    );
  }
}

class _OtpInputFormatter extends TextInputFormatter {
  final int maxLength;

  _OtpInputFormatter({required this.maxLength});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. Jika teks kosong, biarkan (user menekan backspace)
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // 2. Jika user mem-paste banyak karakter (selisih lebih dari 1 karakter)
    // Biarkan nilainya lewat utuh, agar _handlePaste di widget bisa memprosesnya
    if (newValue.text.length - oldValue.text.length > 1) {
      return newValue;
    }

    // 3. Jika user mengetik SATU angka tambahan di kotak yang sudah terisi (Type-over UX)
    // Contoh: oldValue = "1", newValue = "12". Kita ambil "2" saja.
    if (newValue.text.length > 1 && oldValue.text.isNotEmpty) {
      final newChar = newValue.text.characters.last;
      return TextEditingValue(
        text: newChar,
        selection: const TextSelection.collapsed(offset: 1),
      );
    }

    // Default: biarkan lewat
    return newValue;
  }
}