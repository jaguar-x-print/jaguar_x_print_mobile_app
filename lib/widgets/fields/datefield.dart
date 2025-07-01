import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/constant/colors.dart';

class DateField extends StatefulWidget {
  const DateField({
    super.key,
    required this.onTap,
    required this.focus,
    required this.enable,
    required this.hint,
    required this.controller,
    required this.onChange,
    this.correct,
    this.prefixIcon,
    this.maxLines = 1,
    this.keyboardType,
    this.readOnly = false,
  });

  final bool focus;
  final String hint;
  final TextEditingController controller;
  final VoidCallback onTap;
  final VoidCallback onChange;
  final bool? correct;
  final IconData? prefixIcon;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool enable;
  final bool readOnly;

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
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
      child: TextField(
        controller: widget.controller,
        enabled: widget.enable,
        onTap: widget.onTap,
        onChanged: (value) {
          widget.onChange();
        },
        maxLines: widget.maxLines,
        keyboardType: widget.keyboardType ?? TextInputType.text,
        style: const TextStyle(
          color: blackColor,
          fontWeight: FontWeight.bold,
        ),
        readOnly: widget.readOnly,
        decoration: InputDecoration(
          filled: true,
          prefixIcon: widget.prefixIcon != null
              ? Icon(
            widget.prefixIcon,
            color: firstColor,
            size: Adaptive.sp(18),
          )
              : null,
          suffixIcon: widget.correct == true
              ? Icon(
            Icons.done,
            color: greenColor,
            size: Adaptive.sp(20),
          )
              : null,
          fillColor: whiteColor,
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
            color: blackColor,
            fontWeight: FontWeight.normal,
            fontSize: Adaptive.sp(13),
          ),
        ),
      ),
    );
  }
}
