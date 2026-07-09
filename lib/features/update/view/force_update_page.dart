import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:komtim_partner/common/global/widgets/custom_button.dart';
import 'package:komtim_partner/features/update/widget/update_complete.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdatePage extends StatefulWidget {
  const ForceUpdatePage({Key? key}) : super(key: key);

  @override
  State<ForceUpdatePage> createState() => _ForceUpdatePageState();
}

class _ForceUpdatePageState extends State<ForceUpdatePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32.0, 160.0, 32.0, 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'assets/images/ic_illustration_waiting.svg',
                width: 195,
                height: 237,
              ),
              const SizedBox(height: 60),
              const Center(
                child: Text(
                  'Aplikasi perlu diperbarui!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Dapatkan pengalaman terbaik dengan versi terbaru! Nikmati fitur baru dan perbaikan bug.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 52),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Perbarui Sekarang',
                    onPressed: () async {
                      if (Platform.isIOS) {
                        final Uri uri = Uri.parse(
                            "https://apps.apple.com/id/app/komtim/id6473518650");
                        launchUrl(uri);
                      } else {
                        InAppUpdate.checkForUpdate().then((updateInfo) {
                          if (updateInfo.updateAvailability ==
                              UpdateAvailability.updateAvailable) {
                            if (updateInfo.immediateUpdateAllowed) {
                              InAppUpdate.performImmediateUpdate()
                                  .then((appUpdateResult) {
                                if (appUpdateResult ==
                                    AppUpdateResult.success) {
                                  if (!context.mounted) return;

                                  bottomSheetUpdateSuccess(context);
                                }
                              });
                            }
                          }
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
