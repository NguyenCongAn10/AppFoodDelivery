import 'package:delivery_apps/common/color_extention.dart';
import 'package:delivery_apps/common_widget/big_text.dart';
import 'package:delivery_apps/common_widget/normal_text.dart';
import 'package:delivery_apps/common_widget/normal_text_bold.dart';
import 'package:delivery_apps/view/login/login_view.dart';
import 'package:delivery_apps/view/login/signup_view.dart';
import 'package:flutter/material.dart';

class WelcomView extends StatefulWidget {
  const WelcomView({super.key});

  @override
  State<WelcomView> createState() => _WelcomViewState();
}

class _WelcomViewState extends State<WelcomView> {
  Route _route_Signin() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const LoginView(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/image/splash_bg.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: media.height * 0.2,
            left: media.width * 0.2,
            right: media.width * 0.2,
            child: Container(
              alignment: Alignment.center,
              height: media.height * 0.2,
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10)),
              child: const Text("LOGO"),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              height: media.height * 0.4,
              decoration: BoxDecoration(
                  color: TColor.main, borderRadius: BorderRadius.circular(30)),
              child: Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  Container(
                      padding: const EdgeInsets.only(left: 15),
                      alignment: Alignment.topLeft,
                      child: BigText(
                        color: TColor.primary,
                        txt: "Welcome",
                        size: 30,
                      )),
                  Container(
                      padding: const EdgeInsets.only(
                        left: 15,
                        top: 20,
                        right: 40,
                      ),
                      alignment: Alignment.topLeft,
                      child: NormalText(
                          color: TColor.primary,
                          txt: "Welcome back! Hello how are you today")),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 50, vertical: 15)),
                              onPressed: () {
                                Navigator.of(context).push(_route_Signin());
                              },
                              child: NormalTextBold(
                                  color: TColor.primary, txt: "Sign In")),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 50, vertical: 15)),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignUpView()));
                              },
                              child: NormalTextBold(
                                  color: TColor.primaryText, txt: "Sign Up"))
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
