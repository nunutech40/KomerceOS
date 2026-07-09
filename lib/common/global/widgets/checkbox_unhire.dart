import 'package:flutter/material.dart';

class CheckboxUnhire extends StatefulWidget {
  final bool isChecked;
  final void Function(bool?)? onChanged;

  const CheckboxUnhire({Key? key, this.isChecked = false, this.onChanged})
      : super(key: key);

  @override
  _CheckboxDeft createState() => _CheckboxDeft();
}

class _CheckboxDeft extends State<CheckboxUnhire> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.onChanged != null) {
          widget.onChanged!(!widget.isChecked);
        }
      },
      child: Container(
        width: 18.0,
        height: 18.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(
            color: widget.isChecked ? Colors.green : Colors.grey,
          ),
          color: widget.isChecked ? Colors.green : Colors.transparent,
        ),
        child: widget.isChecked
            ? const Icon(
                Icons.check,
                size: 16.0,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}
