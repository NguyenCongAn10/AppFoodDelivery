import 'dart:async';

import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/router/app_router.dart';
import 'package:delivery_apps/core/services/firebase_auth_service.dart';
import 'package:delivery_apps/core/widgets/round_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PhoneOtpView extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final Future<void> Function()? onVerified;

  const PhoneOtpView({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    this.onVerified,
  });

  @override
  State<PhoneOtpView> createState() => _PhoneOtpViewState();
}

class _PhoneOtpViewState extends State<PhoneOtpView> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final _firebaseService = FirebaseAuthService();

  bool _isLoading = false;
  String _errorMessage = '';
  int _resendTimer = 60;
  Timer? _timer;
  late String _currentVerificationId;

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId;
    _startTimer();
  }

  void _startTimer() {
    _resendTimer = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otp = _controllers.map((e) => e.text).join();
    if (otp.length < 6) {
      setState(() => _errorMessage = 'Please enter all 6 digits');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _firebaseService.verifyPhoneOtp(
        verificationId: _currentVerificationId,
        smsCode: otp,
      );
      if (widget.onVerified != null) {
        await widget.onVerified!();
      }
      if (mounted) {
        await AppRouter.routeAfterLogin(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_resendTimer > 0) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    await _firebaseService.sendPhoneOtp(
      phoneNumber: widget.phoneNumber,
      onCodeSent: (verificationId) {
        if (!mounted) return;
        setState(() {
          _currentVerificationId = verificationId;
          _isLoading = false;
        });
        _startTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP Resent Successfully')),
        );
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = error;
        });
      },
      onAutoVerified: (PhoneAuthCredential credential) async {
        try {
          await _firebaseService.verifyPhoneOtp(
            verificationId: _currentVerificationId,
            smsCode: '',
            credential: credential,
          );
          if (widget.onVerified != null) {
            await widget.onVerified!();
          }
          if (mounted) await AppRouter.routeAfterLogin(context);
        } catch (e) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = e.toString().replaceFirst('Exception: ', '');
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: AppColor.textTitle(context)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColor.primary(context).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sms_outlined,
                size: 40,
                color: AppColor.primary(context),
              ),
            ),
            const SizedBox(height: 24),
            Text('SMS Verification', style: AppTextStyle.title(context)),
            const SizedBox(height: 10),
            Text(
              'We sent a 6-digit code to\n${widget.phoneNumber}',
              textAlign: TextAlign.center,
              style: AppTextStyle.body(context),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                (index) => SizedBox(
                  width: 45,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: AppTextStyle.title(context),
                    decoration: InputDecoration(
                      counterText: '',
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColor.primary(context)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      } else if (value.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                      if (index == 5 && value.isNotEmpty) {
                        _verifyOtp();
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 30),
            _isLoading
                ? CircularProgressIndicator(color: AppColor.primary(context))
                : RoundButton(
                    txt: Text(
                      'Verify',
                      style:
                          AppTextStyle.bodyBold(context, color: Colors.white),
                    ),
                    color: AppColor.primary(context),
                    onpress: _verifyOtp,
                  ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Didn't receive code? ",
                    style: AppTextStyle.body(context)),
                TextButton(
                  onPressed: _resendTimer == 0 ? _resendOtp : null,
                  child: Text(
                    _resendTimer == 0
                        ? 'Resend'
                        : 'Resend in ${_resendTimer}s',
                    style: TextStyle(
                      color: _resendTimer == 0
                          ? AppColor.primary(context)
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
