import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/core/widgets/round_button.dart';
import 'package:delivery_apps/core/widgets/round_icon_circle.dart';
import 'package:delivery_apps/core/widgets/round_textfield.dart';
import 'package:delivery_apps/features/home/screen/shipper_main_screen.dart';
import 'package:flutter/material.dart';

class ShipperRegistrationView extends StatefulWidget {
  const ShipperRegistrationView({super.key});

  @override
  State<ShipperRegistrationView> createState() => _ShipperRegistrationViewState();
}

class _ShipperRegistrationViewState extends State<ShipperRegistrationView> {
  final _formKey = GlobalKey<FormState>();
  final BackendService _backendService = BackendService();

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();
  final TextEditingController licensePlateController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _registerShipper() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 1. Register shipper in backend (This now updates role atomically)
      await _backendService.registerShipper(
        phone: phoneController.text.trim(),
        vehicleName: vehicleController.text.trim(),
        licensePlate: licensePlateController.text.trim(),
      );

      // 2. Fetch updated user profile to get the new 'SHIPPER' role
      final updatedUser = await _backendService.getMe();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration successful!',
                style: AppTextStyle.body(context, color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to shipper dashboard
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => ShipperMainScreen(user: updatedUser)),
          (route) => false,
        );
      }
    } catch (e) {
      setState(
          () => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.inputFill(context),
      appBar: AppBar(
        title: Text("Become a Shipper", style: AppTextStyle.title(context)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: AppColor.textTitle(context)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Join our fleet and earn by delivering food!",
                style: AppTextStyle.body(context),
              ),
              const SizedBox(height: 30),
              
              _label("Phone Number"),
              RoundTextField(
                textEditingController: phoneController,
                hint: "Enter your phone number",
                validator: (v) =>
                    v!.isEmpty ? "Please enter your phone number" : null,
                obscureText: false,
                sufIcon: false,
                preicon: const Icon(Icons.phone_outlined),
              ),
              const SizedBox(height: 20),

              _label("Vehicle Name"),
              RoundTextField(
                textEditingController: vehicleController,
                hint: "e.g. Honda Alpha",
                validator: (v) =>
                    v!.isEmpty ? "Please enter your vehicle name" : null,
                obscureText: false,
                sufIcon: false,
                preicon: const Icon(Icons.motorcycle_outlined),
              ),
              const SizedBox(height: 20),

              _label("License Plate"),
              RoundTextField(
                textEditingController: licensePlateController,
                hint: "e.g. 29-H1 12345",
                validator: (v) =>
                    v!.isEmpty ? "Please enter your license plate" : null,
                obscureText: false,
                sufIcon: false,
                preicon: const Icon(Icons.badge_outlined),
              ),
              const SizedBox(height: 30),

              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),

              _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : RoundButton(
                    txt: Text("Register", style: AppTextStyle.bodyBold(context, color: Colors.white)),
                    color: AppColor.primary(context),
                      onpress: _registerShipper,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 5),
      child: Text(
        text,
        style:
            AppTextStyle.bodyBold(context, color: AppColor.textTitle(context)),
      ),
    );
  }
}
