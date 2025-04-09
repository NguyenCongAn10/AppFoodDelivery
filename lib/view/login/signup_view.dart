import 'package:delivery_apps/common/color_extention.dart';
import 'package:delivery_apps/common_widget/big_text.dart';
import 'package:delivery_apps/common_widget/normal_text.dart';
import 'package:delivery_apps/common_widget/normal_text_bold.dart';
import 'package:delivery_apps/common_widget/round_button.dart';
import 'package:delivery_apps/common_widget/round_textfield.dart';
import 'package:delivery_apps/view/home/home_screen.dart';
import 'package:delivery_apps/view/login/login_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  String userName = "", email = "", password = "", confirmPassword = "";
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Registration() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
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
      debugPrint("Signup error: ${e.code}");
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: NormalText(
                color: TColor.primaryText,
                txt: "Password provided is to weak")));
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: NormalText(
                color: TColor.primaryText, txt: "Account already exsists")));
      }
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
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                BigText(color: TColor.primary, txt: "Register"),
                NormalTextBold(
                  color: TColor.primaryText,
                  txt: "Enter Your Personal Information",
                ),
                const SizedBox(
                  height: 20,
                ),
                NormalTextBold(color: TColor.primary, txt: "Username"),
                RoundTextField(
                  textEditingController: userNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your user name';
                    }
                    return null;
                  },
                  hint: "Enter your name",
                  obscureText: false,
                  sufIcon: false,
                ),
                const SizedBox(
                  height: 15,
                ),
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
                const SizedBox(
                  height: 15,
                ),
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
                const SizedBox(
                  height: 15,
                ),
                NormalTextBold(color: TColor.primary, txt: "Confirm Password"),
                RoundTextField(
                  textEditingController: confirmPasswordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter confirm password';
                    }else if(value != passwordController.text){
                      return'Password Do Not Match';
                    }
                    return null;
                  },
                  hint: "Enter confirm password",
                  obscureText: true,
                  sufIcon: true,
                ),
                const SizedBox(height: 15),
                RoundButton(
                    txt: NormalTextBold(color: Colors.white, txt: "Register"),
                    color: TColor.main,
                    onpress: () async {
                      print("Register button pressed"); // <-- thêm dòng này
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          email = emailController.text;
                          userName = userNameController.text;
                          password = passwordController.text;
                          confirmPassword = confirmPasswordController.text;
                        });
                        await Registration();
                      }
                    }),
                Row(
                  children: [
                    NormalText(
                        color: TColor.primary, txt: "Aready have an account? "),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginView()));
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(color: TColor.main,fontSize: 20),
                        ))
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
