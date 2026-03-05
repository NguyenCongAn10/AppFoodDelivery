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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeView()),
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
          Container(
            alignment: Alignment.center,
            width: media.width * 0.6,
            height: media.height * 0.3,
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10)),
            child: const Text(
              "LOGO",
              style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
