import 'package:flutter/material.dart';

class AppTextStyle {
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static TextStyle title(
    BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) =>
      TextStyle(
        fontFamily: "Metropolis",
        color: color ?? (_isDark(context) ? Colors.white : Colors.black),
        fontWeight: fontWeight ?? FontWeight.w700,
        fontSize: fontSize ?? 26,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle body(
    BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) =>
      TextStyle(
        fontFamily: "Metropolis",
        color:
            color ?? (_isDark(context) ? Colors.grey[400] : Colors.grey[800]), 
        fontWeight: fontWeight ?? FontWeight.w500,
        fontSize: fontSize ?? 16,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle bodyBold(
    BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) =>
      TextStyle(
        fontFamily: "Metropolis",
        color:
            color ?? (_isDark(context) ? Colors.grey[200] : Colors.grey[900]),
        fontWeight: fontWeight ?? FontWeight.w600,
        fontSize: fontSize ?? 16,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle subtitle(
    BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) =>
      TextStyle(
        fontFamily: "Metropolis",
        color:
            color ?? (_isDark(context) ? Colors.grey[500] : Colors.grey[600]),
        fontWeight: fontWeight ?? FontWeight.w400,
        fontSize: fontSize ?? 14,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle accent(
    BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) =>
      TextStyle(
        fontFamily: "Metropolis",
        color: color ??
            (_isDark(context)
                ? const Color(0xff7385FF)
                : const Color(0xff2A26DA)), 
        fontWeight: fontWeight ?? FontWeight.w500,
        fontSize: fontSize ?? 16,
        letterSpacing: letterSpacing,
        height: height,
      );
}

