import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/constant/colors.dart';

class DetailsRowEntretien extends StatelessWidget {
  final String title;
  final String value;

  const DetailsRowEntretien({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: Adaptive.h(0.5),
        horizontal: Adaptive.w(0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: Adaptive.sp(17),
              color: whiteColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: Adaptive.sp(14),
              color: whiteColor,
            ),
          ),
        ],
      ),
    );
  }
}