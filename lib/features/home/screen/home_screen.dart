import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/features/home/providers/user_address_provider.dart';
import 'package:delivery_apps/features/home/screen/user_address_screen.dart';
import 'package:delivery_apps/features/home/widget/banner_slider.dart';
import 'package:delivery_apps/features/home/screen/product_home.dart';
import 'package:delivery_apps/features/home/screen/search_screen.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Seed provider with backend default address if not already set
    WidgetsBinding.instance.addPostFrameCallback((_) => _initAddress());
  }

  Future<void> _initAddress() async {
    final provider = context.read<UserAddressProvider>();
    if (provider.selectedAddress != null) return;
    try {
      final addresses = await BackendService().getAddresses();
      final defaultAddr = addresses.where((e) => e.isDefault).firstOrNull;
      if (defaultAddr != null && mounted) {
        provider.selectAddress(defaultAddr);
      }
    } catch (e) {
      debugPrint('Error fetching addresses: $e');
    }
  }

  void _openAddressScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ChangeAddressScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final address = context.watch<UserAddressProvider>().selectedAddress;
    return Scaffold(
      backgroundColor: AppColor.inputFill(context),
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: AppColor.inputFill(context),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.container(context),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on_rounded, color: Colors.red),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Delivering to", style: AppTextStyle.body(context)),
            GestureDetector(
              onTap: () => _openAddressScreen(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      address?.address ?? 'Select Address',
                      style: AppTextStyle.bodyBold(context,
                          color: AppColor.primary(context), fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down,
                      size: 20, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
        titleSpacing: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications,
              color: AppColor.textTitle(context),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SearchScreen()));
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColor.container(context),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: AppColor.textTitle(context)),
                    const SizedBox(width: 10),
                    Text(
                      "Search your food",
                      style: AppTextStyle.body(context,
                          color: AppColor.textSecondary(context)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            BannerSlider(),
            const SizedBox(height: 10),
            Row(
              children: [
                Text("Categories",
                    style: AppTextStyle.bodyBold(context,
                        color: AppColor.textTitle(context))),
                const Spacer(),
                TextButton(
                  style: ButtonStyle(
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    splashFactory: NoSplash.splashFactory,
                  ),
                  onPressed: () {},
                  child: Text(
                    "See All Categories",
                    style: AppTextStyle.body(context,
                        color: AppColor.primary(context), fontSize: 15),
                  ),
                ),
              ],
            ),
            ProductHome(),
          ],
        ),
      ),
    );
  }
}
