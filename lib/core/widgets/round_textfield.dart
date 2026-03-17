import 'package:flutter/material.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/common/app_text_style.dart';

class RoundTextField extends StatefulWidget {
  final TextEditingController? textEditingController;
  final String hint;
  final bool obscureText;
  final Icon? preicon;
  final bool sufIcon;
  final Widget? sufIconWidget;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final EdgeInsetsGeometry? contentPadding;
  final TextInputType? keyboardType;

  const RoundTextField({
    super.key,
    required this.hint,
    this.textEditingController,
    this.preicon,
    required this.sufIcon,
    this.sufIconWidget,
    required this.obscureText,
    this.validator,
    this.onChanged,
    this.contentPadding,
    this.keyboardType,
  });

  @override
  State<RoundTextField> createState() => _RoundTextFieldState();
}

class _RoundTextFieldState extends State<RoundTextField> {
  late bool isObscure;

  @override
  void initState() {
    super.initState();
    isObscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.textEditingController,
      obscureText: isObscure,
      validator: widget.validator,
      onChanged: widget.onChanged,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.never,
        prefixIcon: widget.preicon,
        suffixIcon: widget.sufIconWidget ??
            (widget.sufIcon
            ? IconButton(
                    onPressed: () {
                      setState(() {
                        isObscure = !isObscure;
                      });
                    },
                    icon: Icon(
                      isObscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                  )
                : null),
        label: Text(
          widget.hint,
          style: AppTextStyle.body(context, color: Colors.grey, fontSize: 17),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColor.primary(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColor.primary(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColor.primary(context), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: AppColor.inputFill(context),
        isDense: true,
        errorStyle: const TextStyle(height: 0.8),
        contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }
}
