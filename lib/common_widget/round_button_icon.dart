import 'package:flutter/material.dart';

class RoundButtonIcon extends StatelessWidget {
  final Widget txt;
  final Color color;
  Image image;
  final bool shadow;
  final VoidCallback onpress;

  RoundButtonIcon(
      {super.key,
        required this.txt,
        required this.color,
        required this.image,
        required this.shadow, required this.onpress}) {

  }

  @override
  Widget build(BuildContext context) {
    Size media = MediaQuery.of(context).size;
    return Container(
        height: media.height * 0.065,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: shadow
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            )
          ]
              : [],
          color: color,
        ),
        child: TextButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 35),
                child: image,
              ),
              const SizedBox(width: 10,),
              txt
            ],
          ),
          onPressed: () {},
        ));
  }
}
