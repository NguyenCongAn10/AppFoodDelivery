import 'package:flutter/material.dart';

class AppColor {
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }


  static const Color primaryLight = Color(0xff4CAF7D);
  static const Color primaryDark = Color(0xff2F7D5B);
  static Color primary(BuildContext context) => isDarkMode(context) ? primaryDark : primaryLight;

  
  static const Color inputFillLight = Color(0xffEBF4F1);
  static const Color inputFillDark = Color(0xff1E1E1E);
  static Color inputFill(BuildContext context) => isDarkMode(context) ? inputFillDark : inputFillLight;

  static const Color secondaryBackgroundLight = Color(0xffF4F6F5);
  static const Color secondaryBackgroundDark = Color(0xff2C2C2C);
  static Color secondaryBackground(BuildContext context) => isDarkMode(context) ? secondaryBackgroundDark : secondaryBackgroundLight;

  
  static const Color textTitleLight = Color(0xff05140A);
  static const Color textTitleDark = Color(0xffffffff);
  static Color textTitle(BuildContext context) => isDarkMode(context) ? textTitleDark : textTitleLight;

  static const Color textBodyLight = Color(0xff000000);
  static const Color textBodyDark = Color(0xffffffff);
  static Color textBody(BuildContext context) => isDarkMode(context) ? textBodyDark : textBodyLight;

  static const Color textSecondaryLight = Color(0xff7C7D7E);
  static const Color textSecondaryDark = Color(0xffB6B7B7);
  static Color textSecondary(BuildContext context) => isDarkMode(context) ? textSecondaryDark : textSecondaryLight;

  static const Color textAccentLight = Color(0xff0D6EFD);
  static const Color textAccentDark = Color(0xff1E6BFF);
  static Color textAccent(BuildContext context) => isDarkMode(context) ? textAccentDark : textAccentLight;

  static const Color containerLight = Color(0xffffffff);
  static const Color containerDark = Color(0xff18181A); 
  static Color container(BuildContext context) => isDarkMode(context) ? containerDark : containerLight;

  // Container Level 2
  static const Color containerHighLight = Color(0xffF7F7F7);
  static const Color containerHighDark = Color(0xff222224);
  static Color containerHigh(BuildContext context) =>
      isDarkMode(context) ? containerHighDark : containerHighLight;

  // Container Level 3 (Lightest container in Dark mode)
  static const Color containerHighestLight = Color(0xffEFEFEF);
  static const Color containerHighestDark = Color(0xff2C2C2E);
  static Color containerHighest(BuildContext context) =>
      isDarkMode(context) ? containerHighestDark : containerHighestLight;
}