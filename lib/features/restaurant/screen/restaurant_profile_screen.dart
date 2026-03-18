import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/user_model.dart';
import 'package:delivery_apps/features/user/profile/screen/login_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RestaurantProfileScreen extends StatelessWidget {
  final UserModel user;

  const RestaurantProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.inputFill(context),
      appBar: AppBar(
        backgroundColor: AppColor.container(context),
        title: Text('Profile', style: AppTextStyle.bodyBold(context, fontSize: 18)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          // Avatar
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColor.primary(context).withOpacity(0.15),
                  child: Icon(Icons.storefront_rounded, size: 50, color: AppColor.primary(context)),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColor.primary(context),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Center(child: Text(user.name, style: AppTextStyle.bodyBold(context, fontSize: 20))),
          const SizedBox(height: 4),
          Center(child: Text(user.email, style: AppTextStyle.body(context, color: AppColor.textSecondary(context)))),
          const SizedBox(height: 24),
          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.container(context),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
            ),
            child: Column(
              children: [
                _buildInfoRow(context, Icons.storefront_outlined, 'Restaurant Name', 'Galaxy Kitchen'),
                _buildDivider(),
                _buildInfoRow(context, Icons.location_on_outlined, 'Address', 'Kayani Nagar, Borivali, Mumbai'),
                _buildDivider(),
                _buildInfoRow(context, Icons.phone_outlined, 'Phone', '+91 98765 43210'),
                _buildDivider(),
                _buildInfoRow(context, Icons.category_outlined, 'Category', 'Vegetarian'),
                _buildDivider(),
                _buildInfoRow(context, Icons.access_time_outlined, 'Open Hours', '8:00 AM – 10:00 PM'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Settings
          Container(
            decoration: BoxDecoration(
              color: AppColor.container(context),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
            ),
            child: Column(
              children: [
                _buildSettingsTile(context, Icons.edit_outlined, 'Edit Restaurant Info', () {}),
                _buildDivider(),
                _buildSettingsTile(context, Icons.lock_outline, 'Change Password', () {}),
                _buildDivider(),
                _buildSettingsTile(context, Icons.notifications_outlined, 'Notifications', () {}),
                _buildDivider(),
                _buildSettingsTile(
                  context,
                  Icons.logout,
                  'Logout',
                  () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginView()),
                        (route) => false,
                      );
                    }
                  },
                  isDestructive: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColor.primary(context), size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyle.body(context, fontSize: 12, color: AppColor.textSecondary(context))),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyle.bodyBold(context, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isDestructive ? Colors.red : AppColor.primary(context), size: 22),
      title: Text(
        label,
        style: AppTextStyle.body(context, fontSize: 14, color: isDestructive ? Colors.red : AppColor.textTitle(context)),
      ),
      trailing: isDestructive ? null : Icon(Icons.chevron_right, color: AppColor.textSecondary(context), size: 20),
    );
  }

  Widget _buildDivider() => Divider(height: 1, thickness: 0.5, indent: 52);
}
