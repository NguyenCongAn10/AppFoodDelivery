import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/features/cart/screen/cart_screen.dart';
import 'package:delivery_apps/features/favorites/screen/favourite_screen.dart';
import 'package:delivery_apps/features/home/screen/home_screen.dart';
import 'package:delivery_apps/features/order/screen/order_screen.dart';
import 'package:delivery_apps/features/profile/screen/profile_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int currentIndex;
  late List<Widget> page;
  late Widget currentPage;
  late HomeScreen homeScreen;
  late CartScreen cartScreen;
  late FavouriteScreen favouriteScreen;
  late OrderScreen orderScreen;
  late ProfileScreen profileScreen;

  @override
  void initState() {
    currentIndex = widget.initialIndex;
    homeScreen = HomeScreen();
    cartScreen = CartScreen();
    favouriteScreen = FavouriteScreen();
    orderScreen = OrderScreen();
    profileScreen = ProfileScreen();
    page = [
      homeScreen,
      cartScreen,
      favouriteScreen,
      orderScreen,
      profileScreen
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        items: [
          _buildNavItem(context, Icons.home_outlined, 0, highlightColor: AppColor.primary(context)),
          _buildNavItem(context, Icons.shopping_cart_outlined, 1,
              highlightColor: AppColor.primary(context)),
          _buildNavItem(context, Icons.favorite_outline, 2, highlightColor: AppColor.primary(context)),
          _buildNavItem(context, Icons.list_alt_outlined, 3,
              highlightColor: AppColor.primary(context)),
          _buildNavItem(context, Icons.person_outline, 4, highlightColor: AppColor.primary(context)),
        ],
        backgroundColor: AppColor.inputFill(context),
        color: AppColor.container(context),
        animationDuration: const Duration(milliseconds: 500),
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        height: 65,
      ),
      body: page[currentIndex],
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, int index,
      {Color highlightColor = Colors.blue}) {
    bool isSelected = currentIndex == index;
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? highlightColor : Colors.transparent,
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : AppColor.textSecondary(context),
        size: 30,
      ),
    );
  }
}
