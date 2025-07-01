import 'package:flutter/material.dart';
import 'dart:math';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Liste pour stocker les couleurs des cartes
  final List<Color> cardColors = [];

  // Méthode pour générer une couleur aléatoire
  Color generateRandomColor() {
    final Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256), // Rouge (0-255)
      random.nextInt(256), // Vert (0-255)
      random.nextInt(256), // Bleu (0-255)
      1.0, // Opacité
    );
  }

  // Méthode pour déterminer la couleur du texte en fonction de la couleur de fond
  Color getTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance < 0.2 ? Colors.white : Colors.black;
  }

  // Méthode pour ajouter une nouvelle carte avec une couleur aléatoire
  void addNewCard() {
    setState(() {
      cardColors.add(generateRandomColor());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Page principale"),
      ),
      body: ListView.builder(
        itemCount: cardColors.length,
        itemBuilder: (context, index) {
          final color = cardColors[index];
          final textColor = getTextColor(color);
          return Card(
            color: color,
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Card ${index + 1}',
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewCard,
        tooltip: 'Add Card',
        child: const Icon(Icons.add),
      ),
    );
  }
}