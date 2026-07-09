import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/widgets/checkbox_unhire.dart';
import '../../../core/domain/entities/talents_model.dart';
import 'package:shimmer/shimmer.dart';

class TalentsUnhireItem extends StatelessWidget {
  final bool isLoading;
  final TalentsDataModel? talents;
  final bool isChecked;
  final bool isCheckAll;
  final void Function(bool?)? onCheckboxChanged;

  const TalentsUnhireItem({
    Key? key,
    required this.isLoading,
    this.talents,
    this.isChecked = false,
    this.isCheckAll = false,
    this.onCheckboxChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: _buildShimmeringUI(),
      );
    } else {
      return _buildActualUI();
    }
  }

  Widget _buildShimmeringUI() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 100,
            height: 20, 
            color: Colors.white,
          ),
          const CheckboxUnhire(
            isChecked: false,
            onChanged: null,
          ),
        ],
      ),
    );
  }

  Widget _buildActualUI() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  talents?.talentName ?? '',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          CheckboxUnhire(
            isChecked: isChecked,
            onChanged: onCheckboxChanged,
          ),
        ],
      ),
    );
  }
}
