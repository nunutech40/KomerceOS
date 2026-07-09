import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/styles.dart';

class CustomRadioListTile extends StatelessWidget {
  String? images;
  String? value;
  String? title;
  String? text;
  String? groupValue;
  Function(String?)? onChanged;
  CustomRadioListTile(
      {super.key,
      required this.images,
      required this.value,
      required this.title,
      required this.text,
      required this.groupValue,
      required this.onChanged});

  get radioButtonActiveBank => null;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      child: Column(
        children: [
          RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            activeColor: orangeColor,
            dense: true,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            title: value == "Bank"
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            images ?? "",
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            title ?? "",
                            style: AppTypography.regular16,
                          ),
                        ],
                      ),
                      Text(
                        text ?? "",
                        style: AppTypography.interRegular12,
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 55,
                        height: 20,
                        child: SvgPicture.asset(
                          images ?? "",
                          fit: BoxFit.fill,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        title ?? "",
                        style: AppTypography.regular16,
                      ),
                    ],
                  ),
            value: value ?? "",
            groupValue: groupValue,
            onChanged: onChanged,
            subtitle: value != "Bank"
                ? Text(
                    text ?? "",
                    style: AppTypography.interRegular12,
                  )
                : null,
            controlAffinity: ListTileControlAffinity
                .platform, // optional, places the radio button on the trailing side
          ),
          const SizedBox(height: 0),
          const SizedBox(width: double.infinity, child: Divider())
        ],
      ),
    );
  }
}
