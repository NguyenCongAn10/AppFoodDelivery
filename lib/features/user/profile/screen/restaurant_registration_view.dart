import 'dart:async';

import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/place_result.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/core/widgets/round_button.dart';
import 'package:delivery_apps/core/widgets/round_icon_circle.dart';
import 'package:delivery_apps/core/widgets/round_textfield.dart';
import 'package:delivery_apps/features/restaurant/screen/restaurant_main_screen.dart';
import 'package:flutter/material.dart';

class RestaurantRegistrationView extends StatefulWidget {
  const RestaurantRegistrationView({super.key});

  @override
  State<RestaurantRegistrationView> createState() =>
      _RestaurantRegistrationViewState();
}

class _RestaurantRegistrationViewState
    extends State<RestaurantRegistrationView> {
  final _formKey = GlobalKey<FormState>();
  final BackendService _backendService = BackendService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  // Address Search
  List<PlaceResult> _addressSuggestions = [];
  Timer? _debounce;
  bool _isSearchingAddress = false;
  double? _selectedLat;
  double? _selectedLng;

  @override
  void dispose() {
    _debounce?.cancel();
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _onAddressChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.length < 3) {
        setState(() => _addressSuggestions = []);
        return;
      }

      setState(() => _isSearchingAddress = true);
      try {
        final results = await _backendService.searchAddresses(query);
        setState(() {
          _addressSuggestions = results;
        });
      } catch (e) {
        debugPrint("Address search error: $e");
      } finally {
        setState(() => _isSearchingAddress = false);
      }
    });
  }

  Future<void> _registerRestaurant() async {
    if (_selectedLat == null || _selectedLng == null) {
      setState(() => _errorMessage = "Choose a valid address from suggestions");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _backendService.registerRestaurant(
        name: nameController.text.trim(),
        address: addressController.text.trim(),
        latitude: _selectedLat!,
        longitude: _selectedLng!,
        phone: phoneController.text.trim(),
      );

      final updatedUser = await _backendService.getMe();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Restaurant registered successfully!'),
              backgroundColor: Colors.green),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (_) => RestaurantMainScreen(user: updatedUser)),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 15),
      child: Text(text, style: AppTextStyle.bodyBold(context)),
    );
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
              icon: Icon(Icons.arrow_back_ios_new,
                  color: AppColor.textTitle(context)),
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
              Text("Open your restaurant and reach thousands of customers!",
                  style: AppTextStyle.body(context)),
              const SizedBox(height: 10),
              
              _label("Restaurant Name"),
              RoundTextField(
                textEditingController: nameController,
                hint: "Enter your restaurant name",
                validator: (v) =>
                    v!.isEmpty ? "Please enter restaurant name" : null,
                obscureText: false,
                sufIcon: false,
              ),

              _label("Address"),
              Stack(
                children: [
                  Column(
                    children: [
                      RoundTextField(
                        textEditingController: addressController,
                        hint: "Search for restaurant address",
                        onChanged: _onAddressChanged,
                        validator: (v) =>
                            v!.isEmpty ? "Please select an address" : null,
                        obscureText: false,
                        sufIcon: false,
                        sufIconWidget: _isSearchingAddress
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : null,
                      ),
                      if (_addressSuggestions.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          constraints: const BoxConstraints(maxHeight: 200),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: _addressSuggestions.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final addr = _addressSuggestions[index];
                              return ListTile(
                                leading: const Icon(Icons.location_on_outlined),
                                title: Text(addr.displayName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyle.body(context)),
                                onTap: () {
                                  setState(() {
                                    addressController.text = addr.displayName;
                                    _selectedLat = addr.lat;
                                    _selectedLng = addr.lon;
                                    _addressSuggestions = [];
                                  });
                                  FocusScope.of(context).unfocus();
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              _label("Contact Phone"),
              RoundTextField(
                textEditingController: phoneController,
                hint: "Enter phone number",
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v!.isEmpty ? "Please enter phone number" : null,
                obscureText: false,
                sufIcon: false,
              ),
              const SizedBox(height: 30),

              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Text(_errorMessage,
                      style: const TextStyle(color: Colors.red)),
                ),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RoundButton(
                      txt: Text("Open Restaurant Now",
                          style: AppTextStyle.bodyBold(context,
                              color: Colors.white)),
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
