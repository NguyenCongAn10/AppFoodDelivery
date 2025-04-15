import 'package:delivery_apps/common_widget/normal_text.dart';
import 'package:flutter/material.dart';

import '../../common/color_extention.dart';

class CategoriesSlider extends StatefulWidget {
  const CategoriesSlider({super.key});

  @override
  State<CategoriesSlider> createState() => _CategoriesSliderState();
}

class _CategoriesSliderState extends State<CategoriesSlider> {
  int curentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          ListView.builder(itemBuilder: (context,index){
            return Container(
              width: 100,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey[200],
              ),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Row(
                  children: [
                    Container(
                      width:25,
                      height: 25,
                      decoration:BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        color: Colors.white,

                      ),
                      child: Image.network(""),
                    ),
                    NormalText(color: TColor.primary, txt: "")
                  ],
                ),
              ),
            );
          })
        ],
      ),
    );
  }
}
