import 'package:flutter/material.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/common/app_text_style.dart';

class RoundTextField extends StatefulWidget {
  final TextEditingController? textEditingController;
  final String hint;
  final bool obscureText;
  final Icon? preicon;
  final bool sufIcon;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final EdgeInsetsGeometry? contentPadding;

  const RoundTextField({
    super.key,
    required this.hint,
    this.textEditingController,
    this.preicon,
    required this.sufIcon,
    required this.obscureText,
    this.validator,
    this.onChanged,
    this.contentPadding,
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
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.never,
        prefixIcon: widget.preicon,
        suffixIcon: widget.sufIcon
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
            : null,
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
        filled: true,
        fillColor: AppColor.inputFill(context),
        isDense: true,
        contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }
}
