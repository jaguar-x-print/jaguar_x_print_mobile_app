import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/widgets/fields/text_input_field.dart';

class BlocageField extends StatelessWidget {
  final TextEditingController blocageHeuresController;
  final ValueChanged<String>? onChanged;

  const BlocageField({
    super.key,
    required this.blocageHeuresController,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Nombre d'heures de blocage",
          style: TextStyle(fontSize: Adaptive.sp(15), fontWeight: FontWeight.bold),
        ),
        InputField(
          controller: blocageHeuresController,
          onTap: () {},
          focus: true,
          backColor: whiteColor,
          onChange: onChanged,
          textColor: blackColor,
          hint: 'Nombre d\'heure de blocage...',
          prefixIcon: Icons.lock_clock_rounded,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}