import 'package:flutter/material.dart';
import 'package:komtim_partner/common/styles.dart';

class CheckboxDeft extends StatefulWidget {
  final bool isChecked;
  final void Function(bool?)? onChanged;

  const CheckboxDeft({Key? key, this.isChecked = false, this.onChanged})
      : super(key: key);

  @override
  _CheckboxDeft createState() => _CheckboxDeft();
}

class _CheckboxDeft extends State<CheckboxDeft> {
  @override
  Widget build(BuildContext context) {
    Color getColor(Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return secondaryColor;
      }
      return Colors.white;
    }

    return Checkbox(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      side: const BorderSide(color: e2Gray, width: 1.5),
      checkColor: Colors.white,
      fillColor: WidgetStateProperty.resolveWith(getColor),
      value: widget.isChecked,
      onChanged: widget.onChanged,
    );
  }
}
