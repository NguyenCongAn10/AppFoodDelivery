import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:delivery_apps/common/color_extention.dart';
import 'package:delivery_apps/view/home/cart_screen.dart';
import 'package:delivery_apps/view/home/favourite_screen.dart';
import 'package:delivery_apps/view/home/home_screen.dart';
import 'package:delivery_apps/view/home/orders_screen.dart';
import 'package:delivery_apps/view/home/profile_screen.dart';
import 'package:flutter/material.dart';

class ButtomNavigation extends StatefulWidget {
  const ButtomNavigation({super.key});

  @override
  State<ButtomNavigation> createState() => _ButtomNavigationState();
}

class _ButtomNavigationState extends State<ButtomNavigation> {
  int currentIndex = 0;
  late List<Widget> page;
  late Widget currentPage;
  late HomeScreen homeScreen;
  late CartScreen cartScreen;
  late FavouriteScreen favouriteScreen;
  late OrdersScreen ordersScreen;
  late ProfileScreen profileScreen;

  @override
  void initState() {
    homeScreen = HomeScreen();
    cartScreen = CartScreen();
    favouriteScreen = FavouriteScreen();
    ordersScreen = OrdersScreen();
    profileScreen = ProfileScreen();
    page = [
      homeScreen,
      cartScreen,
      favouriteScreen,
      ordersScreen,
      profileScreen
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        items: [
          _buildNavItem(Icons.home_outlined, 0, highlightColor: TColor.main),
          _buildNavItem(Icons.shopping_cart_outlined, 1,
              highlightColor: TColor.main),
          _buildNavItem(Icons.favorite_outline, 2, highlightColor: TColor.main),
          _buildNavItem(Icons.list_alt, 3, highlightColor: TColor.main),
          _buildNavItem(Icons.person, 4, highlightColor: TColor.main),
        ],
        backgroundColor: Colors.transparent,
        color: TColor.textfield,
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

  Widget _buildNavItem(IconData icon, int index,
      {Color highlightColor = Colors.blue}) {
    bool isSelected = currentIndex == index;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? highlightColor
            : Colors.transparent,
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.black87,

        size: 28,
      ),
    );
  }
}
