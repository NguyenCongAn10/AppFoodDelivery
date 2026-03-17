import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/widgets/round_button.dart';
import 'package:delivery_apps/core/widgets/round_textfield.dart';
import 'package:delivery_apps/core/services/firebase_auth_service.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/core/services/auth_repository.dart';
import 'package:delivery_apps/features/profile/screen/login_view.dart';
import 'package:delivery_apps/features/profile/screen/otp_verification_view.dart';
import 'package:delivery_apps/core/router/app_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final FirebaseAuthService _firebaseService = FirebaseAuthService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String errorMessage = '';

  Future<void> _register() async {
    setState(() => errorMessage = '');

    final username = userNameController.text.trim();
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final phone = phoneController.text.trim();

    try {
      await _firebaseService.createUser(email, password, username, name, phone);

      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        final idToken = await firebaseUser.getIdToken();
        if (idToken != null) {
          await AuthRepository().saveFirebaseToken(idToken);
        }
        try {
          await BackendService().createUser(
            uid: firebaseUser.uid,
            name: name,
            email: email,
            phone: phone,
          );
        } catch (e) {
          if (kDebugMode)
            debugPrint('Warning: Backend user creation failed: $e');
        }
      }

      if (mounted) {
        // Send OTP via Email
        try {
          await BackendService().sendOtp(email);
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OTPVerificationView(email: email),
              ),
            );
          }
        } catch (e) {
          setState(() => errorMessage = 'Failed to send OTP: $e');
        }
      }
    } on FirebaseException catch (e) {
      final msg = switch (e.code) {
        'weak-password' => 'Password provided is too weak.',
        'email-already-in-use' => 'Account already exists.',
        'invalid-email' => 'The email address is not valid.',
        _ => 'An error occurred: ${e.message}',
      };
      setState(() => errorMessage = msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.inputFill(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new,
                      color: AppColor.textTitle(context)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 10),
                Text('Register',
                    style: AppTextStyle.title(context,
                        color: AppColor.textTitle(context))),
                Text('Enter Your Personal Information',
                    style: AppTextStyle.bodyBold(context)),
                const SizedBox(height: 30),
                _label(context, 'Username'),
                RoundTextField(
                  textEditingController: userNameController,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Please enter your username' : null,
                  hint: 'Enter your username',
                  obscureText: false,
                  sufIcon: false,
                ),
                const SizedBox(height: 15),
                _label(context, 'Email'),
                RoundTextField(
                  textEditingController: emailController,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter your email';
                    final bool emailValid = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(v);
                    if (!emailValid) return 'Please enter a valid email address';
                    return null;
                  },
                  hint: 'Enter your email',
                  obscureText: false,
                  sufIcon: false,
                ),
                const SizedBox(height: 15),
                _label(context, 'Name'),
                RoundTextField(
                  textEditingController: nameController,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Please enter your name' : null,
                  hint: 'Enter your name',
                  obscureText: false,
                  sufIcon: false,
                ),
                const SizedBox(height: 15),
                _label(context, 'Phone Number'),
                RoundTextField(
                  textEditingController: phoneController,
                  validator: (v) => v == null || v.isEmpty
                      ? 'Please enter your phone number'
                      : null,
                  hint: 'Enter your phone number',
                  obscureText: false,
                  sufIcon: false,
                ),
                const SizedBox(height: 15),
                _label(context, 'Password'),
                RoundTextField(
                  textEditingController: passwordController,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter your password';
                    if (v.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                  hint: 'Enter password',
                  obscureText: true,
                  sufIcon: true,
                ),
                const SizedBox(height: 15),
                _label(context, 'Confirm Password'),
                RoundTextField(
                  textEditingController: confirmPasswordController,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please confirm your password';
                    if (v != passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                  hint: 'Confirm password',
                  obscureText: true,
                  sufIcon: true,
                ),
                const SizedBox(height: 15),
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 14)),
                  ),
                RoundButton(
                  txt: Text('Register',
                      style:
                          AppTextStyle.bodyBold(context, color: Colors.white)),
                  color: AppColor.primary(context),
                  onpress: () async {
                    if (_formKey.currentState!.validate()) await _register();
                  },
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Already have an account? ',
                        style: AppTextStyle.body(context)),
                    TextButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const LoginView())),
                      child: Text('Login',
                          style: TextStyle(
                              color: AppColor.primary(context), fontSize: 16)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Text(text,
      style: AppTextStyle.bodyBold(context, color: AppColor.textTitle(context)));
}
