import 'package:flutter/material.dart';

class RoundIconCircle extends StatelessWidget {
  final Icon icon;
  final VoidCallback? onTap;
  RoundIconCircle({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap ?? () => Navigator.pop(context),
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(width: 1.5, color: Colors.black12),
            color: Colors.transparent),
        child: icon,
      ),
    );
  }
}
