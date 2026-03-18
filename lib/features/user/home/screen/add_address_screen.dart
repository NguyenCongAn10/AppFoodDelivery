import 'dart:async';
import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/place_result.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/core/widgets/round_icon_circle.dart';
import 'package:delivery_apps/core/widgets/round_textfield.dart';
import 'package:flutter/material.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final TextEditingController _searchController = TextEditingController();
  final BackendService _backendService = BackendService();
  Timer? _debounce;

  List<PlaceResult> _searchResults = [];
  bool _isSearching = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      if (query.isNotEmpty) {
        _searchAddresses(query);
      } else {
        setState(() => _searchResults = []);
      }
    });
  }

  Future<void> _searchAddresses(String query) async {
    setState(() => _isSearching = true);
    try {
      final results = await _backendService.searchAddresses(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching address: $e')),
        );
      }
    }
  }

  Future<void> _saveAddress(PlaceResult place) async {
    setState(() => _isSaving = true);
    try {
      await _backendService.addAddress(
        address: place.displayName,
        latitude: place.lat,
        longitude: place.lon,
        isDefault: true,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address added successfully'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Return true to indicate an update
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save address: $e'), backgroundColor: Colors.red),
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
        title: Text("Add New Address", 
          style: AppTextStyle.bodyBold(context, color: AppColor.textTitle(context))),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: RoundTextField(
              textEditingController: _searchController,
              hint: 'Search for an address...',
              preicon: Icon(Icons.search, color: AppColor.textTitle(context)),
              sufIcon: false,
              obscureText: false,
              onChanged: _onSearchChanged,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
            ),
          ),
          if (_isSearching || _isSaving) const LinearProgressIndicator(),
          Expanded(
            child: _searchResults.isEmpty
                ? Center(
                    child: Text(
                      _searchController.text.isEmpty
                          ? "Enter an address to search"
                          : "No results found",
                      style: AppTextStyle.body(context, color: AppColor.textSecondary(context)),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _searchResults.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final place = _searchResults[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColor.primary(context).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.location_on, color: AppColor.primary(context), size: 20),
                        ),
                        title: Text(place.displayName, 
                          maxLines: 2, 
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.body(context, fontSize: 14)),
                        onTap: _isSaving ? null : () => _saveAddress(place),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
