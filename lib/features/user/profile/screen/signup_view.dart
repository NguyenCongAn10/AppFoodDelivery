import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/widgets/round_button.dart';
import 'package:delivery_apps/core/widgets/round_textfield.dart';
import 'package:delivery_apps/core/services/firebase_auth_service.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/core/services/auth_repository.dart';
import 'package:delivery_apps/features/user/profile/screen/login_view.dart';
import 'package:delivery_apps/features/user/profile/screen/otp_verification_view.dart';
import 'package:delivery_apps/features/user/profile/screen/phone_otp_view.dart';
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

  bool _isLoading = false;
  String errorMessage = '';

  // ── Step 1: Form Validation & Show Bottom Sheet ──────────────────────────

  Future<void> _register() async {
    setState(() {
      errorMessage = '';
      _isLoading = true;
    });

    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    // Dừng loading để show bottom sheet
    setState(() => _isLoading = false);
    _showOtpMethodSheet(email: email, phone: phone);
  }

  // ── Step 2: Tạo tài khoản (được gọi SAU khi OTP thành công) ──────────────

  Future<void> _createAccount() async {
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
        if (idToken != null) await AuthRepository().saveFirebaseToken(idToken);
        try {
          await BackendService().createUser(
            uid: firebaseUser.uid,
            name: name,
            email: email,
            phone: phone,
          );
        } catch (e) {
          if (kDebugMode) debugPrint('Backend createUser warning: $e');
        }
      }
    } on FirebaseException catch (e) {
      final msg = switch (e.code) {
        'weak-password' => 'Password provided is too weak.',
        'email-already-in-use' => 'Account already exists.',
        'invalid-email' => 'The email address is not valid.',
        _ => 'An error occurred: ${e.message}',
      };
      throw Exception(msg);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // ── Step 3: Bottom sheet chọn Email hay SMS ───────────────────────────────

  void _showOtpMethodSheet({required String email, required String phone}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: AppColor.container(context),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('Verify Your Account',
                style: AppTextStyle.title(context, fontSize: 20)),
            const SizedBox(height: 8),
            Text(
              'Choose how you want to receive your OTP',
              textAlign: TextAlign.center,
              style: AppTextStyle.body(context),
            ),
            const SizedBox(height: 28),

            // Nút Email OTP
            _OtpOptionTile(
              icon: Icons.email_outlined,
              title: 'Send via Email',
              subtitle: email,
              onTap: () {
                Navigator.pop(ctx);
                _sendEmailOtp(email);
              },
            ),
            const SizedBox(height: 12),

            // Nút SMS OTP
            _OtpOptionTile(
              icon: Icons.sms_outlined,
              title: 'Send via SMS',
              subtitle: _firebaseService.formatPhoneNumber(phone),
              onTap: () {
                Navigator.pop(ctx);
                _sendSmsOtp(phone);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Step 4a: Gửi Email OTP (Pre-register) ──────────────────────────────────

  Future<void> _sendEmailOtp(String email) async {
    setState(() {
      _isLoading = true;
      errorMessage = '';
    });
    try {
      await BackendService().sendPreRegisterOtp(email);
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OTPVerificationView(
            email: email,
            onVerified: _createAccount,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          errorMessage = 'Failed to send Email OTP: $e';
        });
      }
    }
  }

  // ── Step 4b: Gửi SMS OTP (Firebase Phone Auth) ───────────────────────────

  Future<void> _sendSmsOtp(String phone) async {
    final formattedPhone = _firebaseService.formatPhoneNumber(phone);
    setState(() {
      _isLoading = true;
      errorMessage = '';
    });

    await _firebaseService.sendPhoneOtp(
      phoneNumber: formattedPhone,
      onCodeSent: (verificationId) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PhoneOtpView(
              phoneNumber: formattedPhone,
              verificationId: verificationId,
              onVerified: _createAccount,
            ),
          ),
        );
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          errorMessage = 'Failed to send SMS: $error';
        });
      },
      onAutoVerified: (PhoneAuthCredential credential) async {
        try {
          await _firebaseService.verifyPhoneOtp(
            verificationId: '',
            smsCode: '',
            credential: credential,
          );
          await _createAccount();
          if (mounted) await AppRouter.routeAfterLogin(context);
        } catch (e) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              errorMessage = e.toString().replaceFirst('Exception: ', '');
            });
          }
        }
      },
    );
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
                _isLoading
                    ? CircularProgressIndicator(
                        color: AppColor.primary(context))
                    : RoundButton(
                        txt: Text('Register',
                            style: AppTextStyle.bodyBold(context,
                                color: Colors.white)),
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

// ── OTP Option Tile ─────────────────────────────────────────────────────────

class _OtpOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OtpOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColor.primary(context).withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColor.primary(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColor.primary(context), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyle.bodyBold(context, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyle.body(context, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
