import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/widgets/round_textfield.dart';
import 'package:delivery_apps/features/home/widget/banner_slider.dart';
import 'package:delivery_apps/features/home/screen/product_home.dart';
import 'package:delivery_apps/features/home/screen/search_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.inputFill(context),
      appBar: AppBar(
        backgroundColor: AppColor.container(context),
        leading: IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.menu,
            color: AppColor.textTitle(context),
          ),
        ),
        title: Text("Home", style: AppTextStyle.bodyBold(context, color: AppColor.textTitle(context), fontSize: 20)),
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
                      style: AppTextStyle.body(context, color: AppColor.textSecondary(context)),
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
                Text("Categories", style: AppTextStyle.bodyBold(context, color: AppColor.textTitle(context))),
                const Spacer(),
                TextButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    splashFactory: NoSplash.splashFactory,
                  ),
                  onPressed: () {},
                  child: Text(
                    "See All Categories",
                    style: AppTextStyle.body(context, color: AppColor.primary(context), fontSize: 15),
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
