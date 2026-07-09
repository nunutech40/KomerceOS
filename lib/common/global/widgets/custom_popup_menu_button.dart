import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/widgets/tab_button.dart';

class CustomPopupMenuButton extends StatelessWidget {
  final List<String> items;
  final Function(String) onSelected;
  final bool isActive;
  final VoidCallback onPressed;
  final String displayText;

  const CustomPopupMenuButton({super.key, 
    required this.items,
    required this.onSelected,
    required this.isActive,
    required this.onPressed,
    required this.displayText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: PopupMenuButton<String>(
          onSelected: onSelected,
          offset: const Offset(0, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          elevation: 4.0,
          itemBuilder: (BuildContext context) => items
              .map((item) => PopupMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          child: TabButton(
            isActive: isActive,
            onPressed: onPressed,
            text: displayText,
          ),
        ),
      ),
    );
  }
}
