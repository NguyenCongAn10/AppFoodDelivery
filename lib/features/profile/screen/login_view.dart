import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/widgets/round_button.dart';
import 'package:delivery_apps/core/widgets/round_textfield.dart';
import 'package:delivery_apps/core/router/app_router.dart';
import 'package:delivery_apps/features/profile/screen/signup_view.dart';
import 'package:delivery_apps/features/profile/screen/welcome_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:delivery_apps/core/widgets/round_button_image_login.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/core/services/auth_repository.dart';
import 'package:delivery_apps/core/services/firebase_auth_service.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  String email = "", password = "";
  String errorMessage = "";
  bool _isGoogleLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseAuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _login() async {
    setState(() => errorMessage = "");
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        final idToken = await firebaseUser.getIdToken(true);
        if (idToken != null) {
          await AuthRepository().saveFirebaseToken(idToken);
          
          try {
            await BackendService().createUser(
              uid: firebaseUser.uid,
              name: firebaseUser.displayName ?? email.split('@')[0],
              email: firebaseUser.email ?? email,
            );
          } catch (e) {
            if (kDebugMode) debugPrint('Backend createUser warning: $e');
          }
        }
      }

      if (mounted) {
        await AppRouter.routeAfterLogin(context);
      }
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'invalid-credential' => "Invalid email or password.",
        'user-not-found' => "No user found for this email.",
        'wrong-password' => "Wrong password provided.",
        'invalid-email' => "The email address is not valid.",
        'user-disabled' => "This account has been disabled.",
        _ => "An error occurred: ${e.message}",
      };
      setState(() => errorMessage = msg);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      errorMessage = '';
    });
    try {
      final result = await _firebaseService.signInWithGoogle();
      if (result == null) return;

      final idToken = await result.user.getIdToken(true);
      if (idToken != null) {
        await AuthRepository().saveFirebaseToken(idToken);
      }

      if (result.isNewUser) {
        try {
          await BackendService().createUser(
            uid: result.user.uid,
            name: result.user.displayName ?? '',
            email: result.user.email ?? '',
          );
        } catch (e) {
          if (kDebugMode) debugPrint('Backend createUser warning: $e');
        }
      }

      if (mounted) {
        await AppRouter.routeAfterLogin(context);
      }
    } catch (e) {
      setState(() => errorMessage = 'Google Sign-In failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: media.height * 0.35,
              color: AppColor.primary(context),
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
                          icon: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white),
                          onPressed: () => Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => const WelcomeView(),
                              transitionsBuilder: (_, anim, __, child) =>
                                  SlideTransition(
                                position: anim.drive(
                                  Tween(
                                          begin: const Offset(0, -1),
                                          end: Offset.zero)
                                      .chain(CurveTween(
                                          curve: Curves.easeInOut)),
                                ),
                                child: child,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Center(
                        child: Column(
                          children: [
                            Text("Fresh & Delicious",
                                style: AppTextStyle.title(context,
                                    fontSize: 30,
                                    color: Colors.white)),
                            Text("Discovery your next favotire meal",
                                style: AppTextStyle.body(context,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: media.height * 0.3,
            left: 0,
            right: 0,
            child: Container(
              height: media.height * 0.7,
              decoration: BoxDecoration(
                color: AppColor.container(context),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text("Email Address",
                            style: AppTextStyle.bodyBold(context)),
                      ),
                      RoundTextField(
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please Enter Your Email';
                          final bool emailValid = RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(v);
                          if (!emailValid) return 'Please enter a valid email address';
                          return null;
                        },
                        hint: " Enter Your Email ",
                        obscureText: false,
                        textEditingController: emailController,
                        preicon: const Icon(Icons.email_outlined),
                        sufIcon: false,
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text("Password",
                            style: AppTextStyle.bodyBold(context)),
                      ),
                      RoundTextField(
                        hint: "Enter Your Password",
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please Enter Your Password';
                          if (v.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                        obscureText: true,
                        textEditingController: passwordController,
                        preicon: const Icon(Icons.lock_outlined),
                        sufIcon: true,
                      ),
                      if (errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text(errorMessage,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 14)),
                        ),
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text("Forget Password?",
                              style: AppTextStyle.bodyBold(context,
                                  fontSize: 15,
                                  color: AppColor.primary(context))),
                        ),
                      ),
                      RoundButton(
                        txt: Text("Sign In",
                            style: AppTextStyle.bodyBold(context,
                                color: Colors.white)),
                        color: AppColor.primary(context),
                        onpress: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              email = emailController.text.trim();
                              password = passwordController.text.trim();
                            });
                            _login();
                          }
                        },
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey[500],
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text("Or Continue With",
                                style:
                                    AppTextStyle.body(context, fontSize: 15)),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey[500],
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      RoundImageButtonLogin(
                        txt: _isGoogleLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColor.primary(context)),
                              )
                            : Text("Continue with Google",
                                style: AppTextStyle.bodyBold(context,
                                    fontSize: 18,
                                    color: AppColor.textTitle(context))),
                        color: AppColor.secondaryBackground(context),
                        image: _isGoogleLoading
                            ? null
                            : Image.asset("assets/image/logo_google.png",
                                width: 25, height: 25, fit: BoxFit.contain),
                        shadow: true,
                        onpress: _isGoogleLoading ? () {} : _signInWithGoogle,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Don't have an account? ",
                              style: AppTextStyle.body(context)),
                          TextButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const SignUpView())),
                            child: Text(
                              "Create Account",
                              style: AppTextStyle.bodyBold(context).copyWith(
                                fontSize: 15,
                                color: AppColor.primary(context),
                              ),
                            ),
                          )
                        ],

                      ),

                      // const SizedBox(height: 15),
                      // RoundImageButtonLogin(
                      //   txt: Text("Continue with Facebook",
                      //       style: AppTextStyle.bodyBold(context,
                      //           fontSize: 18,
                      //           color: AppColor.textTitle(context))),
                      //   color: AppColor.secondaryBackground(context),
                      //   image: Image.asset("assets/image/logo_facebook.png",
                      //       width: 30, height: 30, fit: BoxFit.contain),
                      //   shadow: true,
                      //   onpress: () {},
                      // ),
                      // const SizedBox(height: 15),
                      // RoundImageButtonLogin(
                      //   txt: Text("Continue with Apple",
                      //       style: AppTextStyle.bodyBold(context,
                      //           fontSize: 18,
                      //           color: AppColor.textTitle(context))),
                      //   color: AppColor.secondaryBackground(context),
                      //   image: Image.asset("assets/image/apple_icon.png",
                      //       width: 30, height: 30, fit: BoxFit.contain),
                      //   shadow: true,
                      //   onpress: () {},
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
