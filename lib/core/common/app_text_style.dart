import 'package:flutter/material.dart';
import 'package:delivery_apps/core/common/color_extension.dart';

class AppTextStyle {
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
        color: color ?? AppColor.textTitle(context),
        fontWeight: fontWeight ?? FontWeight.w600,
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
        color: color ?? AppColor.textBody(context),
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
        color: color ?? AppColor.textBody(context),
        fontWeight: fontWeight ?? FontWeight.bold,
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
        color: color ?? AppColor.textSecondary(context),
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
        color: color ?? AppColor.textAccent(context),
        fontWeight: fontWeight ?? FontWeight.w500,
        fontSize: fontSize ?? 16,
        letterSpacing: letterSpacing,
        height: height,
      );
}

