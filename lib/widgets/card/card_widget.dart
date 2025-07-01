import 'package:flutter/material.dart';
import 'package:jaguar_x_print/constant/colors.dart';

class CustomCard extends StatelessWidget {
  final Color color;
  final String text;

  const CustomCard({
    super.key,
    required this.color,
    required this.text,
  });

  // Méthode pour déterminer la couleur du texte en fonction du fond
  Color getTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance < 0.2 ? whiteColor : blackColor;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          text,
          style: TextStyle(
            color: getTextColor(color),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

