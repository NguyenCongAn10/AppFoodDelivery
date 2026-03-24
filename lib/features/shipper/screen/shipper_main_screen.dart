import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/user_model.dart';
import 'package:delivery_apps/features/shipper/screen/shipper_home_screen.dart';
import 'package:delivery_apps/features/shipper/screen/shipper_active_screen.dart';
import 'package:delivery_apps/features/shipper/screen/shipper_history_screen.dart';
import 'package:delivery_apps/features/shipper/screen/shipper_dashboard_screen.dart';
import 'package:delivery_apps/features/shipper/screen/shipper_profile_screen.dart';
import 'package:flutter/material.dart';

class ShipperMainScreen extends StatefulWidget {
  final UserModel user;
  const ShipperMainScreen({super.key, required this.user});

  @override
  State<ShipperMainScreen> createState() => _ShipperMainScreenState();
}

class _ShipperMainScreenState extends State<ShipperMainScreen> {
  int _currentIndex = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavKey = GlobalKey();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ShipperHomeScreen(
        onAcceptOrder: () {
           // Chuyển sang tab Đang giao khi nhận đơn thành công
           setState(() => _currentIndex = 1);
           _bottomNavKey.currentState?.setPage(1);
        },
      ),
      const ShipperActiveScreen(),
      const ShipperHistoryScreen(),
      const ShipperDashboardScreen(),
      ShipperProfileScreen(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentIndex != 0) {
          setState(() => _currentIndex = 0);
          _bottomNavKey.currentState?.setPage(0);
        }
      },
      child: Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavKey,
          index: _currentIndex,
          items: [
            _buildNavItem(Icons.home_outlined, 0),
            _buildNavItem(Icons.delivery_dining_outlined, 1),
            _buildNavItem(Icons.history_outlined, 2),
            _buildNavItem(Icons.bar_chart_outlined, 3),
            _buildNavItem(Icons.person_outline, 4),
          ],
          backgroundColor: AppColor.inputFill(context),
          color: AppColor.container(context),
          animationDuration: const Duration(milliseconds: 500),
          onTap: (index) => setState(() => _currentIndex = index),
          height: 65,
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _currentIndex == index;
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColor.primary(context) : Colors.transparent,
      ),
      child: Icon(icon, color: isSelected ? Colors.white : AppColor.textSecondary(context), size: 30),
    );
  }
}

