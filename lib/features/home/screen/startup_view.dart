import 'package:delivery_apps/core/router/app_router.dart';
import 'package:delivery_apps/features/home/screen/main_screen.dart';
import 'package:delivery_apps/features/profile/screen/welcome_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StartupView extends StatefulWidget {
  const StartupView({super.key});

  @override
  State<StartupView> createState() => _StartupViewState();
}

class _StartupViewState extends State<StartupView> {
  @override
  void initState() {
    super.initState();
    goWelcomPage();
  }

  void goWelcomPage() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      if (FirebaseAuth.instance.currentUser != null) {
        AppRouter.routeAfterLogin(context);
      } else {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const WelcomeView(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            "assets/image/splash_bg.png",
            height: media.height,
            width: media.width,
            fit: BoxFit.cover,
          ),
          Transform.scale(
            scale: 1.8, // Bypasses the Stack constraints to force it larger
            child: Image.asset(
              "assets/image/logo3.png",
              fit: BoxFit.contain,
              width: media.width * 0.8, // Base width
            ),
          ),
          
        ],
      ),
    );
  }
}
