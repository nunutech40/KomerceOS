import 'package:flutter/material.dart';
import 'package:komtim_partner/core/domain/entities/talents_model.dart';

class TalentItem extends StatefulWidget {
  final TalentsDataModel dataInvoice;
  final bool isSelectAllChecked;
  final ValueChanged<bool> onCheckboxToggled;

  const TalentItem({
    Key? key,
    required this.dataInvoice,
    required this.isSelectAllChecked,
    required this.onCheckboxToggled,
  }) : super(key: key);

  @override
  _TalentItemState createState() => _TalentItemState();
}

class _TalentItemState extends State<TalentItem> {
  bool isChecked = false;

  @override
  void didUpdateWidget(covariant TalentItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelectAllChecked != oldWidget.isSelectAllChecked) {
      setState(() {
        isChecked = widget.isSelectAllChecked;
      });
    }
  }

  void _toggleCheckbox() {
    setState(() {
      isChecked = !isChecked;
      widget.onCheckboxToggled(isChecked);
    });
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 12.0,
                      ),
                      child: Text(
                        widget.dataInvoice.talentName ?? "",
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _toggleCheckbox,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color:
                            isChecked ? Colors.green : const Color(0xFFB3B3B3),
                        width: 1.5,
                      ),
                      color: isChecked ? Colors.green : Colors.transparent,
                    ),
                    child: isChecked
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
