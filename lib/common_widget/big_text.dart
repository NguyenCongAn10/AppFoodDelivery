import 'package:flutter/material.dart';

class BigText extends StatelessWidget {
  final Color? color;
  final String txt;
  double size;
  TextOverflow overflow;

  BigText(
      {super.key, required this.color, required this.txt, this.overflow = TextOverflow
          .ellipsis, this.size = 26});

  @override
  Widget build(BuildContext context) {
    return Text(
      txt,
      overflow: overflow,
      style: TextStyle(
          fontFamily: "Metropolis",
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: size),
    );
  }
}
