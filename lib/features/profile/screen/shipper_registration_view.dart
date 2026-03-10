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
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 1. Register shipper in backend
      await _backendService.registerShipper(
        phone: phoneController.text.trim(),
        vehicleName: vehicleController.text.trim(),
        licensePlate: licensePlateController.text.trim(),
      );

      // 2. Fetch updated user profile specifically to get updated role
      final updatedUser = await _backendService.getMe();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!'), backgroundColor: Colors.green),
        );
        // Navigate to shipper dashboard
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => ShipperMainScreen(user: updatedUser)),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
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
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Center(
            child: RoundIconCircle(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColor.textTitle(context)),
              onTap: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Join our fleet and earn by delivering food!", style: AppTextStyle.body(context)),
              const SizedBox(height: 30),
              
              Text("Phone Number", style: AppTextStyle.bodyBold(context)),
              RoundTextField(
                textEditingController: phoneController,
                hint: "Enter your phone number",
                validator: (v) => v!.isEmpty ? "Required" : null,
                obscureText: false,
                sufIcon: false,
              ),
              const SizedBox(height: 15),

              Text("Vehicle Name", style: AppTextStyle.bodyBold(context)),
              RoundTextField(
                textEditingController: vehicleController,
                hint: "e.g. Honda Alpha",
                validator: (v) => v!.isEmpty ? "Required" : null,
                obscureText: false,
                sufIcon: false,
              ),
              const SizedBox(height: 15),

              Text("License Plate", style: AppTextStyle.bodyBold(context)),
              RoundTextField(
                textEditingController: licensePlateController,
                hint: "e.g. 29-H1 12345",
                validator: (v) => v!.isEmpty ? "Required" : null,
                obscureText: false,
                sufIcon: false,
              ),
              const SizedBox(height: 15),

              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                ),

              _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : RoundButton(
                    txt: Text("Register", style: AppTextStyle.bodyBold(context, color: Colors.white)),
                    color: AppColor.primary(context),
                    onpress: () {
                      if (_formKey.currentState!.validate()) {
                        _registerShipper();
                      }
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
