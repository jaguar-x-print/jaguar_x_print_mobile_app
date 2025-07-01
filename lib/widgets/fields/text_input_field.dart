import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/constant/colors.dart';

class InputField extends StatefulWidget {
  const InputField({
    super.key,
    required this.onTap,
    required this.focus,
    required this.hint,
    required this.controller,
    this.onChange,
    this.correct,
    this.prefixIcon,
    this.minLines,
    this.maxLines,
    this.validator,
    this.keyboardType,
    this.isPassword = false,
    this.readOnly = false,
    required this.backColor,
    this.hintColor,
    required this.textColor,
    this.suffixIcon,
  });

  final bool focus;
  final String hint;
  final TextEditingController controller;
  final VoidCallback onTap;
  final void Function(String)? onChange;
  final bool? correct;
  final IconData? prefixIcon;
  final Color backColor;
  final Color? hintColor;
  final Color textColor;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? minLines;
  final int? maxLines;
  final bool isPassword;
  final bool readOnly;
  final Widget? suffixIcon;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
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
        readOnly: widget.readOnly,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        onTap: widget.onTap,
        onChanged: widget.onChange,
        keyboardType: widget.keyboardType ?? TextInputType.text,
        style: TextStyle(
          color: widget.textColor,
          fontWeight: FontWeight.bold,
        ),
        obscureText: widget.isPassword ? _obscureText : false,
        decoration: InputDecoration(
          filled: true,
          prefixIcon: widget.prefixIcon != null
              ? Icon(
            widget.prefixIcon,
            color: firstColor,
            size: Adaptive.sp(18),
          )
              : null,
          suffixIcon: widget.isPassword
              ? IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: firstColor,
              size: Adaptive.sp(18),
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          )
              : null,
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