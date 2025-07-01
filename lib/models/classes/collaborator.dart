import 'package:flutter/material.dart';

class Collaborator {
  TextEditingController nameController = TextEditingController();
  TextEditingController jobTitleController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController whatsappController = TextEditingController();

  Map<String, dynamic> toJson() => {
    'name': nameController.text,
    'jobTitle': jobTitleController.text,
    'phone': phoneController.text,
    'whatsapp': whatsappController.text,
  };

  Collaborator.fromJson(Map<String, dynamic> json)
      : nameController = TextEditingController(text: json['name']),
        jobTitleController = TextEditingController(text: json['jobTitle']),
        phoneController = TextEditingController(text: json['phone']),
        whatsappController = TextEditingController(text: json['whatsapp']);

  Collaborator();
}