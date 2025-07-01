import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/widgets/fields/text_input_field.dart';

class CommentsField extends StatelessWidget {
  final TextEditingController commentController;

  const CommentsField({super.key, required this.commentController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Commentaires",
          style: TextStyle(
            fontSize: Adaptive.sp(15),
            fontWeight: FontWeight.bold,
          ),
        ),
        InputField(
          controller: commentController,
          minLines: 2,
          onTap: () {},
          backColor: whiteColor,
          focus: true,
          textColor: blackColor,
          hint: 'Entrez vos commentaires...',
          keyboardType: TextInputType.multiline,
        ),
      ],
    );
  }
}