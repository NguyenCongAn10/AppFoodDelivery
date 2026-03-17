import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/address_model.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/core/widgets/round_icon_circle.dart';
import 'package:delivery_apps/features/home/screen/add_address_screen.dart';
import 'package:flutter/material.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  final BackendService _backendService = BackendService();
  List<AddressModel> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);
    try {
      final addresses = await _backendService.getAddresses();
      if (mounted) {
        setState(() {
          _addresses = addresses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load addresses: $e')),
        );
      }
    }
  }

  Future<void> _deleteAddress(int id) async {
    // Note: Backend might need a delete endpoint. For now, we'll just show local removal 
    // or if backend has it, call it. Based on addressController, it might be missing delete.
    // Let's assume we can at least refresh after modification.
    _loadAddresses();
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
        title: Text("My Addresses", 
          style: AppTextStyle.bodyBold(context, color: AppColor.textTitle(context))),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddAddressScreen()),
                );
                if (result == true) {
                  _loadAddresses();
                }
              },
              icon: Icon(Icons.add_location_alt_outlined, color: AppColor.primary(context)),
            ),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off_outlined, size: 80, color: AppColor.textSecondary(context).withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text("No addresses saved yet", 
                        style: AppTextStyle.body(context, color: AppColor.textSecondary(context))),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddAddressScreen()),
                          );
                          if (result == true) _loadAddresses();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary(context),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Add New Address"),
                      )
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    final address = _addresses[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColor.inputFill(context),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColor.primary(context).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.location_on, color: AppColor.primary(context), size: 24),
                        ),
                        title: Text(address.address.split(',').first.trim(), 
                          style: AppTextStyle.bodyBold(context)),
                        subtitle: Text(address.address, 
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.body(context, fontSize: 13, color: AppColor.textSecondary(context))),
                        trailing: address.isDefault 
                          ? Icon(Icons.check_circle, color: AppColor.primary(context))
                          : null,
                      ),
                    );
                  },
                ),
    );
  }
}
