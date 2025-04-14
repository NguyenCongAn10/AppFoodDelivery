import 'package:delivery_apps/common/color_extention.dart';
import 'package:delivery_apps/common_widget/normal_text.dart';
import 'package:delivery_apps/common_widget/normal_text_bold.dart';
import 'package:delivery_apps/common_widget/round_textfield.dart';
import 'package:delivery_apps/view/home/banner_slider.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.menu,
            color: Colors.black,
          ),
        ),
        title: NormalTextBold(color: TColor.primary, txt: "Home"),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: RoundTextField(
                        hint: "Search your food",
                        preicon: Icon(Icons.search),
                        sufIcon: false,
                        obscureText: false),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: TColor.main,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.filter_list,
                          color: Colors.white,
                        )),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              BannerSlider(),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  NormalTextBold(color: TColor.primary, txt: "Categories"),
                  Spacer(),
                  TextButton(
                      style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(Colors.transparent),
                          splashFactory: NoSplash.splashFactory),
                      onPressed: () {},
                      child: NormalText(
                        color: TColor.main,
                        txt: "See All Categories",
                        size: 15,
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
