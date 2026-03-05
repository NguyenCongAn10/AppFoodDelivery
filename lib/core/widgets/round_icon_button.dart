import 'package:delivery_apps/core/common/color_extension.dart';
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppColor.textSecondary(context).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                preIcon,
                size: 27,
                color: AppColor.textSecondary(context),
              ),
              const SizedBox(width: 8),
              txt,
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColor.textSecondary(context),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
