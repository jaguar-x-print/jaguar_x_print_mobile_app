import 'package:flutter/material.dart';
import 'package:jaguar_x_print/constant/colors.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Confirmer la suppression"),
      content: const Text("Voulez-vous vraiment supprimer ?"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Annuler"),
        ),
        TextButton(
          onPressed: onConfirm,
          child: const Text(
            "Supprimer",
            style: TextStyle(
              color: redColor,
            ),
          ),
        ),
      ],
    );
  }
}