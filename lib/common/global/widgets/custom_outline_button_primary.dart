import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/styles.dart';

class CustomeOutlineButtonPrimary extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final String? icon;
  const CustomeOutlineButtonPrimary(
      {super.key, required this.text, required this.onPressed, this.icon});

  @override
  State<CustomeOutlineButtonPrimary> createState() =>
      _CustomeOutlineButtonPrimaryState();
}

class _CustomeOutlineButtonPrimaryState
    extends State<CustomeOutlineButtonPrimary> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.013,
        ),
        decoration: BoxDecoration(
            border: Border.all(color: primaryColor),
            borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.022,
                width: MediaQuery.of(context).size.width * 0.073,
                child: SvgPicture.asset(widget.icon ?? ""),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.008,
              ),
              Text(
                widget.text,
                style: AppTypography.regular14PrimaryBold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
