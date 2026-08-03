import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFFF95E16);
const Color secondaryColor = Color(0xFFD84E0F);
const Color greenLight = Color(0xFFDFF3FF);
const Color lighPrimaryColor = Color(0xFFFFEBE1);
const Color tagBackgorundPrimaryColor = Color(0xFFFFD5C4);
const Color backgroundPrimaryColor = Color(0xFFFFF2EC);

const Color lightGray = Color(0xFFF8F8F8);
const Color darkGray = Color(0xFF626262);
const Color onlyGray = Color(0xFF828282);
const Color f4Gray = Color(0xFFF4F4F4);
const Color e2Gray = Color(0xFFE2E2E2);
const Color inActiveGray = Color(0xFFC2C2C2);
const Color borderGray = Color(0xFFCCCCCC);

const Color errorColor = Color(0xFFE31A1A);

const Color errorBackground = Color(0xFFFCE8E8);
const Color orangeColor = Color(0xFFF95031);
const Color creameColor = Color(0xFFFEF3E6);

const Color lightWarningColor = Color(0xFFFFF2E2);
const Color warningColor = Color(0xFFFBA63C);
const Color warningDarkColor = Color(0xFFAF6A13);
const Color backgroundContainerColor = Color(0xFFF2F2F2);
const Color blueMain = Color(0xFF08A0F7);
const Color blueLight = Color(0xFFDFF3FF);
const Color blackColors = Color(0xFF000000);
const Color blackColors33 = Color(0xff3333333);
const Color blue42 = Color(0xFF4285F4);
const Color purple = Color(0xFF6D3CB8);
const Color lightPurple = Color(0xFFE2D8F1);

class AppTypography {
  // default familly fonts is jakartans plus
  static const TextStyle bold16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle textColorGreen = TextStyle(
      fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF34A853));

  static const TextStyle semiBold14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600, // FontWeight.w600 corresponds to semiBold
  );

  static const TextStyle semiBold16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600, // FontWeight.w600 corresponds to semiBold
  );

  static const TextStyle semiBold20 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600, // FontWeight.w600 corresponds to semiBold
  );

  static const TextStyle semiBold12 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle medium14White = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500, // FontWeight.w500 corresponds to medium
      color: Colors.white);

  static const TextStyle medium12 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500, // FontWeight.w500 corresponds to medium
  );

  static const TextStyle medium14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500, // FontWeight.w500 corresponds to medium
  );

  static const TextStyle medium14Grey = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500, // FontWeight.w500 corresponds to medium
      color: inActiveGray);

  static const TextStyle regular14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle regular14PrimaryBold =
      TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor);

  static const TextStyle regular8 = TextStyle(
    fontSize: 8,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle regular14inActive = TextStyle(
      fontSize: 14, fontWeight: FontWeight.normal, color: inActiveGray);

  static const TextStyle regular14Active = TextStyle(
      fontSize: 14, fontWeight: FontWeight.normal, color: primaryColor);

  static const TextStyle regular16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle regular16FF33 =
      TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: darkGray);

  static const TextStyle regular14black = TextStyle(
      fontSize: 14, fontWeight: FontWeight.normal, color: blackColors33);

  static const TextStyle regular12 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );
  static const TextStyle regular10 = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle regular20 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle regular12Grey = TextStyle(
      fontSize: 12, fontWeight: FontWeight.normal, color: inActiveGray);

  static const TextStyle regular12FF6262 =
      TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: darkGray);

  static const TextStyle regular12WarningDark = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: warningDarkColor,
  );

  static const TextStyle regular12White = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );

  static const TextStyle regular12Primary = TextStyle(
      fontSize: 12, fontWeight: FontWeight.normal, color: primaryColor);

  static const TextStyle regular12BlueMain =
      TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: blueMain);

  // inter familly
  static const TextStyle interRegular12 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    fontFamily: 'Inter',
  );

  static const TextStyle interRegular14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    fontFamily: 'Inter',
  );

  static const TextStyle interSemiBold14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
  );

  static const TextStyle interSemiBold16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
  );

  static const TextStyle interSemiBold18 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
  );

  static const TextStyle regular600 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: blackColors,
  );
  static const TextStyle regularBold = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: blackColors,
  );
  static const TextStyle small14White = TextStyle(
      fontSize: 8,
      fontWeight: FontWeight.w400, // FontWeight.w500 corresponds to medium
      color: Colors.white);

  static const TextStyle small14Grey = TextStyle(
      fontSize: 8,
      fontWeight: FontWeight.w400, // FontWeight.w500 corresponds to medium
      color: inActiveGray);
}

class AppTypographyCustom {
  final double fontSize;

  AppTypographyCustom({required this.fontSize});

  TextStyle get semiBoldCustom => TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
      );
}
