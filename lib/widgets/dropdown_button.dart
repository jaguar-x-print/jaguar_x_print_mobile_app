import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/constant/colors.dart';

class DropdownField<T> extends StatefulWidget {
  const DropdownField({
    super.key,
    required this.focus,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.value,
    this.validator,
    this.prefixIcon,
  });

  final bool focus;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;

  @override
  State<DropdownField<T>> createState() => _DropdownFieldState<T>();
}

class _DropdownFieldState<T> extends State<DropdownField<T>> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Adaptive.w(95),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: firstColor,
            width: 2,
          ),
        ),
        child: DropdownButtonFormField<T>(
          value: widget.value,
          items: widget.items,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: whiteColor,
            prefixIcon: widget.prefixIcon != null
            ? Icon(
              widget.prefixIcon,
              color: firstColor,
              size: Adaptive.sp(20),
            )
                : null,
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
          style: TextStyle(
            color: blackColor,
            fontWeight: FontWeight.bold,
            fontSize: Adaptive.sp(13),
          ),
          validator: widget.validator,
          dropdownColor: whiteColor,
          isExpanded: true,
        ),
      ),
    );
  }
}
