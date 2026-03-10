import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/core/widgets/round_button.dart';
import 'package:delivery_apps/core/widgets/round_icon_circle.dart';
import 'package:delivery_apps/core/widgets/round_textfield.dart';
import 'package:delivery_apps/features/home/screen/restaurant_main_screen.dart';
import 'package:flutter/material.dart';

// Note: Backend might not have `registerRestaurant` yet.
// We will placeholder the logic and assume an API allows role update or category creation.
class RestaurantRegistrationView extends StatefulWidget {
  const RestaurantRegistrationView({super.key});

  @override
  State<RestaurantRegistrationView> createState() => _RestaurantRegistrationViewState();
}

class _RestaurantRegistrationViewState extends State<RestaurantRegistrationView> {
  final _formKey = GlobalKey<FormState>();
  final BackendService _backendService = BackendService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _registerRestaurant() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Logic for restaurant registration. 
      // If no explicit endpoint, you might just update User Role.
      final me = await _backendService.getMe();
      
      // Update role explicitly if custom endpoint not yet ready
      await _backendService.updateUser(me.id, role: 'RESTAURANT', phone: phoneController.text.trim());

      final updatedUser = await _backendService.getMe();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => RestaurantMainScreen(user: updatedUser)),
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
        title: Text("Become a Partner", style: AppTextStyle.title(context)),
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Center(
            child: RoundIconCircle(
              icon: Icon(Icons.arrow_back_ios_new, color: AppColor.textTitle(context)),
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
              Text("Open your restaurant and reach more customers!", style: AppTextStyle.body(context)),
              const SizedBox(height: 30),
              
              Text("Restaurant Name", style: AppTextStyle.bodyBold(context)),
              RoundTextField(
                textEditingController: nameController,
                hint: "Enter your restaurant name",
                validator: (v) => v!.isEmpty ? "Required" : null,
                obscureText: false,
                sufIcon: false,
              ),
              const SizedBox(height: 15),

              Text("Address", style: AppTextStyle.bodyBold(context)),
              RoundTextField(
                textEditingController: addressController,
                hint: "Enter your full address",
                validator: (v) => v!.isEmpty ? "Required" : null,
                obscureText: false,
                sufIcon: false,
              ),
              const SizedBox(height: 15),

              Text("Contact Phone", style: AppTextStyle.bodyBold(context)),
              RoundTextField(
                textEditingController: phoneController,
                hint: "Enter contact number",
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
                    txt: Text("Open Restaurant", style: AppTextStyle.bodyBold(context, color: Colors.white)),
                    color: AppColor.primary(context),
                    onpress: () {
                      if (_formKey.currentState!.validate()) {
                        _registerRestaurant();
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
