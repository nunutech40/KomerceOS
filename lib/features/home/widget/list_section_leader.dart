import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/styles.dart';
import '../../../core/domain/entities/talents_model.dart';
import 'custom_button_contact.dart';

class ListSectionLeader extends StatelessWidget {
  const ListSectionLeader({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<TalentLeaderModel> items;

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> whatsapp(TalentLeaderModel item) async {
    final contact = item.phoneNumber;

    if (contact == null) {
      return;
    }

    String processedContact;
    if (contact.startsWith('0')) {
      processedContact = '62${contact.substring(1)}';
    } else if (contact.startsWith('+62')) {
      processedContact = contact.replaceFirst('+', '');
    } else {
      processedContact = contact;
    }

    final androidUrl = "https://wa.me/$processedContact";
    final iosUrl = "https://wa.me/$contact";

    try {
      if (Platform.isIOS) {
        await _launchUrl(Uri.parse(iosUrl));
      } else {
        await _launchUrl(Uri.parse(androidUrl));
      }
    } catch (e) {
      // Handle the exception here. Maybe show a snackbar or logger.
      // print("Failed to open WhatsApp: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const double verticalPadding = 28.0;
    const double itemHeight = 24.0 + verticalPadding;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Text(title, style: AppTypography.semiBold14),
        ),
        SizedBox(
          height: items.length * itemHeight,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemExtent: itemHeight, // Set the height of each item explicitly
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        items[index].staffName ?? '',
                        style: AppTypography.regular12,
                      ),
                      CustomButtonContact(onPressed: () async {
                        await whatsapp(items[index]);
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
