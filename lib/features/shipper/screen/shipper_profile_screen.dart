import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/shipper_model.dart';
import 'package:delivery_apps/core/models/user_model.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/features/user/profile/screen/login_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ShipperProfileScreen extends StatefulWidget {
  final UserModel user;
  const ShipperProfileScreen({super.key, required this.user});

  @override
  State<ShipperProfileScreen> createState() => _ShipperProfileScreenState();
}

class _ShipperProfileScreenState extends State<ShipperProfileScreen> {
  bool _isLoading = true;
  ShipperModel? _shipperInfo;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final shipper = await BackendService().getMyShipper();
      if (mounted && shipper != null) {
        setState(() {
          _shipperInfo = shipper;
          _isOnline = shipper.isActive;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleOnlineStatus(bool value) async {
    setState(() => _isOnline = value); // Optimistic UI update
    try {
      await BackendService().updateMyShipper(isActive: value);
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() => _isOnline = !value);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update status')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColor.inputFill(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColor.inputFill(context),
      appBar: AppBar(
        title: Text('Profile', style: AppTextStyle.bodyBold(context, fontSize: 18, color: Colors.white)),
        backgroundColor: AppColor.primary(context),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginView()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Profile
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 30, top: 20),
              decoration: BoxDecoration(
                color: AppColor.primary(context),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                   CircleAvatar(
                     radius: 50,
                     backgroundColor: Colors.white,
                     child: Icon(Icons.delivery_dining, size: 50, color: AppColor.primary(context)),
                   ),
                   const SizedBox(height: 16),
                   Text(widget.user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                   const SizedBox(height: 6),
                   Text(widget.user.phone ?? widget.user.email, style: const TextStyle(color: Colors.white70, fontSize: 15)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Toggle Online
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColor.container(context),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                   Container(
                     padding: const EdgeInsets.all(10),
                     decoration: BoxDecoration(color: _isOnline ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1), shape: BoxShape.circle),
                     child: Icon(Icons.power_settings_new, color: _isOnline ? Colors.green : Colors.grey),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(_isOnline ? 'Online' : 'Offline', style: AppTextStyle.bodyBold(context, fontSize: 16)),
                         Text(_isOnline ? 'You will receive new orders' : 'You will not receive new orders', style: AppTextStyle.body(context, fontSize: 13, color: AppColor.textSecondary(context))),
                       ],
                     ),
                   ),
                   Switch(
                     value: _isOnline,
                     activeColor: Colors.green,
                     onChanged: _toggleOnlineStatus,
                   )
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Vehicle Info
            if (_shipperInfo != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColor.container(context),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vehicle Information', style: AppTextStyle.bodyBold(context, fontSize: 16)),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.two_wheeler, 'Vehicle Type', _shipperInfo!.vehicleName),
                    const Divider(height: 24),
                    _buildInfoRow(Icons.pin, 'License Plate', _shipperInfo!.licensePlate),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColor.textSecondary(context), size: 22),
        const SizedBox(width: 16),
        Text(label, style: AppTextStyle.body(context, color: AppColor.textSecondary(context), fontSize: 14)),
        const Spacer(),
        Text(value, style: AppTextStyle.bodyBold(context, fontSize: 15)),
      ],
    );
  }
}
