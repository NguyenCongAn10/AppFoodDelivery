import 'package:delivery_apps/common/color_extention.dart';
import 'package:delivery_apps/common_widget/big_text.dart';
import 'package:delivery_apps/common_widget/normal_text.dart';
import 'package:delivery_apps/common_widget/normal_text_bold.dart';
import 'package:delivery_apps/common_widget/round_button.dart';
import 'package:delivery_apps/common_widget/round_textfield.dart';
import 'package:delivery_apps/view/home/home_screen.dart';
import 'package:delivery_apps/view/login/signup_view.dart';
import 'package:delivery_apps/view/login/welcom_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../common_widget/round_button_icon.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  String email = "", password = "";

  final _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  UserLogin() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } on FirebaseAuthException catch (e) {
      debugPrint("Login error: ${e.code}");
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: NormalText(
                color: TColor.primary, txt: "No User Found For This Email")));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: NormalText(
                color: TColor.primary,
                txt: "Wrong Password Provided By User")));
      }
    }
  }

  Route _route_Welcome() {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => WelcomView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, -1);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: media.height * 0.35,
                color: TColor.main,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(_route_Welcome());
                            },
                          ),
                          TextButton(
                            child: NormalTextBold(
                              color: TColor.primary,
                              txt: "Register",
                              size: 15,
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUpView()));
                            },
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BigText(
                              color: TColor.primary,
                              txt: "Sign In",
                              size: 30,
                            ),
                            NormalText(
                                color: TColor.primary,
                                txt: "Login To Continue Using App")
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )),
          Positioned(
            top: media.height * 0.3,
            left: 0,
            right: 0,
            child: Container(
              height: media.height * 0.7,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
                child: Form(
                  key: _formKey,
                  child: Column(children: [
                    Align(
                        alignment: Alignment.topLeft,
                        child: NormalText(color: TColor.primary, txt: "Email")),
                    RoundTextField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Your Email';
                        }
                        return null;
                      },
                      hint: " Enter Your Email ",
                      obscureText: false,
                      textEditingController: emailController,
                      preicon: Icon(Icons.account_circle_outlined),
                      sufIcon: false,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Align(
                        alignment: Alignment.topLeft,
                        child:
                            NormalText(color: TColor.primary, txt: "Password")),
                    RoundTextField(
                      hint: "Enter Your Password",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Your Password';
                        }
                        return null;
                      },
                      obscureText: true,
                      textEditingController: passwordController,
                      preicon: Icon(Icons.lock_outlined),
                      sufIcon: true,
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        child: NormalTextBold(
                          color: TColor.main,
                          txt: "Forget Password?",
                          size: 15,
                        ),
                        onPressed: () {},
                      ),
                    ),
                    RoundButton(
                      txt: NormalTextBold(color: Colors.white, txt: "Sign In"),
                      color: TColor.main,
                      onpress: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            email = emailController.text.trim();
                            password = passwordController.text.trim();
                          });
                          UserLogin();
                        }

                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    NormalTextBold(
                      color: TColor.primary,
                      txt: "Or Continue With",
                      size: 15,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    RoundButtonIcon(
                      txt: NormalTextBold(
                        color: TColor.primary,
                        txt: "Continue with Google",
                        size: 18,
                      ),
                      color: TColor.placeholder,
                      image: Image.asset(
                        "assets/image/logo_google.png",
                        width: 25,
                        height: 25,
                        fit: BoxFit.contain,
                      ),
                      shadow: true,
                      onpress: () {},
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    RoundButtonIcon(
                      txt: NormalTextBold(
                        color: TColor.primary,
                        txt: "Continue with Facebook",
                        size: 18,
                      ),
                      color: TColor.placeholder,
                      image: Image.asset(
                        "assets/image/logo_facebook.png",
                        width: 30,
                        height: 30,
                        fit: BoxFit.contain,
                      ),
                      shadow: true,
                      onpress: () {},
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    RoundButtonIcon(
                      txt: NormalTextBold(
                        color: TColor.primary,
                        txt: "Continue with Apple",
                        size: 18,
                      ),
                      color: TColor.placeholder,
                      image: Image.asset(
                        "assets/image/apple_icon.png",
                        width: 30,
                        height: 30,
                        fit: BoxFit.contain,
                      ),
                      shadow: true,
                      onpress: () {},
                    ),
                  ]),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
