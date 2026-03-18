import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/user_model.dart';
import 'package:delivery_apps/features/restaurant/screen/restaurant_home_screen.dart';
import 'package:delivery_apps/features/restaurant/screen/restaurant_menu_screen.dart';
import 'package:delivery_apps/features/restaurant/screen/restaurant_orders_screen.dart';
import 'package:delivery_apps/features/restaurant/screen/restaurant_profile_screen.dart';
import 'package:delivery_apps/features/restaurant/screen/restaurant_sales_screen.dart';
import 'package:flutter/material.dart';

class RestaurantMainScreen extends StatefulWidget {
  final UserModel user;
  const RestaurantMainScreen({super.key, required this.user});

  @override
  State<RestaurantMainScreen> createState() => _RestaurantMainScreenState();
}

class _RestaurantMainScreenState extends State<RestaurantMainScreen> {
  int _currentIndex = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavKey = GlobalKey();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const RestaurantHomeScreen(),
      const RestaurantMenuScreen(),
      const RestaurantOrdersScreen(),
      const RestaurantSalesScreen(),
      RestaurantProfileScreen(user: widget.user),
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
            _buildNavItem(Icons.menu_book_outlined, 1),
            _buildNavItem(Icons.list_alt_outlined, 2),
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
      child: Icon(
        icon,
        color: isSelected ? Colors.white : AppColor.textSecondary(context),
        size: 30,
      ),
    );
  }
}
