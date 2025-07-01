import 'package:flutter/material.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactLink extends StatelessWidget {
  final String label;
  final String? phoneNumber;

  const ContactLink({
    super.key,
    required this.label,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    if (phoneNumber == null || phoneNumber!.isEmpty) {
      return const Text("Numéro non disponible");
    }

    return InkWell(
      onTap: () async {
        final url = label.startsWith("WhatsApp")
            ? "https://wa.me/$phoneNumber"
            : "tel:$phoneNumber";
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Impossible d'ouvrir le lien")),
          );
        }
      },
      child: Text(
        "$label$phoneNumber",
        style: const TextStyle(color: contactColor),
      ),
    );
  }
}