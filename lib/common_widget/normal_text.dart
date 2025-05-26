import 'package:flutter/material.dart';

class NormalText extends StatelessWidget {
  final Color? color;
  final String txt;
  double size;
  TextOverflow overflow;

  NormalText(
      {super.key,
      required this.color,
      required this.txt,
      this.overflow = TextOverflow.ellipsis,
      this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Text(
      softWrap: true,
      txt,
      overflow: overflow,
      style: TextStyle(
        fontFamily: "Metropolis",
        color: color,
        fontWeight: FontWeight.w500,
        fontSize: size,
      ),
    );
  }
}
