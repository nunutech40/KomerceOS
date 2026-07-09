import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StatusUpdate extends StatefulWidget {
  final VoidCallback? onClicked;
  final String availableVersion;

  const StatusUpdate({Key? key, this.onClicked, required this.availableVersion})
      : super(key: key);

  @override
  State<StatusUpdate> createState() => _StatusUpdate();
}

class _StatusUpdate extends State<StatusUpdate> {
  void _onStatusUpdateClicked() {
    if (widget.onClicked != null) {
      widget.onClicked!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onStatusUpdateClicked,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.green,
            width: 1,
          ),
          color: const Color(0xFFD6EEDD), // Set the background color to #BBE2C6
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'assets/images/ic_home_active.svg',
                width: 23,
                height: 20,
                fit: BoxFit.scaleDown,
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Check for Update',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w600,
                      height: 0,
                    ),
                  ),
                  Text(
                    'Komtim v ${widget.availableVersion}',
                    style: const TextStyle(
                      color: Color(0xFF626262),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              SvgPicture.asset(
                'assets/images/ic-arrow-right.svg',
                width: 23,
                height: 20,
                fit: BoxFit.scaleDown,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
