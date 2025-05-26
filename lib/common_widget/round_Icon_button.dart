import 'package:flutter/material.dart';

class RoundIconButton extends StatelessWidget {
  final IconData preIcon;
  final VoidCallback onPress;
  final Widget txt;

  const RoundIconButton(
      {super.key,
      required this.preIcon,
      required this.onPress,
      required this.txt});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onPress,
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(
                preIcon,
                size: 27,
                color: Colors.black54,
              ),
              const SizedBox(
                width: 8,
              ),
              txt,
              const Spacer(),
              const Icon(Icons.arrow_forward_ios)
            ],
          ),
        ),
      ),
    );
  }
}
