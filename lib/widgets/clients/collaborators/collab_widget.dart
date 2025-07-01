import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/models/classes/collaborator.dart';
import 'package:jaguar_x_print/widgets/clients/custom_phone_field.dart';
import 'package:jaguar_x_print/widgets/fields/text_input_field.dart';

class CollaboratorWidget extends StatefulWidget {
  final Collaborator collaborator;
  final void Function() onRemove;

  const CollaboratorWidget({
    super.key,
    required this.collaborator,
    required this.onRemove,
  });

  @override
  State<CollaboratorWidget> createState() => _CollaboratorWidgetState();
}

class _CollaboratorWidgetState extends State<CollaboratorWidget> {
  String _formatWithSpaces(String value) {
    if (value.length <= 3) {
      return value;
    }

    final buffer = StringBuffer();
    int count = 0;
    for (int i = value.length - 1; i >= 0; i--) {
      buffer.write(value[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write(' ');
      }
    }

    return buffer.toString().split('').reversed.join('');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Adaptive.h(0.5)),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.all(Adaptive.w(2)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Adaptive.h(0.8)),
            Text(
              "Nom du collaborateur",
              style: TextStyle(fontSize: Adaptive.sp(12)),
            ),
            InputField(
              onTap: () {},
              focus: true,
              backColor: whiteColor,
              textColor: blackColor,
              controller: widget.collaborator.nameController,
              hint: "Nom du collaborateur",
              prefixIcon: Icons.person,
            ),
            SizedBox(height: Adaptive.h(0.8)),
            Text(
              "Poste occupé",
              style: TextStyle(fontSize: Adaptive.sp(12)),
            ),
            InputField(
              onTap: () {},
              focus: true,
              backColor: whiteColor,
              textColor: blackColor,
              controller: widget.collaborator.jobTitleController,
              hint: "Poste occupé",
              prefixIcon: Icons.work_rounded,
            ),
            SizedBox(height: Adaptive.h(0.8)),
            Text(
              "Téléphone",
              style: TextStyle(fontSize: Adaptive.sp(12)),
            ),
            CustomPhoneField(
              focus: true,
              hint: "xxx...",
              initialCountryCode: "CM",
              suffixIcon: Icons.phone_android_rounded,
              controller: widget.collaborator.phoneController,
              onChange: (dialCode, number) {
                setState(() {
                  widget.collaborator.phoneController.text = _formatWithSpaces(
                    number,
                  );
                });
              },
            ),
            SizedBox(height: Adaptive.h(0.8)),
            Text(
              "WhatsApp contact",
              style: TextStyle(fontSize: Adaptive.sp(12)),
            ),
            CustomPhoneField(
              focus: true,
              hint: "xxx...",
              initialCountryCode: "CM",
              suffixIcon: FontAwesomeIcons.whatsapp,
              controller: widget.collaborator.whatsappController,
              onChange: (dialCode, number) {
                setState(() {
                  widget.collaborator.whatsappController.text =
                      _formatWithSpaces(
                    number,
                  );
                });
              },
            ),
            Center(
              child: IconButton(
                onPressed: widget.onRemove,
                icon: Icon(
                  Icons.remove_circle,
                  color: redColor,
                  size: Adaptive.sp(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
