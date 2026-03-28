import 'package:delivery_apps/core/models/order_model.dart';
import 'package:delivery_apps/core/services/supabase_service.dart';
import 'package:flutter/foundation.dart';

class OrderRealtimeProvider with ChangeNotifier {
  final List<OrderModel> _orders = [];
  Map<String, dynamic>? _latestPayload;

  // Reference counter — channel stays open while any subscriber is active.
  int _refCount = 0;

  List<OrderModel> get orders => List.unmodifiable(_orders);
  Map<String, dynamic>? get latestPayload => _latestPayload;
  bool get isSubscribed => _refCount > 0;

  void subscribe() {
    _refCount++;
    if (_refCount == 1) {
      SupabaseService.subscribeOrders(onPayload: _handlePayload);
      debugPrint('[OrderRealtime] channel opened (refCount=$_refCount)');
    } else {
      debugPrint('[OrderRealtime] reused channel (refCount=$_refCount)');
    }
  }

  Future<void> unsubscribe() async {
    if (_refCount <= 0) return;
    _refCount--;
    debugPrint('[OrderRealtime] unsubscribe (refCount=$_refCount)');
    if (_refCount == 0) {
      await SupabaseService.unsubscribeOrders();
      debugPrint('[OrderRealtime] channel closed');
    }
  }

  void _handlePayload(Map<String, dynamic> payload) {
    debugPrint('\n=====================================');
    debugPrint('[OrderRealtime] payload: ${payload}');
    
    final eventType = payload['eventType'] as String?;
    final newRecord = payload['new'] as Map<String, dynamic>? ?? {};
    final oldRecord = payload['old'] as Map<String, dynamic>? ?? {};

    _latestPayload = newRecord.isNotEmpty ? newRecord : oldRecord;

    try {
      if (eventType == 'delete' && oldRecord.isNotEmpty) {
        final deletedId = oldRecord['id'];
        _orders.removeWhere((o) => o.id == deletedId);
      } else if (newRecord.isNotEmpty) {
        final order = OrderModel.fromJson(newRecord);
        final idx = _orders.indexWhere((o) => o.id == order.id);
        if (idx != -1) {
          _orders[idx] = order;
        } else {
          _orders.insert(0, order);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[OrderRealtime] Parse error: $e');
      }
    }
    notifyListeners();
  }

  void seedOrders(List<OrderModel> initial) {
    _orders
      ..clear()
      ..addAll(initial);
    notifyListeners();
  }

  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }
}
