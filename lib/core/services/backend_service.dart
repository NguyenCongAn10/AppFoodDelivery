import 'dart:convert';
import 'package:delivery_apps/core/models/place_result.dart';
import 'package:delivery_apps/core/models/food_model.dart';
import 'package:delivery_apps/core/models/order_model.dart';
import 'package:delivery_apps/core/models/restaurant_model.dart';
import 'package:delivery_apps/core/models/shipper_model.dart';
import 'package:delivery_apps/core/models/user_model.dart';
import 'package:delivery_apps/core/models/category_model.dart';
import 'package:delivery_apps/core/models/address_model.dart';
import 'package:delivery_apps/core/models/cart_item.dart';
import 'package:delivery_apps/core/services/auth_repository.dart';
import 'package:delivery_apps/core/models/restaurant_search_result.dart';
import 'package:delivery_apps/core/models/restaurant_detail_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class BackendService {
  static final BackendService _instance = BackendService._internal();

  factory BackendService() {
    return _instance;
  }

  BackendService._internal();

  static const String baseUrl = 'http://192.168.1.82:3000/api';

  final _authRepo = AuthRepository();

  void _logError(String method, dynamic error, [StackTrace? stack]) {
    debugPrint('--- [BackendService Error] in $method ---');
    debugPrint('Error: $error');
    if (stack != null) debugPrint('Stacktrace: $stack');
    debugPrint('------------------------------------------');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authRepo.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final token = data['token'] as String;
        await _authRepo.saveToken(token);
        return UserModel.fromJson(data['user'] as Map<String, dynamic>);
      } else {
        throw Exception(
            'Failed to login: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stack) {
      _logError('login', e, stack);
      rethrow;
    }
  }

  Future<UserModel> getMe() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to get user profile: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logError('getMe', e, stack);
      rethrow;
    }
  }

  Future<List<FoodModel>> getFoods({String? categoryId}) async {
    try {
      String url = '$baseUrl/foods';
      if (categoryId != null && categoryId.isNotEmpty) {
        url += '?category_id=$categoryId';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list
            .map((e) => FoodModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load foods: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logError('getFoods', e, stack);
      rethrow;
    }
  }

  Future<List<FoodModel>> getSearchSuggestions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search/suggestions'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list
            .map((e) => FoodModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
            'Failed to load search suggestions: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logError('getSearchSuggestions', e, stack);
      rethrow;
    }
  }

  Future<List<RestaurantSearchResult>> searchRestaurantsByFood({
    required String query,
    double? latitude,
    double? longitude,
  }) async {
    try {
      if (query.trim().isEmpty) return [];

      final params = <String, String>{'q': query};
      if (latitude != null && longitude != null) {
        params['lat'] = latitude.toString();
        params['lng'] = longitude.toString();
      }

      final uri = Uri.parse('$baseUrl/search/restaurants')
          .replace(queryParameters: params);

      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list
            .map((e) =>
                RestaurantSearchResult.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
            'Failed to search restaurants: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stack) {
      _logError('searchRestaurantsByFood', e, stack);
      rethrow;
    }
  }

  Future<RestaurantDetailModel> getRestaurantDetail(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/restaurants/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return RestaurantDetailModel.fromJson(data);
      } else {
        throw Exception(
            'Failed to load restaurant details: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logError('getRestaurantDetail', e, stack);
      rethrow;
    }
  }

  Future<OrderModel> createOrder({
    required int restaurantId,
    required List<Map<String, dynamic>> items,
    String? deliveryAddress,
    String? paymentMethod,
    double? lat,
    double? lng,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'restaurant_id': restaurantId,
          'items': items,
          'address': deliveryAddress,
          'payment_method': paymentMethod,
          'lat': lat,
          'lng': lng,
        }),
      );

      if (response.statusCode == 201) {
        return OrderModel.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception(
            'Failed to create order: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stack) {
      _logError('createOrder', e, stack);
      rethrow;
    }
  }

  // --- REVIEW ENDPOINTS ---
  Future<List<OrderModel>> getMyOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/me'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to get my orders: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logError('getMyOrders', e, stack);
      rethrow;
    }
  }

  Future<List<OrderModel>> getAssignedOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/assigned'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
            'Failed to get assigned orders: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logError('getAssignedOrders', e, stack);
      rethrow;
    }
  }

  Future<List<OrderModel>> getAvailableOrders(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/available?lat=$lat&lng=$lng'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to get available orders: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logError('getAvailableOrders', e, stack);
      rethrow;
    }
  }

  Future<OrderModel> acceptOrder(int orderId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/accept'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to accept order: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stack) {
      _logError('acceptOrder', e, stack);
      rethrow;
    }
  }

  Future<OrderModel> updateShipperLocation(int orderId, double lat, double lng) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/location'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'lat': lat,
          'lng': lng,
        }),
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to update location: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stack) {
      _logError('updateShipperLocation', e, stack);
      rethrow;
    }
  }

  Future<List<OrderModel>> getAllOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to get all orders: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logError('getAllOrders', e, stack);
      rethrow;
    }
  }

  Future<OrderModel> updateOrderStatus(
    int orderId,
    String action, {
    int? shipperId,
  }) async {
    try {
      final body =
          shipperId != null ? jsonEncode({'shipper_id': shipperId}) : null;

      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/$action'),
        headers: await _getHeaders(),
        body: body,
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception(
            'Failed to $action order: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stack) {
      _logError('updateOrderStatus', e, stack);
      rethrow;
    }
  }

  Future<ShipperModel> registerShipper({
    required String phone,
    required String vehicleName,
    required String licensePlate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/shippers/register'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'phone': phone,
          'vehicle_name': vehicleName,
          'license_plate': licensePlate,
        }),
      );

      if (response.statusCode == 201) {
        return ShipperModel.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception(
            'Failed to register shipper: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stack) {
      _logError('registerShipper', e, stack);
      rethrow;
    }
  }

  Future<ShipperModel?> getMyShipper() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/shippers/me'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body == null || (body is Map && body.isEmpty)) return null;
        return ShipperModel.fromJson(body as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
            'Failed to get shipper profile: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logError('getMyShipper', e, stack);
      rethrow;
    }
  }

  Future<ShipperModel> updateMyShipper({
    String? phone,
    String? vehicleName,
    String? licensePlate,
    bool? isActive,
  }) async {
    try {
      final data = <String, dynamic>{
        if (phone != null) 'phone': phone,
        if (vehicleName != null) 'vehicle_name': vehicleName,
        if (licensePlate != null) 'license_plate': licensePlate,
        if (isActive != null) 'is_active': isActive,
      };

      final response = await http.patch(
        Uri.parse('$baseUrl/shippers/me'),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return ShipperModel.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception(
            'Failed to update shipper profile: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logError('updateMyShipper', e, stack);
      rethrow;
    }
  }

  Future<UserModel> createUser({
    required String uid,
    required String name,
    required String email,
    String? phone,
    String role = 'USER',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': uid,
          'name': name,
          'email': email,
          'phone': phone,
          'role': role,
        }),
      );

      if (response.statusCode == 201) {
        return UserModel.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception(
            'Failed to create user: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stack) {
      _logError('createUser', e, stack);
      rethrow;
    }
  }

  Future<UserModel> getUser(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to get user: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logError('getUser', e, stack);
      rethrow;
    }
  }

  Future<UserModel> updateUser(
    String uid, {
    String? name,
    String? email,
    String? phone,
    String? role,
  }) async {
    try {
      final data = <String, dynamic>{
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (role != null) 'role': role,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/user/$uid'),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to update user: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logError('updateUser', e, stack);
      rethrow;
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => CategoryModel.fromJson(json))
            .cast<CategoryModel>()
            .toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logError('getCategories', e, stack);
      rethrow;
    }
  }

  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/addresses'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list.map((e) => AddressModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load addresses: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logError('getAddresses', e, stack);
      rethrow;
    }
  }

  Future<AddressModel> addAddress({
    required String address,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addresses'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'is_default': isDefault,
        }),
      );

      if (response.statusCode == 201) {
        return AddressModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to add address: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logError('addAddress', e, stack);
      rethrow;
    }
  }

  Future<AddressModel> updateAddress(
    int addressId, {
    String? address,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/addresses/$addressId'),
        headers: await _getHeaders(),
        body: jsonEncode({
          if (address != null) 'address': address,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (isDefault != null) 'is_default': isDefault,
        }),
      );

      if (response.statusCode == 200) {
        return AddressModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update address: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logError('updateAddress', e, stack);
      rethrow;
    }
  }

  Future<List<PlaceResult>> searchAddresses(String query) async {
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5');
      final response = await http.get(url, headers: {
        'User-Agent': 'DeliveryApp/1.0 (Mobile App)',
      });
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((e) => PlaceResult.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to search addresses: ${response.statusCode}');
    } catch (e, stack) {
      _logError('searchAddresses', e, stack);
      rethrow;
    }
  }

  // Cart Methods
  Future<List<CartItem>> getCart() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cart'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list.map((e) => CartItem.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load cart: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logError('getCart', e, stack);
      rethrow;
    }
  }

  Future<void> addToCart(CartItem item) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cart'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'food_id': int.tryParse(item.productId) ?? 0,
          'quantity': int.tryParse(item.quantity) ?? 1,
          'selected_options':
              item.selectedOptions.map((o) => o.toJson()).toList(),
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final message = jsonDecode(response.body)['error'] ?? 'Unknown error';
        throw Exception('Failed to add to cart: $message');
      }
    } catch (e, stack) {
      _logError('addToCart', e, stack);
      rethrow;
    }
  }

  Future<void> updateCartItem(String cartItemId, String quantity) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/cart/$cartItemId/quantity'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'quantity': int.tryParse(quantity) ?? 1,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update cart item: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logError('updateCartItem', e, stack);
      rethrow;
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/cart/$cartItemId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to remove from cart: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logError('removeFromCart', e, stack);
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      final token = await _authRepo.getToken();
      if (token == null) throw Exception('Vui lòng đăng nhập');

      final response = await http.delete(
        Uri.parse('$baseUrl/cart'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Lỗi xoá giỏ hàng');
      }
    } catch (e, stack) {
      _logError('clearCart', e, stack);
      rethrow;
    }
  }

  Future<List<FoodModel>> getFavorites() async {
    try {
      final token = await _authRepo.getToken();
      if (token == null) throw Exception('Vui lòng đăng nhập');

      final response = await http.get(
        Uri.parse('$baseUrl/favorites'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((jsonItem) {
          final food = jsonItem['foods'];
          return FoodModel.fromJson(food);
        }).toList();
      } else {
        throw Exception('Lỗi lấy danh sách yêu thích');
      }
    } catch (e, stack) {
      _logError('getFavorites', e, stack);
      rethrow;
    }
  }

  Future<void> toggleFavorite(int foodId) async {
    try {
      final token = await _authRepo.getToken();
      if (token == null) throw Exception('Vui lòng đăng nhập');

      final response = await http.post(
        Uri.parse('$baseUrl/favorites/toggle'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'food_id': foodId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Lỗi cập nhật yêu thích');
      }
    } catch (e, stack) {
      _logError('toggleFavorite', e, stack);
      rethrow;
    }
  }

  Future<void> sendOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send OTP: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logError('sendOtp', e, stack);
      rethrow;
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body)['error'] ?? 'Invalid OTP';
        throw Exception(error);
      }
    } catch (e, stack) {
      _logError('verifyOtp', e, stack);
      rethrow;
    }
  }

  Future<void> registerRestaurant({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/restaurants/register'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'restaurant_name': name,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'phone': phone,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception(
            'Failed to register restaurant: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stack) {
      _logError('registerRestaurant', e, stack);
      rethrow;
    }
  }

  // Restaurant Specific Methods
  Future<List<OrderModel>> getRestaurantOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/restaurant'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to get restaurant orders: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logError('getRestaurantOrders', e, stack);
      rethrow;
    }
  }

  Future<RestaurantModel> getMyRestaurant() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/restaurants/me'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return RestaurantModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to get my restaurant profile: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logError('getMyRestaurantProfile', e, stack);
      rethrow;
    }
  }

  Future<RestaurantModel> updateRestaurantStatus(bool isOpen) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/restaurants/me/status'),
        headers: await _getHeaders(),
        body: jsonEncode({'is_open': isOpen}),
      );

      if (response.statusCode == 200) {
        return RestaurantModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to update restaurant status: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logError('updateRestaurantStatus', e, stack);
      rethrow;
    }
  }

  Future<RestaurantModel> updateRestaurantProfile({
    String? name,
    String? address,
    String? phone,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (name != null) data['restaurant_name'] = name;
      if (address != null) data['address'] = address;
      if (phone != null) data['phone'] = phone;
      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;

      final response = await http.patch(
        Uri.parse('$baseUrl/restaurants/me'),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return RestaurantModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to update restaurant profile: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logError('updateRestaurantProfile', e, stack);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createFood(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/foods'),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create food: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logError('createFood', e, stack);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateFood(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/foods/$id'),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update food: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logError('updateFood', e, stack);
      rethrow;
    }
  }

  Future<void> deleteFood(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/foods/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete food: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logError('deleteFood', e, stack);
      rethrow;
    }
  }
  Future<Map<String, dynamic>> getShipperDashboard() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/shippers/me/dashboard'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get dashboard data: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logError('getShipperDashboard', e, stack);
      rethrow;
    }
  }
}
