import 'dart:developer';

import 'package:delivery_apps/core/models/user_model.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/features/restaurant/screen/restaurant_main_screen.dart';
import 'package:delivery_apps/features/shipper/screen/shipper_main_screen.dart';
import 'package:delivery_apps/features/user/home/screen/main_screen.dart';
import 'package:delivery_apps/features/user/profile/screen/login_view.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static Future<void> routeAfterLogin(BuildContext context) async {
    try {
      final user = await BackendService().getMe();

      if (!context.mounted) return;

      if (user.role == UserRole.SHIPPER) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ShipperMainScreen(user: user)),
        );
      } else if (user.role == UserRole.RESTAURANT) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => RestaurantMainScreen(user: user)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    } catch (e) {
      log('Failed to route after login: $e');
      if (context.mounted) {
        // Fallback or error
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginView()),
        );
      }
    }
  }
}
