import 'package:delivery_apps/view/login/welcom_view.dart';
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
    await Future.delayed(Duration(seconds: 3));
    WelcomPage();
  }
  void WelcomPage(){
    Navigator.push(context, MaterialPageRoute(builder: (context)
    =>
    const WelcomView()
    ));
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
