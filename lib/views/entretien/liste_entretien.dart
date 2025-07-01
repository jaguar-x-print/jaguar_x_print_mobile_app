// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/bloc/entretien/entretien_cubit.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/models/contact_model.dart';
import 'package:jaguar_x_print/models/entretien_model.dart';
import 'package:jaguar_x_print/views/entretien/pages/pdf_service.dart';
import 'package:jaguar_x_print/views/entretien/pdf_viewer_screen.dart';

class ListeEntretienPage extends StatelessWidget {
  final Contact contact;

  const ListeEntretienPage({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EntretienCubit(
        contactId: contact.id!,
      )..loadEntretiens(),
      child: Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              );
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Entretiens ${contact.companyName}',
                style: TextStyle(fontSize: Adaptive.sp(16)),
              ),
              Text(
                contact.name ?? "",
                style: TextStyle(
                  fontSize: Adaptive.sp(12),
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        body: _buildEntretienList(),
      ),
    );
  }

  Widget _buildEntretienList() {
    return BlocBuilder<EntretienCubit, List<Entretien>>(
      builder: (context, entretiens) {
        //entretiens.sort((a, b) => b.date!.compareTo(a.date!));
        if (entretiens.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Aucun entretien pour ce client',
                  style: TextStyle(fontSize: Adaptive.sp(14)),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(Adaptive.w(4)),
          itemCount: entretiens.length,
          separatorBuilder: (context, index) => Divider(
            height: Adaptive.h(2),
          ),
          itemBuilder: (context, index) {
            final entretien = entretiens[index];
            return _EntretienTile(
              contact: contact,
              entretien: entretien,
              onDelete: () => context.read<EntretienCubit>().deleteEntretien(
                entretien.id!,
              ),
            );
          },
        );
      },
    );
  }
}

class _EntretienTile extends StatefulWidget {
  final Entretien entretien;
  final VoidCallback onDelete;
  final Contact contact;

  const _EntretienTile({
    required this.entretien,
    required this.onDelete,
    required this.contact,
  });

  @override
  State<_EntretienTile> createState() => _EntretienTileState();
}

class _EntretienTileState extends State<_EntretienTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: Adaptive.h(2)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Adaptive.w(3)),
      ),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(Adaptive.w(3)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(Adaptive.w(2.5)),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(),
                    size: Adaptive.w(6),
                  ),
                ),
                SizedBox(width: Adaptive.w(3)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _truncateText(
                          widget.entretien.problemePostIntervention ?? 'Sans titre',
                          context,
                          Adaptive.w(70),
                        ),
                        style: TextStyle(
                          fontSize: Adaptive.sp(14),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: Adaptive.h(0.3)),
                      Text(
                        widget.entretien.date ?? "No date",
                        style: TextStyle(
                          fontSize: Adaptive.sp(10),
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildPopupMenu(),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                left: Adaptive.w(12),
                right: Adaptive.w(4),
                top: Adaptive.h(1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _truncateText(
                      widget.entretien.problemeDecrit ?? 'Aucune description',
                      context,
                      Adaptive.w(80),
                    ),
                    style: TextStyle(
                      fontSize: Adaptive.sp(12),
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: Adaptive.h(1)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Adaptive.w(3),
                      vertical: Adaptive.h(0.5),
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(Adaptive.w(2)),
                      border: Border.all(
                        color: _getStatusColor().withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      'Résolu: ${widget.entretien.probRes ?? 'Non spécifié'}',
                      style: TextStyle(
                        fontSize: Adaptive.sp(10),
                        color: _getStatusColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _truncateText(String text, BuildContext context, double maxWidth) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: Adaptive.sp(14),
          fontWeight: FontWeight.w600,
        ),
      ),
      maxLines: 2,
      textDirection: TextDirection.ltr,
    )..layout(
      maxWidth: maxWidth,
    );

    if (textPainter.didExceedMaxLines) {
      final endIndex = textPainter.getPositionForOffset(
        Offset(maxWidth, 0),
      ).offset;
      return '${text.substring(0, endIndex - 2)}...';
    } else {
      return text;
    }
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: Adaptive.w(6)),
      onSelected: (value) => _handleMenuSelection(value, context),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: 'pdf',
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, size: Adaptive.w(5)),
              SizedBox(width: Adaptive.w(2)),
              Text(
                'Voir le PDF',
                style: TextStyle(fontSize: Adaptive.sp(12)),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: Adaptive.w(5)),
              SizedBox(width: Adaptive.w(2)),
              Text(
                'Supprimer',
                style: TextStyle(fontSize: Adaptive.sp(12)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleMenuSelection(String value, BuildContext context) async {
    switch (value) {
      case 'pdf':
        _handlePdfGeneration(context);
        break;
      case 'delete':
        _confirmDelete(context);
        break;
    }
  }

  void _handlePdfGeneration(BuildContext context) async {
    try {
      final pdfFile = await PdfService.generateEntretienPdf(
        contact: widget.contact,
        entretien: widget.entretien,
        signaturePath: widget.entretien.signatureImagePath,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(
            pdfPath: pdfFile.path,
            contact: widget.contact,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur de génération du PDF: $e"),
          backgroundColor: redColor,
        ),
      );
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer suppression'),
        content: const Text('Supprimer cet entretien de l\'historique ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              widget.onDelete();
              Navigator.pop(context);
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: redColor),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    return widget.entretien.probRes?.toLowerCase() == 'oui'
        ? green2Color
        : redColor;
  }

  IconData _getStatusIcon() {
    return widget.entretien.probRes?.toLowerCase() == 'oui'
        ? Icons.check_circle_outline
        : Icons.error_outline;
  }
}
