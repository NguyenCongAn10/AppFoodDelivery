import 'package:delivery_apps/core/models/address_model.dart';
import 'package:flutter/material.dart';

class UserAddressProvider extends ChangeNotifier {
  AddressModel? _selectedAddress;

  AddressModel? get selectedAddress => _selectedAddress;

  void selectAddress(AddressModel address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void clear() {
    _selectedAddress = null;
    notifyListeners();
  }
}
