import 'package:another_flushbar/flushbar.dart';
import 'package:delivery_apps/core/models/order_model.dart';
import 'package:delivery_apps/core/models/user_model.dart';
import 'package:delivery_apps/core/providers/order_realtime_provider.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/features/user/order/screen/order_detail_screen.dart';
import 'package:delivery_apps/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class GlobalOrderNotification extends StatefulWidget {
  final Widget child;
  const GlobalOrderNotification({super.key, required this.child});

  @override
  State<GlobalOrderNotification> createState() => _GlobalOrderNotificationState();
}

class _GlobalOrderNotificationState extends State<GlobalOrderNotification> {
  Map<String, dynamic>? _lastPayload;
  late OrderRealtimeProvider _realtimeProvider;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _realtimeProvider = context.read<OrderRealtimeProvider>();
      _realtimeProvider.subscribe();
    });
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final user = await BackendService().getMe();
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('No logged-in user found for Flushbar: $e');
      }
    }
  }

  @override
  void dispose() {
    _realtimeProvider.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final payload = context.select<OrderRealtimeProvider, Map<String, dynamic>?>(
      (p) => p.latestPayload,
    );

    if (payload != null && payload != _lastPayload) {
      _lastPayload = payload;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showRoleBasedFlushbar(payload);
      });
    }

    return widget.child;
  }

  void _showRoleBasedFlushbar(Map<String, dynamic> payload) {
    // Only process payloads that contain basic order info
    if (!payload.containsKey('status') || _currentUser == null) return;

    OrderModel order;
    try {
      order = OrderModel.fromJson(payload);
    } catch (_) {
      return;
    }

    final navContext = globalNavigatorKey.currentContext;
    if (navContext == null) return;

    final role = _currentUser!.role;
    
    String title = 'Order #${order.id} Updated';
    String message = 'Status: ${order.status?.name ?? 'UNKNOWN'}';
    Widget? mainButton;
    Widget icon = Icon(Icons.info_outline, color: Theme.of(navContext).colorScheme.primary);
    OnTap? onTap;

    Flushbar? flushbar;

    if (role == UserRole.USER) {
      icon = Icon(Icons.shopping_bag, color: Theme.of(navContext).colorScheme.primary);
      onTap = (bar) {
        bar.dismiss();
        Navigator.push(
          navContext,
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(order: order),
          ),
        );
      };
    } else if (role == UserRole.SHIPPER || role == UserRole.RESTAURANT) {
      title = role == UserRole.SHIPPER ? 'New Delivery Request!' : 'New Order Received!';
      message = 'Order #${order.id} • \$${order.totalPrice}';
      icon = Icon(
        role == UserRole.SHIPPER ? Icons.delivery_dining : Icons.restaurant, 
        color: Theme.of(navContext).colorScheme.secondary,
      );
      
      mainButton = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () => flushbar?.dismiss(),
            child: Text('Ignore', style: TextStyle(color: Theme.of(navContext).colorScheme.onSurface.withValues(alpha: 0.6))),
          ),
          TextButton(
            onPressed: () async {
              flushbar?.dismiss();
              try {
                if (role == UserRole.SHIPPER) {
                  await BackendService().acceptOrder(order.id);
                } else {
                  await BackendService().updateOrderStatus(order.id, 'confirm');
                }
              } catch (e) {
                if (kDebugMode) {
                  debugPrint('Action Failed: $e');
                }
              }
            },
            child: Text('Accept', style: TextStyle(color: Theme.of(navContext).colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    }

    final textColor = Theme.of(navContext).colorScheme.onSurface;

    flushbar = Flushbar(
      titleText: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 16)),
      messageText: Text(message, style: TextStyle(color: textColor.withValues(alpha: 0.8), fontSize: 14)),
      icon: icon,
      mainButton: mainButton,
      onTap: onTap,
      duration: const Duration(seconds: 4),
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: Theme.of(navContext).cardColor,
      boxShadows: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.1), offset: const Offset(0, 4), blurRadius: 10),
      ],
    );

    flushbar.show(navContext);
  }
}
