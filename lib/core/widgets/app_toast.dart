import 'package:another_flushbar/flushbar.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:flutter/material.dart';

enum _ToastType { success, error, warning, info }

class AppToast {
  static void success(BuildContext context, String message, {String? title}) {
    _show(context, _ToastType.success, message, title: title);
  }

  static void error(BuildContext context, String message, {String? title}) {
    _show(context, _ToastType.error, message, title: title);
  }

  static void warning(BuildContext context, String message, {String? title}) {
    _show(context, _ToastType.warning, message, title: title);
  }

  static void info(BuildContext context, String message, {String? title}) {
    _show(context, _ToastType.info, message, title: title);
  }

  static void _show(
    BuildContext context,
    _ToastType type,
    String message, {
    String? title,
  }) {
    final (icon, accent, defaultTitle) = switch (type) {
      _ToastType.success => (Icons.check_circle, Colors.green, 'Success'),
      _ToastType.error => (Icons.error_outline, Colors.red, 'Something went wrong'),
      _ToastType.warning => (Icons.warning_amber_rounded, Colors.orange, 'Heads up'),
      _ToastType.info => (Icons.info_outline, AppColor.primary(context), 'Notice'),
    };

    final textColor = AppColor.textTitle(context);

    Flushbar(
      titleText: Text(
        title ?? defaultTitle,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: textColor,
          fontSize: 15,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          color: textColor.withValues(alpha: 0.8),
          fontSize: 13,
        ),
      ),
      icon: Icon(icon, color: accent, size: 26),
      leftBarIndicatorColor: accent,
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: AppColor.container(context),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          offset: const Offset(0, 4),
          blurRadius: 10,
        ),
      ],
    ).show(context);
  }
}
