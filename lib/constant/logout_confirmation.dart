import 'package:flutter/material.dart';
import 'package:jaguar_x_print/constant/colors.dart';

class LogoutConfirmation extends StatelessWidget {
  final VoidCallback onConfirm;

  const LogoutConfirmation({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Confirmer la déconnexion"),
      content: const Text("Voulez-vous vraiment vous déconnecté ?"),
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
            "Déconnexion",
            style: TextStyle(
              color: redColor,
            ),
          ),
        ),
      ],
    );
  }
}