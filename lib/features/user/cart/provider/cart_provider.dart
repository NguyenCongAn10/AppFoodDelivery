import 'package:delivery_apps/core/models/cart_item.dart';
import 'package:delivery_apps/core/models/food_model.dart';
import 'package:delivery_apps/core/models/restaurant_detail_model.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:flutter/foundation.dart';

class CartProvider with ChangeNotifier {
  final BackendService _backendService = BackendService();
  List<CartItem> _items = [];
  bool _isLoading = false;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;

  double get subTotal {
    double total = 0.0;
    for (var item in _items) {
      final quantity = double.tryParse(item.quantity) ?? 0.0;
      final price = double.tryParse(item.price) ?? 0.0;
      total += quantity * price;
    }
    return total;
  }

  int get totalItems {
    int count = 0;
    for (var item in _items) {
        count += int.tryParse(item.quantity) ?? 0;
    }
    return count;
  }

  CartProvider() {
    loadCart();
  }

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _backendService.getCart();
    } catch (e) {
      if (kDebugMode) debugPrint("Error loading cart: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int getQuantity(int foodId) {
    final item = getCartItem(foodId);
    return item != null ? (int.tryParse(item.quantity) ?? 0) : 0;
  }

  CartItem? getCartItem(int foodId) {
    final productId = foodId.toString();
    try {
      return _items.firstWhere(
        (element) => element.productId == productId,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> addFood(FoodModel food, int restaurantId, {int quantity = 1, List<FoodOptionModel> selectedOptions = const []}) async {
    try {
      final productId = food.id.toString();
      
      // Find existing item with exact same food and options
      CartItem? existingItem;
      try {
        existingItem = _items.firstWhere((item) {
          if (item.productId != productId) return false;
          if (item.selectedOptions.length != selectedOptions.length) return false;
          
          final existingIds = item.selectedOptions.map((o) => o.id).toSet();
          final newIds = selectedOptions.map((o) => o.id).toSet();
          return existingIds.containsAll(newIds);
        });
      } catch (_) {
        existingItem = null;
      }

      if (existingItem != null) {
        final currentQuantity = int.tryParse(existingItem.quantity) ?? 0;
        final newQuantity = currentQuantity + quantity;
        await _backendService.updateCartItem(existingItem.id, newQuantity.toString());
      } else {
        final newItem = CartItem(
          id: '0',
          productId: productId,
          restaurantId: restaurantId.toString(),
          name: food.name,
          price: food.price.toString(),
          imageUrl: food.imageUrl ?? '',
          quantity: quantity.toString(),
          selectedOptions: selectedOptions,
        );
        await _backendService.addToCart(newItem);
      }
      await loadCart();
    } catch (e) {
      if (kDebugMode) debugPrint("Error adding to cart: $e");
      rethrow;
    }
  }

  Future<void> removeFood(int foodId) async {
    try {
        final productId = foodId.toString();
        final existingIndex = _items.indexWhere((item) => item.productId == productId);
        
        if (existingIndex != -1) {
            final existingItem = _items[existingIndex];
            final currentQuantity = int.tryParse(existingItem.quantity) ?? 0;
            
            if (currentQuantity > 1) {
                final newQuantity = currentQuantity - 1;
                await _backendService.updateCartItem(existingItem.id, newQuantity.toString());
            } else {
                await _backendService.removeFromCart(existingItem.id);
            }
            await loadCart();
        }
    } catch (e) {
        if (kDebugMode) debugPrint("Error removing from cart: $e");
        rethrow;
    }
  }

  Future<void> updateCartItemQuantity(String cartItemId, String quantity) async {
    try {
        await _backendService.updateCartItem(cartItemId, quantity);
        await loadCart();
    } catch (e) {
        rethrow;
    }
  }

  Future<void> removeItem(String cartItemId) async {
    try {
        _items.removeWhere((item) => item.id == cartItemId);
        notifyListeners();
        
        await _backendService.removeFromCart(cartItemId);
        await loadCart();
    } catch (e) {
        rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      await _backendService.clearCart();
      _items = [];
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint("Error clearing cart: $e");
      rethrow;
    }
  }
}
