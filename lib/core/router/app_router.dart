import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_apps/features/home/screen/startup_view.dart';
import 'package:delivery_apps/features/profile/screen/welcome_view.dart';
import 'package:delivery_apps/features/profile/screen/login_view.dart';
import 'package:delivery_apps/features/profile/screen/signup_view.dart';
import 'package:delivery_apps/features/home/screen/main_screen.dart';
import 'package:delivery_apps/features/home/screen/home_screen.dart';
import 'package:delivery_apps/features/cart/screen/cart_screen.dart';
import 'package:delivery_apps/features/favorites/screen/favourite_screen.dart';
import 'package:delivery_apps/features/order/screen/order_screen.dart';
import 'package:delivery_apps/features/profile/screen/profile_screen.dart';
import 'package:delivery_apps/features/profile/screen/change_password_screen.dart';
import 'package:delivery_apps/features/home/screen/search_screen.dart';
import 'package:delivery_apps/features/home/screen/product_detail_page.dart';
import 'package:delivery_apps/core/models/product.dart';
import 'package:delivery_apps/core/router/auth_guard.dart';

class AppRouter {
  static GoRouter createRouter(Listenable? refreshListenable) {
    return GoRouter(
      initialLocation: '/startup',
      refreshListenable: refreshListenable,
      redirect: AuthGuard.redirect,
      routes: [
        // Startup & Auth Routes
        GoRoute(
          path: '/startup',
          builder: (context, state) => const StartupView(),
        ),
        GoRoute(
          path: '/welcome',
          builder: (context, state) => const WelcomeView(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginView(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const SignUpView(),
        ),

        // Main App Routes
        GoRoute(
          path: '/',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final initialIndex = extra?['initialIndex'] as int? ?? 0;
            return MainScreen(initialIndex: initialIndex);
          },
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),

        // Cart
        GoRoute(
          path: '/cart',
          builder: (context, state) => const CartScreen(),
        ),

        // Favorites
        GoRoute(
          path: '/favorites',
          builder: (context, state) => const FavouriteScreen(),
        ),

        // Orders
        GoRoute(
          path: '/orders',
          builder: (context, state) => const OrderScreen(),
        ),

        // Profile
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/change-password',
          builder: (context, state) => const ChangePasswordScreen(),
        ),

        // Search
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),

        // Product Detail
        GoRoute(
          path: '/products/:product_id',
          builder: (context, state) {
            final productIdStr = state.pathParameters['product_id'];
            final extra = state.extra as Map<String, dynamic>?;
            
            if (extra == null || extra['product'] == null) {
              return const Scaffold(
                body: Center(child: Text('Product not found')),
              );
            }
            
            final product = extra['product'] as Product;
            final onToggleFavorite = extra['onToggleFavorite'] as Function(Product)?;
            
            return ProductDetailPage(
              product: product,
              // onToggleFavorite: onToggleFavorite,
            );
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Page not found: ${state.uri}'),
        ),
      ),
    );
  }
}
