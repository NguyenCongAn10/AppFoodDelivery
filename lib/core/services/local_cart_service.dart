import 'dart:convert';
import 'package:delivery_apps/core/models/cart_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalCartService {
  static final LocalCartService _instance = LocalCartService._internal();

  factory LocalCartService() {
    return _instance;
  }

  LocalCartService._internal();

  static const String keyCart = 'local_cart';

  Future<List<CartItem>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cartJson = prefs.getString(keyCart);
    if (cartJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(cartJson);
    return decoded.map((e) => CartItem.fromJson(e)).toList();
  }

  Future<void> addToCart(CartItem newItem) async {
    final prefs = await SharedPreferences.getInstance();
    final List<CartItem> currentCart = await getCart();
    
    // Check if item exists
    final index = currentCart.indexWhere((item) => item.productId == newItem.productId && item.id == newItem.id);
    if (index != -1) {
      // Update quantity
      int qty = int.tryParse(currentCart[index].quantity) ?? 0;
      int newQty = int.tryParse(newItem.quantity) ?? 1;
      currentCart[index].quantity = (qty + newQty).toString();
    } else {
      currentCart.add(newItem);
    }
    
    await _saveCart(prefs, currentCart);
  }

  Future<void> updateCartItem(String itemId, String quantity) async {
    final prefs = await SharedPreferences.getInstance();
    final List<CartItem> currentCart = await getCart();
    final index = currentCart.indexWhere((item) => item.id == itemId);
    
    if (index != -1) {
      currentCart[index].quantity = quantity;
      await _saveCart(prefs, currentCart);
    }
  }

  Future<void> removeFromCart(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<CartItem> currentCart = await getCart();
    currentCart.removeWhere((item) => item.id == itemId);
    await _saveCart(prefs, currentCart);
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyCart);
  }

  Future<void> _saveCart(SharedPreferences prefs, List<CartItem> cart) async {
    final String encoded = jsonEncode(cart.map((e) => e.toJson()).toList());
    await prefs.setString(keyCart, encoded);
  }
}
