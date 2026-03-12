import 'dart:convert';
import 'package:delivery_apps/core/models/place_result.dart';
import 'package:delivery_apps/core/models/food_model.dart';
import 'package:delivery_apps/core/models/order_model.dart';
import 'package:delivery_apps/core/models/product.dart';
import 'package:delivery_apps/core/models/shipper_model.dart';
import 'package:delivery_apps/core/models/user_model.dart';
import 'package:delivery_apps/core/models/category_model.dart';
import 'package:delivery_apps/core/models/address_model.dart';
import 'package:delivery_apps/core/models/cart_item.dart';
import 'package:delivery_apps/core/services/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BackendService {
  static final BackendService _instance = BackendService._internal();

  factory BackendService() {
    return _instance;
  }

  BackendService._internal();

  static const String baseUrl = 'http://192.168.1.82:3000/api';

  final _authRepo = AuthRepository();


  Future<Map<String, String>> _getHeaders() async {
    final token = await _authRepo.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }


  Future<UserModel> login(String email, String password) async {
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
      throw Exception('Failed to login: ${response.statusCode} - ${response.body}');
    }
  }

  Future<UserModel> getMe() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to get user profile: ${response.statusCode}');
    }
  }


  Future<List<FoodModel>> getFoods({String? categoryId}) async {
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
  }


  Future<OrderModel> createOrder({
    required int restaurantId,
    required List<Map<String, int>> items, 
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'restaurant_id': restaurantId,
        'items': items,
      }),
    );

    if (response.statusCode == 201) {
      return OrderModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create order: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<OrderModel>> getMyOrders() async {
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
  }

  Future<List<OrderModel>> getAssignedOrders() async {
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
      throw Exception('Failed to get assigned orders: ${response.statusCode}');
    }
  }

  Future<List<OrderModel>> getAllOrders() async {
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
  }


  Future<OrderModel> updateOrderStatus(
    int orderId,
    String action, {
    int? shipperId,
  }) async {
    final body = shipperId != null ? jsonEncode({'shipper_id': shipperId}) : null;

    final response = await http.patch(
      Uri.parse('$baseUrl/orders/$orderId/$action'),
      headers: await _getHeaders(),
      body: body,
    );

    if (response.statusCode == 200) {
      return OrderModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to $action order: ${response.statusCode} - ${response.body}');
    }
  }


  Future<ShipperModel> registerShipper({
    required String phone,
    required String vehicleName,
    required String licensePlate,
  }) async {
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
      return ShipperModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to register shipper: ${response.statusCode} - ${response.body}');
    }
  }

  Future<ShipperModel?> getMyShipper() async {
    final response = await http.get(
      Uri.parse('$baseUrl/shippers/me'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body == null || (body is Map && body.isEmpty)) return null;
      return ShipperModel.fromJson(body as Map<String, dynamic>);
    } else if (response.statusCode == 404) {
      return null; // Chưa đăng ký shipper
    } else {
      throw Exception('Failed to get shipper profile: ${response.statusCode}');
    }
  }

  Future<ShipperModel> updateMyShipper({
    String? phone,
    String? vehicleName,
    String? licensePlate,
    bool? isActive,
  }) async {
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
      return ShipperModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update shipper profile: ${response.statusCode}');
    }
  }

  Future<UserModel> createUser({
    required String uid,
    required String name,
    required String email,
    String? phone,
    String role = 'USER',
  }) async {
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
      return UserModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create user: ${response.statusCode} - ${response.body}');
    }
  }

  Future<UserModel> getUser(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to get user: ${response.statusCode}');
    }
  }

  Future<UserModel> updateUser(
    int id, {
    String? name,
    String? email,
    String? phone,
    String? role,
  }) async {
    final data = <String, dynamic>{
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (role != null) 'role': role,
    };

    final response = await http.put(
      Uri.parse('$baseUrl/user/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update user: ${response.statusCode}');
    }
  }

  Future<List<CategoryModel>> getCategories() async {
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
  }

  // Address Methods
  Future<List<AddressModel>> getAddresses() async {
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
  }

  Future<AddressModel> addAddress({
    required String address,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
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
  }

  Future<AddressModel> updateAddress(
    int addressId, {
    String? address,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) async {
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
  }

  Future<List<PlaceResult>> searchAddresses(String query) async {
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
  }

  // Cart Methods
  Future<List<CartItem>> getCart() async {
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
  }

  Future<void> addToCart(CartItem item) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cart'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'food_id': int.tryParse(item.productId) ?? 0,
        'quantity': int.tryParse(item.quantity) ?? 1,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final message = jsonDecode(response.body)['error'] ?? 'Unknown error';
      throw Exception('Failed to add to cart: $message');
    }
  }

  Future<void> updateCartItem(String cartItemId, String quantity) async {
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
  }

  Future<void> removeFromCart(String cartItemId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/cart/$cartItemId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove from cart: ${response.statusCode}');
    }
  }

  Future<void> clearCart() async {
    final token = await _authRepo.getToken();
    if (token == null) throw Exception('Vui lòng đăng nhập');

    final response = await http.delete(
      Uri.parse('$baseUrl/cart'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Lỗi xoá giỏ hàng');
    }
  }

  Future<List<Product>> getFavorites() async {
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
        return Product.fromJson({
          'id': food['id'],
          'name': food['name'],
          'image_url': food['image_url'] ?? '',
          'price': food['price'],
          'description': food['description'] ?? '',
          'restaurant_id': food['restaurant_id'],
        });
      }).toList();
    } else {
      throw Exception('Lỗi lấy danh sách yêu thích');
    }
  }

  Future<void> toggleFavorite(int foodId) async {
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
  }
}
