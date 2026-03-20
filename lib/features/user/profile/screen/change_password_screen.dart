import 'package:flutter/material.dart';
import 'package:delivery_apps/core/services/firebase_auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _loading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final service = FirebaseAuthService();
      await service.changePassword(
        currentPassword: _currentCtrl.text.trim(),
        newPassword: _newCtrl.text.trim(),
      );

      if (!mounted) return;

      // Clear inputs first
      _currentCtrl.clear();
      _newCtrl.clear();
      _confirmCtrl.clear();

      // Show success dialog; when user taps OK, pop this screen to return to Profile
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Đổi mật khẩu thành công'),
          content: const Text('Mật khẩu của bạn đã được cập nhật.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (confirmed == true && mounted) {
        Navigator.of(context).pop(); // quay về màn hình profile
      }
    } catch (e) {
      if (!mounted) return;
      final message = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Lỗi khi đổi mật khẩu';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đổi mật khẩu thất bại: $message')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback toggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildPasswordField(
                controller: _currentCtrl,
                label: 'Current password',
                obscure: _obscureCurrent,
                toggle: () =>
                    setState(() => _obscureCurrent = !_obscureCurrent),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter current password';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildPasswordField(
                controller: _newCtrl,
                label: 'New password',
                obscure: _obscureNew,
                toggle: () => setState(() => _obscureNew = !_obscureNew),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter new password';
                  if (v.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildPasswordField(
                controller: _confirmCtrl,
                label: 'Confirm new password',
                obscure: _obscureConfirm,
                toggle: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Confirm your new password';
                  }
                  if (v != _newCtrl.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _changePassword,
                  child: _loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Change Password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
