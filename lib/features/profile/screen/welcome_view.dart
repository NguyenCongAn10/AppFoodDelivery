import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/features/profile/screen/login_view.dart';
import 'package:delivery_apps/features/profile/screen/signup_view.dart';
import 'package:flutter/material.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
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
                  color: AppColor.primary(context),
                  borderRadius: BorderRadius.circular(30)),
              child: Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  Container(
                      padding: const EdgeInsets.only(left: 15),
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Welcome",
                        style: AppTextStyle.title(context, color: AppColor.textTitle(context), fontSize: 30),
                      )),
                  Container(
                      padding: const EdgeInsets.only(
                        left: 15,
                        top: 20,
                        right: 40,
                      ),
                      alignment: Alignment.topLeft,
                      child: Text(
                          "Welcome back! Hello how are you today",
                          style: AppTextStyle.body(context, color: AppColor.textTitle(context)))),
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
                              child: Text(
                                "Sign In",
                                style: AppTextStyle.bodyBold(context, color: AppColor.textTitle(context)),
                              )),
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
                              child: Text("Sign Up", style: AppTextStyle.bodyBold(context, color: Colors.white)))
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
