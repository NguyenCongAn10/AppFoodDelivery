import 'package:delivery_apps/common_widget/normal_text_bold.dart';
import 'package:flutter/material.dart';

import '../../common/color_extention.dart';


class CategoriesSlider extends StatefulWidget {
  const CategoriesSlider({super.key});

  @override
  State<CategoriesSlider> createState() => _CategoriesSliderState();
}

class _CategoriesSliderState extends State<CategoriesSlider> {
  List<String> imageCategories = [
    "assets/image/apple_icon.png",
    "assets/image/logo_facebook.png",
    "assets/image/logo_google.png"
  ];

  List<String> nameCategories = [
    "apple",
    "facebook",
    "gu go"
  ];

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Cuộn ngang
        itemCount: imageCategories.length, // Số lượng danh mục
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  currentIndex = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB( 5, 8, 10, 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: currentIndex == index
                      ? TColor.main
                      : Colors.grey[100],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Image.asset(
                        imageCategories[index],
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 8),
                    NormalTextBold(
                      color: currentIndex == index ? Colors.white : Colors.black,
                      txt: nameCategories[index],
                      size:15 ,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
