import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/user_model.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/core/widgets/round_button.dart';
import 'package:delivery_apps/core/widgets/round_icon_circle.dart';
import 'package:delivery_apps/core/widgets/round_textfield.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone ?? "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name cannot be empty"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await BackendService().updateUser(
        widget.user.uid,
        name: name,
        phone: phone,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully"), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.container(context),
      appBar: AppBar(
        leadingWidth: 60,
        backgroundColor: AppColor.inputFill(context),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: RoundIconCircle(
            icon: const Icon(Icons.arrow_back_ios_new_outlined),
            onTap: () => Navigator.pop(context),
          ),
        ),
        title: Text("Edit Profile", 
          style: AppTextStyle.bodyBold(context, color: AppColor.textTitle(context))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Full Name", style: AppTextStyle.bodyBold(context, fontSize: 14)),
            const SizedBox(height: 8),
            RoundTextField(
              textEditingController: _nameController,
              hint: "Enter your name",
              preicon: Icon(Icons.person_outline, color: AppColor.textSecondary(context)),
              obscureText: false,
              sufIcon: false,
            ),
            const SizedBox(height: 20),
            Text("Phone Number", style: AppTextStyle.bodyBold(context, fontSize: 14)),
            const SizedBox(height: 8),
            RoundTextField(
              textEditingController: _phoneController,
              hint: "Enter your phone number",
              preicon: Icon(Icons.phone_outlined, color: AppColor.textSecondary(context)),
              obscureText: false,
              sufIcon: false,
            ),
            const SizedBox(height: 40),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              RoundButton(
                txt: Text("Save Changes", style: AppTextStyle.bodyBold(context, color: Colors.white)),
                color: AppColor.primary(context),
                onpress: _updateProfile,
              ),
          ],
        ),
      ),
    );
  }
}
