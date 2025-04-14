import 'package:flutter/material.dart';

import '../../common/color_extention.dart';
import '../../common_widget/normal_text.dart';
import '../../common_widget/normal_text_bold.dart';

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  List<Map<String, dynamic>> listBanner = [
    {
      "style": "style1",
      "image": "assets/image/splash_bg.png",
      "tittle1": "Shop Your Daily\n Necessary!",
      "TextButtom": "Free Delivery",
    },
    {
      "style": "style2",
      "image": "assets/image/splash_bg.png",
      "tittle1": "Shop Your Daily\n Necessary!",
      "TextButtom": "Free Delivery",
    },
    {
      "style": "style3",
      "image": "assets/image/splash_bg.png",
      "tittle1": "Shop Your Daily\n Necessary!",
      "TextButtom": "Free Delivery",
    }
  ];

  int currentIndexBaner = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
              itemCount: listBanner.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndexBaner = index;
                });
              },
              itemBuilder: (context, index) {
                final banner = listBanner[index];
                switch (banner["style"]) {
                  case "style1":
                    return Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: TColor.textfield,
                          borderRadius: BorderRadius.circular(30)),
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
                              SizedBox(
                                height: 8,
                              ),
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
                    );
                  case "style2":
                    return Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: TColor.textfield,
                          borderRadius: BorderRadius.circular(30)),
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
                              SizedBox(
                                height: 8,
                              ),
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
                    );
                  case "style3":
                    return Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: TColor.textfield,
                          borderRadius: BorderRadius.circular(30)),
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
                              SizedBox(
                                height: 8,
                              ),
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
                    );
                  default:
                    return SizedBox.shrink();
                }
              }),
        ),
        const SizedBox(height: 8,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
              listBanner.length,
              (index) => Container(
                    width: currentIndexBaner == index ? 12 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: currentIndexBaner == index
                            ? TColor.main
                            : Colors.grey[300],
                        shape: BoxShape.circle),
                  )),
        )
      ],
    );
  }
}
