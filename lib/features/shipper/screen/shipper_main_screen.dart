import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/user_model.dart';
import 'package:delivery_apps/features/shipper/screen/shipper_home_screen.dart';
import 'package:delivery_apps/features/user/profile/screen/login_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      const ShipperHomeScreen(),
      const _ShipperActiveScreen(),
      const _ShipperHistoryScreen(),
      _ShipperProfileScreen(user: widget.user),
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
            _buildNavItem(Icons.person_outline, 3),
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

// Scaffold screens for future implementation
class _ShipperActiveScreen extends StatelessWidget {
  const _ShipperActiveScreen();

  @override
  Widget build(BuildContext context) {
    return const _ShipperPlaceholderScreen(
      icon: Icons.delivery_dining,
      title: 'Active Delivery',
      message: 'No active delivery right now.',
    );
  }
}

class _ShipperHistoryScreen extends StatelessWidget {
  const _ShipperHistoryScreen();

  @override
  Widget build(BuildContext context) {
    return const _ShipperPlaceholderScreen(
      icon: Icons.history,
      title: 'Delivery History',
      message: 'Your completed deliveries will appear here.',
    );
  }
}

class _ShipperProfileScreen extends StatelessWidget {
  final UserModel user;
  const _ShipperProfileScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.inputFill(context),
      appBar: AppBar(
        backgroundColor: AppColor.container(context),
        title: const Text('Profile'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: AppColor.primary(context)),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginView()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColor.primary(context).withOpacity(0.1),
              child: Icon(Icons.delivery_dining, size: 50, color: AppColor.primary(context)),
            ),
            const SizedBox(height: 16),
            Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(user.email, style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

class _ShipperPlaceholderScreen extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const _ShipperPlaceholderScreen({required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.inputFill(context),
      appBar: AppBar(
        backgroundColor: AppColor.container(context),
        title: Text(title),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 70, color: AppColor.textSecondary(context).withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(message, style: TextStyle(color: AppColor.textSecondary(context))),
          ],
        ),
      ),
    );
  }
}
