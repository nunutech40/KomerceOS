import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/custom_filtering_text_input.dart';

import '../../styles.dart';

class CustomPasswordField extends StatefulWidget {
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;
  final String? errorText; // Add this

  const CustomPasswordField({
    Key? key,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.errorText, // And this
  }) : super(key: key);

  @override
  _CustomPasswordFieldState createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  final FocusNode _focusNode = FocusNode();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor =
        widget.errorText != null && widget.errorText!.isNotEmpty
            ? Colors.red
            : (_focusNode.hasFocus
                ? primaryColor
                : Colors.grey); // Adjust the border color

    return TextField(
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      obscureText: _obscureText,
      inputFormatters: [
        //allow
        CustomTextInputFormatter.denyTextInput(),
      ],
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(12.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: borderColor, // Set the border color
            width: 2.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: borderColor,
            width: 2.0,
          ),
        ),
        labelText: widget.label,
        labelStyle: TextStyle(
          color: _focusNode.hasFocus ? primaryColor : Colors.black,
          fontSize: 16,
        ),
        hintText: widget.hint,
        hintStyle: TextStyle(
          color: borderColor, // Set the same color as the border
          fontSize: 16,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        errorText: widget.errorText, // Add this
        suffixIcon: IconButton(
          icon: _obscureText
              ? SvgPicture.asset('assets/images/ic_eye-slash.svg')
              : SvgPicture.asset('assets/images/ic_eye.svg'),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
    );
  }
}
