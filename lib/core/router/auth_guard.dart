import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthGuard {
  static String? redirect(BuildContext context, GoRouterState state) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;
    final path = state.uri.toString();

    final publicRoutes = ['/startup', '/welcome', '/login', '/register'];
    
    if (!isLoggedIn && !publicRoutes.contains(path)) {
      return '/welcome';
    }

    if (isLoggedIn && ['/login', '/register', '/welcome'].contains(path)) {
      return '/';
    }

    return null;
  }
}
