import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/order_model.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class ShipperMapScreen extends StatefulWidget {
  final OrderModel order;
  const ShipperMapScreen({super.key, required this.order});

  @override
  State<ShipperMapScreen> createState() => _ShipperMapScreenState();
}

class _ShipperMapScreenState extends State<ShipperMapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentShipperPos;
  late final LatLng _restaurantPos;
  late final LatLng _customerPos;
  StreamSubscription<Position>? _positionStream;
  List<LatLng> _routePoints = [];
  bool _isFetchingRoute = false;
  late OrderStatus _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status;
    
    // Fallback tọa độ nếu thiếu
    _restaurantPos = LatLng(
      widget.order.restaurant?.latitude ?? 10.762622, 
      widget.order.restaurant?.longitude ?? 106.660172
    );
    
    _customerPos = LatLng(
      widget.order.deliveryLat ?? 10.776889, 
      widget.order.deliveryLng ?? 106.700806
    );

    _initLocationTracking();
  }

  Future<void> _initLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    // Lấy vị trí ngay hiện tại
    Position pos = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
    setState(() {
      _currentShipperPos = LatLng(pos.latitude, pos.longitude);
    });

    await _fetchRoute();

    // Lắng nghe thay đổi vị trí
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 10),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentShipperPos = LatLng(position.latitude, position.longitude);
        });
        
        // Push vị trí mới lên backend updateShipperLocation
        BackendService().updateShipperLocation(
          widget.order.id, 
          position.latitude, 
          position.longitude
        ).catchError((e) {
          debugPrint("Lỗi update vị trí lùi: $e");
        });
      }
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  void _centerMap(LatLng position) {
    if (mounted) {
      _mapController.move(position, 15.0);
    }
  }

  Future<void> _fetchRoute() async {
    if (_currentShipperPos == null) return;
    setState(() => _isFetchingRoute = true);
    try {
      final isConfirmed = _currentStatus == OrderStatus.CONFIRMED;
      final destination = isConfirmed ? _restaurantPos : _customerPos;

      final url = 'http://router.project-osrm.org/route/v1/driving/${_currentShipperPos!.longitude},${_currentShipperPos!.latitude};${destination.longitude},${destination.latitude}?geometries=geojson';
      final resp = await http.get(Uri.parse(url));
      
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final coords = data['routes'][0]['geometry']['coordinates'] as List;
        if (mounted) {
          setState(() {
            _routePoints = coords.map((c) => LatLng(c[1] as double, c[0] as double)).toList();
          });
        }
      } else {
        throw Exception('Failed to load route');
      }
    } catch (e) {
      debugPrint('Route error: $e');
      if (mounted) {
        setState(() {
          final isConfirmed = _currentStatus == OrderStatus.CONFIRMED;
          _routePoints = [_currentShipperPos!, isConfirmed ? _restaurantPos : _customerPos];
        });
      }
    } finally {
      if (mounted) setState(() => _isFetchingRoute = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Navigation', style: AppTextStyle.bodyBold(context, fontSize: 18, color: Colors.white)),
        backgroundColor: AppColor.primary(context),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          _currentShipperPos == null
            ? const Center(child: CircularProgressIndicator())
            : FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentShipperPos!,
                  initialZoom: 14.5,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.delivery.shipper',
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        color: AppColor.primary(context),
                        strokeWidth: 5.0,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      // Shipper
                      Marker(
                        point: _currentShipperPos!,
                        width: 50,
                        height: 50,
                        child: _buildMarkerIcon(Icons.two_wheeler, Colors.blue, 'You'),
                      ),
                      // Nhà hàng
                      Marker(
                        point: _restaurantPos,
                        width: 50,
                        height: 50,
                        child: _buildMarkerIcon(Icons.storefront, Colors.orange, 'Pickup'),
                      ),
                      // Khách
                      Marker(
                        point: _customerPos,
                        width: 50,
                        height: 50,
                        child: _buildMarkerIcon(Icons.person_pin_circle, Colors.red, 'Deliver To'),
                      ),
                    ],
                  ),
                ],
              ),
          
          // Nút điều khiển map
          Positioned(
            right: 16,
            top: 20,
            child: Column(
              children: [
                _MapButton(
                  icon: Icons.my_location, 
                  onTap: () => _currentShipperPos != null ? _centerMap(_currentShipperPos!) : null
                ),
                const SizedBox(height: 10),
                _MapButton(icon: Icons.storefront, onTap: () => _centerMap(_restaurantPos)),
                const SizedBox(height: 10),
                _MapButton(icon: Icons.person, onTap: () => _centerMap(_customerPos)),
              ],
            ),
          ),

          // Bottom Sheet info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColor.container(context),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -5))
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: AppColor.primary(context).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text('#${widget.order.id.toString().padLeft(4, '0')}', style: AppTextStyle.bodyBold(context, color: AppColor.primary(context), fontSize: 13)),
                        ),
                        const Spacer(),
                        Text(widget.order.paymentMethod?.toLowerCase() == 'cash' ? 'Collect: ${widget.order.totalPrice.toStringAsFixed(0)} VND' : 'Paid',
                          style: AppTextStyle.bodyBold(context, color: widget.order.paymentMethod?.toLowerCase() == 'cash' ? Colors.red : Colors.green, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         const Icon(Icons.location_on, color: Colors.red),
                         const SizedBox(width: 10),
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text('Deliver to: ${widget.order.user?.name ?? 'Customer'}', style: AppTextStyle.bodyBold(context, fontSize: 15)),
                               const SizedBox(height: 4),
                               Text(widget.order.deliveryAddress ?? '', style: AppTextStyle.body(context, color: AppColor.textSecondary(context), fontSize: 13)),
                             ],
                           ),
                         )
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentStatus == OrderStatus.CONFIRMED ? Colors.orange : Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                        ),
                        onPressed: () async {
                           showDialog(
                             context: context,
                             barrierDismissible: false,
                             builder: (_) => const Center(child: CircularProgressIndicator()),
                           );
                           try {
                             if (_currentStatus == OrderStatus.CONFIRMED) {
                               await BackendService().updateOrderStatus(widget.order.id, 'pickup');
                               if (mounted) {
                                 Navigator.pop(context); // close loading dialog
                                 setState(() {
                                   _currentStatus = OrderStatus.DELIVERING;
                                 });
                                 _fetchRoute(); // Redraw route immediately without closing map
                               }
                             } else {
                               await BackendService().updateOrderStatus(widget.order.id, 'complete');
                               if (mounted) {
                                 Navigator.pop(context); // close loading
                                 Navigator.pop(context); // close map screen finally
                               }
                             }
                           } catch (e) {
                             if (mounted) {
                               Navigator.pop(context);
                               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                             }
                           }
                        }, 
                        child: Text(
                          _currentStatus == OrderStatus.CONFIRMED ? 'START DELIVERY' : 'COMPLETE ORDER', 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMarkerIcon(IconData icon, Color bg, String label) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))]
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      ],
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  
  const _MapButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))]
        ),
        child: Icon(icon, color: AppColor.primary(context)),
      ),
    );
  }
}
