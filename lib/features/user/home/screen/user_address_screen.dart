import 'dart:async';
import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/address_model.dart';
import 'package:delivery_apps/core/models/place_result.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/core/widgets/round_icon_circle.dart';
import 'package:delivery_apps/core/widgets/round_textfield.dart';
import 'package:delivery_apps/features/user/home/providers/user_address_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangeAddressScreen extends StatefulWidget {
  const ChangeAddressScreen({super.key});

  @override
  State<ChangeAddressScreen> createState() => _ChangeAddressScreenState();
}

class _ChangeAddressScreenState extends State<ChangeAddressScreen> {
  final TextEditingController _searchController = TextEditingController();
  final BackendService _backendService = BackendService();
  Timer? _debounce;

  List<PlaceResult> _searchResults = [];
  bool _isSearching = false;

  List<AddressModel> _userAddresses = [];
  bool _isLoadingAddresses = true;

  @override
  void initState() {
    super.initState();
    _loadUserAddresses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadUserAddresses() async {
    try {
      final addresses = await _backendService.getAddresses();
      if (mounted) {
        setState(() {
          _userAddresses = addresses;
          _isLoadingAddresses = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAddresses = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load addresses: $e')),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(seconds: 1), () {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<UserAddressProvider>(
      builder: (context, addressProvider, _) {
        final currentAddress = addressProvider.selectedAddress;

        return Scaffold(
          appBar: AppBar(
            leadingWidth: 60,
            backgroundColor: AppColor.inputFill(context),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: RoundIconCircle(
                icon: const Icon(Icons.arrow_back_ios_new_outlined),
                onTap: () => Navigator.pop(context),
              ),
            ),
            title: SizedBox(
              height: 45,
              child: RoundTextField(
                textEditingController: _searchController,
                hint: 'Search for a new address',
                preicon: Icon(Icons.search, color: AppColor.textTitle(context)),
                sufIcon: false,
                obscureText: false,
                onChanged: _onSearchChanged,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              ),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isSearching) const LinearProgressIndicator(),

              // Current selected address banner
              if (currentAddress != null && _searchResults.isEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: AppColor.textAccent(context).withValues(alpha: 0.1),
                  child: Row(
                    children: [
                      Icon(Icons.location_on,
                          color: AppColor.textAccent(context)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Address',
                              style: AppTextStyle.body(
                                context,
                                fontSize: 12,
                                color: AppColor.textAccent(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              currentAddress.address.split(',').first,
                                style: AppTextStyle.bodyBold(context,
                                    fontSize: 16)),
                            Text(
                              currentAddress.address,
                              style: AppTextStyle.body(context, fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.check_circle,
                          color: AppColor.textAccent(context)),
                    ],
                  ),
                ),

              // Search results list
              if (_searchResults.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final place = _searchResults[index];
                      return ListTile(
                        leading:
                            const Icon(Icons.location_on, color: Colors.blue),
                        title: Text(place.displayName),
                        onTap: () {
                          final address = AddressModel(
                            userUid: '',
                            address: place.displayName,
                            latitude: place.lat,
                            longitude: place.lon,
                            isDefault: true,
                          );
                          addressProvider.selectAddress(address);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                )
              else ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Your Addresses',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                Expanded(
                  child: _isLoadingAddresses
                      ? const Center(child: CircularProgressIndicator())
                      : _userAddresses.isEmpty
                          ? const Center(
                              child: Text('You have no addresses yet'))
                          : ListView.builder(
                              itemCount: _userAddresses.length,
                              itemBuilder: (context, index) {
                                final address = _userAddresses[index];
                                final isSelected =
                                    address.address == currentAddress?.address;

                                return ListTile(
                                  leading: Icon(
                                    Icons.location_on,
                                    color: Colors.grey,
                                  ),
                                  title: Text(address.address.split(',').first,
                                      style: AppTextStyle.bodyBold(context)),
                                  subtitle: Text(address.address,
                                      style: AppTextStyle.body(context)),
                                  onTap: () {
                                    addressProvider.selectAddress(address);
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
