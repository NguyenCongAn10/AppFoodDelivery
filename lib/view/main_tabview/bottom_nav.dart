import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:delivery_apps/common/color_extention.dart';
import 'package:delivery_apps/view/main_tabview/cart_screen.dart';
import 'package:delivery_apps/view/main_tabview/favourite_screen.dart';
import 'package:delivery_apps/view/main_tabview/home_screen.dart';
import 'package:delivery_apps/view/main_tabview/wallet_screen.dart';
import 'package:delivery_apps/view/main_tabview/profile_screen.dart';
import 'package:flutter/material.dart';

class ButtomNavigation extends StatefulWidget {
  final int initialIndex;
  const ButtomNavigation({super.key, this.initialIndex = 0});

  @override
  State<ButtomNavigation> createState() => _ButtomNavigationState();
}

class _ButtomNavigationState extends State<ButtomNavigation> {
  late int currentIndex;
  late List<Widget> page;
  late Widget currentPage;
  late HomeScreen homeScreen;
  late CartScreen cartScreen;
  late FavouriteScreen favouriteScreen;
  late WalletScreen walletScreen;
  late ProfileScreen profileScreen;

  @override
  void initState() {
    currentIndex = widget.initialIndex;
    homeScreen = HomeScreen();
    cartScreen = CartScreen();
    favouriteScreen = FavouriteScreen();
    walletScreen = WalletScreen();
    profileScreen = ProfileScreen();
    page = [
      homeScreen,
      cartScreen,
      favouriteScreen,
      walletScreen,
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
          _buildNavItem(Icons.account_balance_wallet_outlined, 3,
              highlightColor: TColor.main),
          _buildNavItem(Icons.person_outline, 4, highlightColor: TColor.main),
        ],
        backgroundColor: Colors.white,
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
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? highlightColor : Colors.transparent,
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.black87,
        size: 30,
      ),
    );
  }
}
