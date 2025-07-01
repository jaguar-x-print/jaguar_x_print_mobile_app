import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jaguar_x_print/constant/colors.dart'; // Assurez-vous que ce chemin est correct
import 'package:jaguar_x_print/models/contact_model.dart'; // Assurez-vous que ce chemin est correct
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ContactCard extends StatefulWidget {
  final Contact contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(String) onPhotoChanged;

  const ContactCard({
    super.key,
    required this.contact,
    required this.onEdit,
    required this.onDelete,
    required this.onPhotoChanged,
  });

  @override
  State<ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<ContactCard> {
  Color? cardColor;
  late Color textColor;

  @override
  void initState() {
    super.initState();
    cardColor = generateRandomColor(widget.contact);
    textColor = getTextColor(cardColor!);
  }

  @override
  void didUpdateWidget(covariant ContactCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contact != widget.contact) {
      cardColor = generateRandomColor(widget.contact);
      textColor = getTextColor(cardColor!);
    }
  }

  Color generateRandomColor(Contact contact) {
    final random = Random(contact.name.hashCode);
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1.0,
    );
  }

  Color getTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance < 0.2 ? whiteColor : blackColor;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(Adaptive.w(1)),
      color: cardColor,
      child: Padding(
        padding: EdgeInsets.all(Adaptive.w(3)),
        child: Row(
          children: [
            // Cercle décoratif à gauche
            Container(
              width: Adaptive.w(4.5),
              height: Adaptive.h(4.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: whiteColor,
                border: Border.all(
                  color: blackColor,
                  width: 1.0,
                ),
              ),
              margin: const EdgeInsets.only(right: 10),
            ),

            // Nom du contact
            Expanded(
              child: Text(
                widget.contact.companyName ?? 'Nom indisponible',
                style: TextStyle(
                  fontSize: Adaptive.sp(24),
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),

            // Menu à trois points
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: textColor),
              onSelected: (value) {
                if (value == 'edit') {
                  widget.onEdit();
                } else if (value == 'delete') {
                  widget.onDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit_rounded, color: firstColor),
                    title: Text('Modifier'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_forever_rounded, color: redColor),
                    title: Text('Supprimer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
