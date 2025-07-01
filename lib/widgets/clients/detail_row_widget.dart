import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

class DetailRow extends StatelessWidget {
  final String title;
  final String value;

  const DetailRow({
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: Adaptive.sp(15),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value, style: TextStyle(fontSize: Adaptive.sp(15))),
        ],
      ),
    );
  }
}