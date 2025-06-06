import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_apps/common/color_extention.dart';
import 'package:delivery_apps/common_widget/big_text.dart';
import 'package:delivery_apps/common_widget/normal_text.dart';
import 'package:delivery_apps/common_widget/normal_text_bold.dart';
import 'package:delivery_apps/common_widget/round_button.dart';
import 'package:delivery_apps/common_widget/round_textfield.dart';
import 'package:delivery_apps/server/firebase_service.dart';
import 'package:delivery_apps/view/login/login_view.dart';
import 'package:delivery_apps/view/main_tabview/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final FirebaseService _firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  String errorMessage = "";

  Future<bool> isUsernameTaken(String username) async {
    final snapshot = await _firebaseFirestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<void> registerUser() async {
    setState(() {
      errorMessage = "";
    });

    final username = userNameController.text.trim();
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final phone = phoneController.text.trim();

    if (await isUsernameTaken(username)) {
      setState(() {
        errorMessage = "Username already exists. Please choose another.";
      });
      return;
    }

    try {
      await _firebaseService.createUser(email, password, username, name, phone);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: NormalText(
              color: TColor.primaryText, txt: "Registered Successfully"),
          backgroundColor: TColor.main,
        ),
      );

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } on FirebaseException catch (e) {
      String errorMsg;
      switch (e.code) {
        case 'weak-password':
          errorMsg = "Password provided is too weak.";
          break;
        case 'email-already-in-use':
          errorMsg = "Account already exists.";
          break;
        case 'invalid-email':
          errorMsg = "The email address is not valid.";
          break;
        default:
          errorMsg = "An error occurred: ${e.message}";
          break;
      }

      setState(() {
        errorMessage = errorMsg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.placeholder,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon:
                      const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 30),
                BigText(color: TColor.primary, txt: "Register"),
                NormalTextBold(
                    color: TColor.primaryText,
                    txt: "Enter Your Personal Information"),
                const SizedBox(height: 20),
                NormalTextBold(color: TColor.primary, txt: "Username"),
                RoundTextField(
                  textEditingController: userNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                  hint: "Enter your username",
                  obscureText: false,
                  sufIcon: false,
                ),
                const SizedBox(height: 15),
                NormalTextBold(color: TColor.primary, txt: "Email"),
                RoundTextField(
                  textEditingController: emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                  hint: "Enter your email",
                  obscureText: false,
                  sufIcon: false,
                ),
                const SizedBox(height: 15),
                NormalTextBold(color: TColor.primary, txt: "Name"),
                RoundTextField(
                  textEditingController: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  hint: "Enter your name",
                  obscureText: false,
                  sufIcon: false,
                ),
                const SizedBox(height: 15),
                NormalTextBold(color: TColor.primary, txt: "Phone Number"),
                RoundTextField(
                  textEditingController: phoneController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                  hint: "Enter your phone number",
                  obscureText: false,
                  sufIcon: false,
                ),
                const SizedBox(height: 15),
                NormalTextBold(color: TColor.primary, txt: "Password"),
                RoundTextField(
                  textEditingController: passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  hint: "Enter password",
                  obscureText: true,
                  sufIcon: true,
                ),
                const SizedBox(height: 15),
                NormalTextBold(color: TColor.primary, txt: "Confirm Password"),
                RoundTextField(
                  textEditingController: confirmPasswordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    } else if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  hint: "Confirm password",
                  obscureText: true,
                  sufIcon: true,
                ),
                const SizedBox(height: 15),
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                RoundButton(
                  txt: NormalTextBold(color: Colors.white, txt: "Register"),
                  color: TColor.main,
                  onpress: () async {
                    if (_formKey.currentState!.validate()) {
                      await registerUser();
                    }
                  },
                ),
                Row(
                  children: [
                    NormalText(
                        color: TColor.primary,
                        txt: "Already have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginView()));
                      },
                      child: Text("Login",
                          style: TextStyle(color: TColor.main, fontSize: 20)),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
