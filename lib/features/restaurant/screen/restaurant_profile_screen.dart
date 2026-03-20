import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/restaurant_model.dart';
import 'package:delivery_apps/core/models/user_model.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/features/user/profile/screen/login_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RestaurantProfileScreen extends StatefulWidget {
  final UserModel user;

  const RestaurantProfileScreen({super.key, required this.user});

  @override
  State<RestaurantProfileScreen> createState() =>
      _RestaurantProfileScreenState();
}

class _RestaurantProfileScreenState extends State<RestaurantProfileScreen> {
  bool _isLoading = true;
  RestaurantModel? _restaurant;
  final BackendService _backendService = BackendService();

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    setState(() => _isLoading = true);
    try {
      final restaurant = await _backendService.getMyRestaurant();
      if (mounted) {
        setState(() {
          _restaurant = restaurant;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching restaurant profile: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleStatus(bool isOpen) async {
    try {
      final updated = await _backendService.updateRestaurantStatus(isOpen);
      if (mounted) {
        setState(() => _restaurant = updated);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(isOpen
                  ? 'Restaurant is now OPEN'
                  : 'Restaurant is now CLOSED')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update status')),
        );
      }
    }
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchProfileData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 8),
                  // Avatar
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 52,
                          backgroundColor:
                              AppColor.primary(context).withValues(alpha: 0.15),
                          child: Icon(Icons.storefront_rounded,
                              size: 50, color: AppColor.primary(context)),
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
                            child: const Icon(Icons.camera_alt_rounded,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                      child: Text(widget.user.name,
                          style: AppTextStyle.bodyBold(context, fontSize: 20))),
                  const SizedBox(height: 4),
                  Center(
                      child: Text(widget.user.email,
                          style: AppTextStyle.body(context,
                              color: AppColor.textSecondary(context)))),
                  const SizedBox(height: 24),
                
                  // Status Toggle
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColor.container(context),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8)
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.power_settings_new,
                                color: (_restaurant?.isOpen ?? false)
                                    ? Colors.green
                                    : Colors.red,
                                size: 22),
                            const SizedBox(width: 12),
                            Text(
                              (_restaurant?.isOpen ?? false)
                                  ? 'Store is Open'
                                  : 'Store is Closed',
                              style:
                                  AppTextStyle.bodyBold(context, fontSize: 14),
                            ),
                          ],
                        ),
                        Switch.adaptive(
                          value: _restaurant?.isOpen ?? false,
                          onChanged: _toggleStatus,
                          activeColor: AppColor.primary(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColor.container(context),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8)
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                            context,
                            Icons.storefront_outlined,
                            'Restaurant Name',
                            _restaurant?.restaurantName ?? 'N/A'),
                        _buildDivider(),
                        _buildInfoRow(context, Icons.location_on_outlined,
                            'Address', _restaurant?.address ?? 'N/A'),
                        _buildDivider(),
                        _buildInfoRow(context, Icons.phone_outlined, 'Phone',
                            _restaurant?.phone ?? 'N/A'),
                        _buildDivider(),
                        _buildInfoRow(context, Icons.star_outline, 'Rating',
                            '${_restaurant?.rating ?? 0.0} (${_restaurant?.ratingCount ?? 0} reviews)'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Settings
                  Container(
                    decoration: BoxDecoration(
                      color: AppColor.container(context),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8)
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSettingsTile(context, Icons.edit_outlined,
                            'Edit Restaurant Info', () {
                          _showEditProfileBottomSheet();
                        }),
                        _buildDivider(),
                        // _buildSettingsTile(
                        //     context, Icons.lock_outline, 'Change Password', () {
                        //   // TODO: Implement change password
                        // }),
                        // _buildDivider(),
                        // _buildSettingsTile(
                        //     context,
                        //     Icons.notifications_outlined,
                        //     'Notifications',
                        //     () {}),
                        // _buildDivider(),
                        _buildSettingsTile(
                          context,
                          Icons.logout,
                          'Logout',
                          () async {
                            await FirebaseAuth.instance.signOut();
                            if (mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (_) => const LoginView()),
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
            ),
    );
  }

  void _showEditProfileBottomSheet() {
    final nameController =
        TextEditingController(text: _restaurant?.restaurantName);
    final addressController = TextEditingController(text: _restaurant?.address);
    final phoneController = TextEditingController(text: _restaurant?.phone);
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
            color: AppColor.container(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Edit Profile',
                      style: AppTextStyle.bodyBold(context, fontSize: 18)),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextField(context, 'Restaurant Name', nameController),
              const SizedBox(height: 16),
              _buildTextField(context, 'Address', addressController),
              const SizedBox(height: 16),
              _buildTextField(context, 'Phone Number', phoneController,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          setModalState(() => isSaving = true);
                          try {
                            final updated =
                                await _backendService.updateRestaurantProfile(
                              name: nameController.text.trim(),
                              address: addressController.text.trim(),
                              phone: phoneController.text.trim(),
                            );
                            if (mounted) {
                              setState(() => _restaurant = updated);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Profile updated successfully')),
                              );
                            }
                          } catch (e) {
                            debugPrint("Error updating profile: $e");
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Failed to update profile')),
                              );
                            }
                          } finally {
                            if (context.mounted) {
                              setModalState(() => isSaving = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary(context),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Changes',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      BuildContext context, String label, TextEditingController controller,
      {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyle.bodyBold(context,
                fontSize: 14, color: AppColor.textSecondary(context))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyle.body(context),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColor.inputFill(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColor.primary(context), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyle.body(context,
                        fontSize: 12, color: AppColor.textSecondary(context))),
                const SizedBox(height: 2),
                Text(value,
                    style: AppTextStyle.bodyBold(context, fontSize: 14)),
              ],
            ),
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
