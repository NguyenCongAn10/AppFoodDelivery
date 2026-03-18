import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/features/user/cart/screen/cart_screen.dart';
import 'package:delivery_apps/features/user/favorites/screen/favourite_screen.dart';
import 'package:delivery_apps/features/user/home/screen/home_screen.dart';
import 'package:delivery_apps/features/user/order/screen/order_screen.dart';
import 'package:delivery_apps/features/user/profile/screen/profile_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int currentIndex;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  void _goToHome() {
    setState(() => currentIndex = 0);
    // Add null check and properly update curved navigation bar's visual state
    final navState = _bottomNavigationKey.currentState;
    if (navState != null) {
      navState.setPage(0);
    }
  }

  List<Widget> get _pages => [
        const HomeScreen(),
        CartScreen(onBackToHome: _goToHome),
        FavouriteScreen(onBackToHome: _goToHome),
        OrderScreen(onBackToHome: _goToHome),
        const ProfileScreen(),
      ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && currentIndex != 0) {
          _goToHome();
        }
      },
      child: Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: currentIndex,
        items: [
            _buildNavItem(context, Icons.home_outlined, 0),
            _buildNavItem(context, Icons.shopping_cart_outlined, 1),
            _buildNavItem(context, Icons.favorite_outline, 2),
            _buildNavItem(context, Icons.list_alt_outlined, 3),
            _buildNavItem(context, Icons.person_outline, 4),
        ],
        backgroundColor: AppColor.inputFill(context),
        color: AppColor.container(context),
        animationDuration: const Duration(milliseconds: 500),
          onTap: (int index) => setState(() => currentIndex = index),
        height: 65,
      ),
        body: IndexedStack(
          index: currentIndex,
          children: _pages,
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, int index) {
    final isSelected = currentIndex == index;
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
