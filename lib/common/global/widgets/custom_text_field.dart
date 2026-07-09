import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komtim_partner/common/styles.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool onlyNumbers;
  final String textValue;
  final bool isEnable;
  final TextEditingController? controller;
  final VoidCallback? onTap;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.hint,
    this.onChanged,
    this.errorText,
    this.onlyNumbers = false,
    this.textValue = '',
    this.isEnable = true,
    this.controller,
    this.onTap,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    });
    // Use the controller from the parent widget if provided, otherwise create a new one.
    _textEditingController =
        widget.controller ?? TextEditingController(text: widget.textValue);
  }

  // Dispose of the controller only if it was created within this widget.
  @override
  void dispose() {
    if (widget.controller == null) {
      _textEditingController.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor =
        widget.errorText != null && widget.errorText!.isNotEmpty
            ? errorColor
            : (_hasFocus ? primaryColor : borderGray);

    List<TextInputFormatter>? inputFormatters;
    if (widget.onlyNumbers) {
      inputFormatters = <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ];
    }

    return TextField(
      enabled: widget.isEnable,
      controller: _textEditingController,
      focusNode: _focusNode,
      onTap: widget.onTap,
      onChanged: (value) {
        if (widget.onlyNumbers) {
          final newValue = value.replaceAll(RegExp('[^0-9]'), '');
          if (newValue != value) {
            widget.onChanged?.call(newValue);
          }
        } else {
          widget.onChanged?.call(value);
        }
      },
      inputFormatters: inputFormatters,
      keyboardType:
          widget.onlyNumbers ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(12.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: borderColor,
            width: 0.7,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 2.0,
          ),
        ),
        labelText: widget.label,
        labelStyle: TextStyle(
          color: _hasFocus ? primaryColor : Colors.black,
          fontSize: 16,
        ),
        hintText: widget.hint,
        hintStyle: TextStyle(
          color: borderColor,
          fontSize: 16,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        errorText: widget.errorText,
      ),
    );
  }
}
