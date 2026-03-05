import 'dart:convert';
import 'package:delivery_apps/core/models/food_model.dart';
import 'package:delivery_apps/core/models/order_model.dart';
import 'package:delivery_apps/core/models/shipper_model.dart';
import 'package:delivery_apps/core/models/user_model.dart';
import 'package:delivery_apps/core/services/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BackendService {
  static final BackendService _instance = BackendService._internal();

  factory BackendService() {
    return _instance;
  }

  BackendService._internal();

  static const String baseUrl = 'http://192.168.1.9:3000/api';

  final _authRepo = AuthRepository();

  // ─── Headers ─────────────────────────────────────────────────────────────

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


  Future<List<FoodModel>> getFoods() async {
    final response = await http.get(
      Uri.parse('$baseUrl/foods'),
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

  /// Cập nhật thông tin shipper → ShipperModel
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
}
