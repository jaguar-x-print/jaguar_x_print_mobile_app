import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/models/contact_model.dart';
import 'package:jaguar_x_print/widgets/image_picker.dart';

class FacadePhotoWidget extends StatelessWidget {
  final Contact contact;
  final Function(String? imagePath) onImageSelected;

  const FacadePhotoWidget({
    super.key,
    required this.contact,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Photo de la façade de l'entreprise",
          style: TextStyle(fontSize: Adaptive.sp(20), fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
        SizedBox(height: Adaptive.h(1)),
        if (contact.photoFacade.isEmpty)
          Text(
            "Aucune image sélectionnée",
            style: TextStyle(
              fontSize: Adaptive.sp(16),
              color: redColor,
            ),
          ),
        SizedBox(height: Adaptive.h(1)),
        ImagePickerWidget(
          initialImagePath: contact.photoFacade.isNotEmpty == true
              ? contact.photoFacade
              : "assets/Image_not_available.png",
          onImageSelected: onImageSelected,
        ),
      ],
    );
  }
}
