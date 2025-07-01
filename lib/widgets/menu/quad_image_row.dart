import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/constant/colors.dart';

class QuadImageRow extends StatelessWidget {
  final List<String> imagePaths;
  final List<String> titles;
  final List<Color>? titleColors;
  final List<VoidCallback>? onTapCallbacks;
  final double spacing;
  final MainAxisAlignment alignment;

  const QuadImageRow({
    super.key,
    required this.imagePaths,
    required this.titles,
    this.titleColors,
    this.onTapCallbacks,
    this.spacing = 0,
    this.alignment = MainAxisAlignment.spaceEvenly,
  })  : assert(
          imagePaths.length == 4 && titles.length == 4,
          'Exactly 4 images and titles required',
        ),
        assert(
          titleColors == null || titleColors.length == 4,
          'If provided, titleColors must have exactly 4 colors',
        );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 5.h,
      child: Row(
        mainAxisAlignment: alignment,
        children: List.generate(4, (index) {
          return InkWell(
            onTap: onTapCallbacks?[index],
            borderRadius: BorderRadius.circular(8),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: spacing.w),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      imagePaths[index],
                      width: 23.w,
                      height: 16.h,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.error,
                        size: 40,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(1.w),
                        child: Text(
                          titles[index],
                          style: TextStyle(
                            fontSize: Adaptive.sp(14),
                            fontWeight: FontWeight.bold,
                            color: titleColors?[index] ?? whiteColor,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
