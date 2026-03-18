import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/common/app_text_style.dart';

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  List<Map<String, dynamic>> listBanner = [
    {
      "style": "style1",
      "imageUrl":
          "https://images.unsplash.com/photo-1546069901-ba9599a7e63c", // Healthy bowl
      "title1": "Fresh & Healthy\nSalads!",
      "textButton": "Order Now",
      "link": "/shop"
    },
    {
      "style": "style2",
      "imageUrl":
          "https://images.unsplash.com/photo-1568901346375-23c9450c58cd", // Burger
      "title1": "Juicy Burgers\nNear You!",
      "textButton": "Grab a Bite",
      "link": "/food"
    },
    {
      "style": "style3",
      "imageUrl":
          "https://images.unsplash.com/photo-1504674900247-0877df9cc836", // Wide food spread
      "title1": "Weekend Special\nFeast Ends Soon!",
      "textButton": "Claim Offer",
      "link": "/grocery"
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
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: AppColor.container(context),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                banner["title1"] ?? "",
                                style: AppTextStyle.bodyBold(context,
                                    color: AppColor.textTitle(context),
                                    fontSize: 22),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                    color: AppColor.primary(context),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text(
                                  banner["textButton"] ?? "",
                                  style: AppTextStyle.body(context,
                                      color: Colors.white, fontSize: 14),
                                ),
                              )
                            ],
                          )),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              imageUrl: banner["imageUrl"],
                              width: 110,
                              height: 110,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Container(color: Colors.grey[300]),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          )
                        ],
                      ),
                    );
                  case "style2":
                    return Container(
                      padding: const EdgeInsets.only(
                          left: 20, right: 10, top: 16, bottom: 16),
                      decoration: BoxDecoration(
                          color: AppColor.primary(context),
                          boxShadow: [
                            BoxShadow(
                                color: AppColor.primary(context)
                                    .withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5))
                          ],
                          borderRadius: BorderRadius.circular(25)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                banner["title1"] ?? "",
                                style: AppTextStyle.bodyBold(context,
                                    color: Colors.white, fontSize: 22),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text(
                                  banner["textButton"] ?? "",
                                  style: AppTextStyle.bodyBold(context,
                                      color: AppColor.primary(context),
                                      fontSize: 14),
                                ),
                              )
                            ],
                          )),
                          const SizedBox(width: 10),
                          Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5))
                                ]),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: banner["imageUrl"],
                                width: 110,
                                height: 110,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Container(color: Colors.white24),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error,
                                        color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  case "style3":
                    return Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image:
                                CachedNetworkImageProvider(banner["imageUrl"]),
                            fit: BoxFit.cover,
                          )),
                      child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                colors: [Colors.black87, Colors.transparent],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )),
                          child: Row(
                            children: [
                              Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      banner["title1"] ?? "",
                                      style: AppTextStyle.bodyBold(context,
                                          color: Colors.white, fontSize: 22),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                          color: AppColor.primary(context),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Text(
                                        banner["textButton"] ?? "",
                                        style: AppTextStyle.bodyBold(context,
                                            color: Colors.white, fontSize: 14),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          )
                      ),
                    );
                  default:
                    return const SizedBox.shrink();
                }
              }),
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
              listBanner.length,
              (index) => Container(
                    width: currentIndexBaner == index ? 12 : 10,
                    height: 8,
                    decoration: BoxDecoration(
                        color: currentIndexBaner == index
                            ? AppColor.primary(context)
                            : AppColor.textSecondary(context).withValues(alpha: 0.3),
                        shape: BoxShape.circle),
                  )),
        )
      ],
    );
  }
}
