import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/core/data/models/detail_shopping_response.dart';

class ItemTalents extends StatelessWidget {
  final TalentRequest? talent;

  const ItemTalents({super.key, this.talent});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(
              child: Text(
                talent?.talentName ?? '',
                style: const TextStyle(
                  color: AppColors.black0A0A,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: SizedBox(
              child: Text(
                talent?.talentSkill ?? '',
                textAlign: TextAlign.start,
                style: const TextStyle(
                  color: AppColors.black0A0A,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
