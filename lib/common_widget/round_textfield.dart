import 'package:flutter/material.dart';
import '../common/color_extention.dart';
import 'normal_text_bold.dart';

class RoundTextField extends StatefulWidget {
  final TextEditingController? textEditingController;
  final String hint;
  final bool obscureText;
  final Icon? preicon;
  final bool sufIcon;
  final String? Function(String?)? validator;

  const RoundTextField({
    super.key,
    required this.hint,
    this.textEditingController,
    this.preicon,
    required this.sufIcon,
    required this.obscureText,
    this.validator,
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
        label: NormalTextBold(
          color: Colors.grey,
          txt: widget.hint,
          size: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: TColor.textfield,
      ),
    );
  }
}
