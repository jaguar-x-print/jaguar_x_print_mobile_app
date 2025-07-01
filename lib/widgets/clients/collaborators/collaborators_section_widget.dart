import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/widgets/clients/collaborators/collaborator_card_widget.dart';

class CollaboratorsSection extends StatelessWidget {
  final String? collaboratorsJson;

  const CollaboratorsSection({super.key, required this.collaboratorsJson});

  @override
  Widget build(BuildContext context) {
    if (collaboratorsJson == null || collaboratorsJson!.isEmpty) {
      return const Text("Aucun collaborateur enregistré");
    }

    try {
      final collaborators = jsonDecode(collaboratorsJson!) as List<dynamic>;

      if (collaborators.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 1.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Collaborateurs",
                style: TextStyle(
                  fontSize: Adaptive.sp(16),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 1.w),
              Text(
                "Aucun collaborateur enregistré",
                style: TextStyle(fontSize: Adaptive.sp(14), color: redColor),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 0.5.h),
            child: Text(
              "Collaborateurs",
              style: TextStyle(
                fontSize: Adaptive.sp(16),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: collaborators.length,
            itemBuilder: (context, index) {
              final collaborator = collaborators[index] as Map<String, dynamic>;
              return CollaboratorCard(collaborator: collaborator);
            },
          ),
        ],
      );
    } catch (e) {
      if (kDebugMode) {
        print("Erreur lors du décodage JSON des collaborateurs: $e");
      }
      return Text(
        "Erreur lors de la récupération des collaborateurs",
        style: TextStyle(fontSize: Adaptive.sp(14)),
      );
    }
  }
}