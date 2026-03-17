import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderTrackingMap extends StatefulWidget {
  final double restaurantLat;
  final double restaurantLng;
  final double? deliveryLat;
  final double? deliveryLng;
  final double? shipperLat;
  final double? shipperLng;
  final bool isDelivering;

  const OrderTrackingMap({
    super.key,
    required this.restaurantLat,
    required this.restaurantLng,
    this.deliveryLat,
    this.deliveryLng,
    this.shipperLat,
    this.shipperLng,
    this.isDelivering = false,
  });

  @override
  State<OrderTrackingMap> createState() => _OrderTrackingMapState();
}

class _OrderTrackingMapState extends State<OrderTrackingMap> {
  List<LatLng> _routePoints = [];
  bool _isLoadingRoute = false;

  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  @override
  void didUpdateWidget(OrderTrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.restaurantLat != widget.restaurantLat ||
        oldWidget.deliveryLat != widget.deliveryLat) {
      _fetchRoute();
    }
  }

  Future<void> _fetchRoute() async {
    final destLat = widget.deliveryLat;
    final destLng = widget.deliveryLng;
    
    if (destLat == null || destLng == null) return;

    setState(() => _isLoadingRoute = true);

    try {
      final url = 'https://router.project-osrm.org/route/v1/driving/'
          '${widget.restaurantLng},${widget.restaurantLat};$destLng,$destLat'
          '?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coordinates = data['routes'][0]['geometry']['coordinates'] as List;
        
        setState(() {
          _routePoints = coordinates
              .map((coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
              .toList();
          _isLoadingRoute = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching route: $e');
      setState(() => _isLoadingRoute = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final destLat = widget.deliveryLat ?? widget.restaurantLat;
    final destLng = widget.deliveryLng ?? widget.restaurantLng;
    
    final sLat = widget.restaurantLat;
    final sLng = widget.restaurantLng;

    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng((widget.restaurantLat + destLat) / 2, (widget.restaurantLng + destLng) / 2),
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.nguyencongan.delivery_apps',
              ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: AppColor.primary(context),
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(widget.restaurantLat, widget.restaurantLng),
                    width: 40,
                    height: 40,
                    child: _buildMarker(Icons.restaurant, AppColor.primary(context)),
                  ),
                  if (widget.deliveryLat != null)
                    Marker(
                      point: LatLng(destLat, destLng),
                      width: 45,
                      height: 45,
                      child: _buildMarker(Icons.person_pin_circle, Colors.blue, isUser: true),
                    ),
                  if (widget.isDelivering)
                    Marker(
                      point: LatLng(sLat, sLng),
                      width: 40,
                      height: 40,
                      child: _buildMarker(Icons.delivery_dining, Colors.orange),
                    ),
                ],
              ),
            ],
          ),
          if (_isLoadingRoute)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildMarker(IconData icon, Color color, {bool isUser = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          )
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: isUser ? 24 : 20),
      ),
    );
  }
}
