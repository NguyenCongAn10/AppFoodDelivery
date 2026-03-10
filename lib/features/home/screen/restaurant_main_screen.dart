import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/user_model.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/features/profile/screen/login_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RestaurantMainScreen extends StatefulWidget {
  final UserModel user;
  const RestaurantMainScreen({super.key, required this.user});

  @override
  State<RestaurantMainScreen> createState() => _RestaurantMainScreenState();
}

class _RestaurantMainScreenState extends State<RestaurantMainScreen> {
  final BackendService _backendService = BackendService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.inputFill(context),
      appBar: AppBar(
        title: Text("Restaurant Dashboard", style: AppTextStyle.title(context)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: AppColor.primary(context)),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginView()),
              );
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront, size: 80, color: AppColor.primary(context)),
            const SizedBox(height: 20),
            Text(
              "Welcome, Merchant ${widget.user.name}",
              style: AppTextStyle.bodyBold(context, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              "Your restaurant orders will appear here soon.",
              style: AppTextStyle.body(context, color: AppColor.textSecondary(context)),
            ),
          ],
        ),
      ),
    );
  }
}
