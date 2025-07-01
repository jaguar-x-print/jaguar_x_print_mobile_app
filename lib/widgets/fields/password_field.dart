import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/constant/colors.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.onTap,
    required this.focus,
    required this.hint,
    required this.controller,
    this.onChange,
    this.correct,
    this.prefixIcon,
    this.prefixIconColor,
    this.validator,
    this.keyboardType,
    this.backColor,
    this.textColor,
    this.hintColor,
    this.suffixIconColor,
    this.textFieldColor,

  });

  final bool focus;
  final String hint;
  final TextEditingController controller;
  final VoidCallback onTap;
  final void Function(String)? onChange;
  final bool? correct;
  final IconData? prefixIcon;
  final Color? prefixIconColor;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Color? backColor;
  final Color? textColor;
  final Color? hintColor;
  final Color? suffixIconColor;
  final Color? textFieldColor;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: widget.focus
            ? const LinearGradient(
          colors: [
            firstColor,
            firstColor,
          ],
        )
            : null,
      ),
      child: TextFormField(
        controller: widget.controller,
        onTap: widget.onTap,
        onChanged: widget.onChange,
        keyboardType: widget.keyboardType ?? TextInputType.text,
        style: TextStyle(
          color: widget.textFieldColor ?? blackColor,
          fontWeight: FontWeight.bold,
        ),
        obscureText: _obscureText,
        decoration: InputDecoration(
          filled: true,
          prefixIcon: widget.prefixIcon != null
              ? Icon(
            widget.prefixIcon,
            color: widget.prefixIconColor ?? firstColor,
            size: Adaptive.sp(18),
          )
              : null,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: widget.suffixIconColor ?? firstColor,
              size: Adaptive.sp(18),
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
          fillColor: widget.backColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          hoverColor: blackColor,
          contentPadding: EdgeInsets.symmetric(
            horizontal: Adaptive.w(4),
            vertical: Adaptive.h(1),
          ),
          hintText: widget.hint,
          hintStyle: TextStyle(
            color: widget.hintColor,
            fontWeight: FontWeight.normal,
            fontSize: Adaptive.sp(13),
          ),
        ),
        validator: widget.validator,
      ),
    );
  }
}