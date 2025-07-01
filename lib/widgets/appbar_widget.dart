import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

class AppBarWidget extends StatelessWidget {
  final String title;
  final Color textColor;
  final String imagePath;

  const AppBarWidget({
    super.key,
    required this.title,
    required this.textColor,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: 10.h,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
        ),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: Adaptive.sp(22),
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
