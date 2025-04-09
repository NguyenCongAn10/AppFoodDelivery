import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final Widget txt;
  final Color color;
  final VoidCallback onpress;

  RoundButton({
    super.key,
    required this.txt,
    required this.color,
    required this.onpress,
  });

  @override
  Widget build(BuildContext context) {
    Size media = MediaQuery.of(context).size;
    return Container(
        height: media.height * 0.065,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: color,
        ),
        child: TextButton(
          onPressed: onpress,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [txt],
          ),
        ));
  }
}
