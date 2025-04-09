import 'package:delivery_apps/common/color_extention.dart';
import 'package:delivery_apps/common_widget/normal_text.dart';
import 'package:delivery_apps/common_widget/normal_text_bold.dart';
import 'package:delivery_apps/common_widget/round_textfield.dart';
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
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: TColor.textfield,
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NormalTextBold(
                          color: Colors.black,
                          txt: "Shop Your Daily\n Necessary!",
                          size: 25,
                        ),
                        SizedBox(height: 8,),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: TColor.main,
                              borderRadius: BorderRadius.circular(20)),
                          child: NormalText(
                            color: Colors.white,
                            txt: "Free Delivery",
                            size: 15,
                          ),
                        )
                      ],
                    )),
                    Image.asset(
                      "assets/image/splash_bg.png",
                      width: 120,
                      height: 120,
                      fit: BoxFit.fill,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
