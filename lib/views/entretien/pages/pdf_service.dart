import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:jaguar_x_print/models/entretien_model.dart';
import 'package:jaguar_x_print/models/contact_model.dart';

class PdfService {
  static File? generatedPdfFile;

  static Future<File> generateEntretienPdf({
    required Contact contact,
    required Entretien entretien,
    String? signaturePath,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          _buildHeader(contact, entretien),
          _buildEntretienDetails(entretien),
          if (signaturePath != null && File(signaturePath).existsSync())
            _buildSignatureSection(signaturePath),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    String sanitizedName = contact.name.replaceAll(RegExp(r'\s+'), '_');

    final file = File(
        '${output.path}/entretien_${sanitizedName}_${DateFormat("yyyyMMdd_HHmmss").format(DateTime.now())}.pdf'
    );

    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static pw.Widget _buildHeader(Contact contact, Entretien entretien) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              "Jaguar x-Print",
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              "Fiche d'entretien",
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          "Client: ${contact.name}",
          style: const pw.TextStyle(fontSize: 16),
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              "Date: ${entretien.date}",
              style: const pw.TextStyle(fontSize: 14),
            ),
            pw.Text(
              "Heure d\'arrivée : ${entretien.heureArrivee}",
              style: const pw.TextStyle(fontSize: 14),
            ),
            pw.Text(
              "Heure de départ : ${entretien.signatureTime != null ? DateFormat(
                'HH:mm',
              ).format(
                DateTime.parse(entretien.signatureTime!),
              ) : 'Non spécifié'}",
              style: const pw.TextStyle(fontSize: 14),
            ),
          ],
        ),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildEntretienDetails(Entretien entretien) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          "Environnement de l'appareil",
          const PdfColor.fromInt(0xFF0000FF),
        ),
        // Section Commentaires et Images
        _buildDetailItem("Environnement de l'imprimante", entretien.printerEnvironmentComment),
        _buildImageList('Photos', entretien.printerEnvironmentImage),

        pw.Divider(
          height: 1,
          color: const PdfColor.fromInt(0xFF00FFC8),
        ),

        _buildDetailItem('Evacuation encre', entretien.evacuationEncreComment),
        _buildImageList('Photos', entretien.evacuationEncreImage),

        pw.Divider(
          height: 1,
          color: const PdfColor.fromInt(0xFF00FFC8),
        ),

        _buildDetailItem('Niveau encre', entretien.niveauEncreSelection),
        _buildDetailItem('Commentaire', entretien.niveauEncreComment),
        _buildImageList('Photos', entretien.niveauEncreImage),

        pw.Divider(
          height: 1,
          color: const PdfColor.fromInt(0xFF00FFC8),
        ),

        _buildDetailItem('Station encre, Wiper, Pompe...', entretien.photoStationEncreComment),
        _buildImageList('Photos', entretien.photoStationEncreImage),

        pw.Divider(
          height: 1,
          color: const PdfColor.fromInt(0xFF00FFC8),
        ),

        _buildDetailItem('Nozzel Test', entretien.nozzelComment),
        _buildImageList('Photos', entretien.nozzelImage),

        pw.Divider(
          height: 1,
          color: const PdfColor.fromInt(0xFF00FFC8),
        ),

        _buildSectionTitle(
          'Détails techniques',
          const PdfColor.fromInt(0xFF0000FF),
        ),
        _buildDetailItem("Régulateur tension", entretien.regulTension),
        _buildDetailItem("Capacité régulateur", entretien.capaRegulTension),
        _buildDetailItem("Prise Terre", entretien.priseT),
        _buildDetailItem("Local", entretien.local),
        _buildDetailItem("Temperature", entretien.temp),
        _buildDetailItem("Encre Jaguar x-Print", entretien.encreJxP),
        _buildDetailItem("Nettoyant Jaguar x-Print", entretien.netJxP),
        _buildDetailItem(
          "Etat Général de l'imprimante",
          entretien.etatGenIm,
        ),

        // Interventions
        _buildSectionTitle(
          'Interventions',
          const PdfColor.fromInt(0xFF0000FF),
        ),
        _buildDetailItem('Problème Client', entretien.problemeDecrit),
        _buildDetailItem('Problème Estimé', entretien.problemeEstime),
        _buildDetailItem('Changement tête', entretien.changTete),
        _buildDetailItem('Changement Caps', entretien.changCaps),
        _buildDetailItem('Dampers', entretien.dampers),
        _buildDetailItem('Wiper', entretien.wiper),
        _buildDetailItem('Changement de pompe', entretien.changPom),
        _buildDetailItem('Graissage du Rail', entretien.graisRail),
        _buildDetailItem('Changement Encoder', entretien.changEncod),
        _buildDetailItem('Changement Raster', entretien.changRast),

        // À prévoir d'urgence
        _buildSectionTitle(
          "À prévoir d'urgence",
          const PdfColor.fromInt(0xFFFF0000),
        ),
        _buildDetailItem("Caps", entretien.capsU),
        _buildDetailItem("Dampers", entretien.dampersU),
        _buildDetailItem("Wiper", entretien.wiperU),
        _buildDetailItem("Pompe", entretien.pompeU),
        _buildDetailItem("Roulement du Rail", entretien.roulRailU),
        _buildDetailItem("Changement Encoder", entretien.changEncodU),
        _buildDetailItem("Changement Raster", entretien.changRastU),

        // Conclusion
        _buildSectionTitle("Conclusion", const PdfColor.fromInt(0xFF00FF00)),
        _buildDetailItem("Problème résolu", entretien.probRes),
        _buildDetailItem("Constat après intervention", entretien.problemePostIntervention),
      ],
    );
  }

  static pw.Widget _buildSignatureSection(String signaturePath) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 16),
        pw.Text(
          'Signature client :',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Image(
          pw.MemoryImage(File(signaturePath).readAsBytesSync()),
          width: 150,
          height: 80,
        ),
      ],
    );
  }

  static pw.Widget _buildSectionTitle(String title, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 16, bottom: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
          color: color,
          decoration: pw.TextDecoration.underline,
        ),
      ),
    );
  }

  static pw.Widget _buildDetailItem(String label, String? value) {
    final text = value ?? 'Non spécifié';

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "$label:",
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            text,
            style: const pw.TextStyle(),
            softWrap: true, // Activation du retour à la ligne
            maxLines: null, // Nombre illimité de lignes
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildImageList(String label, List<String>? imagePaths) {
    if (imagePaths == null || imagePaths.isEmpty) {
      return pw.SizedBox();
    }

    final validImages = imagePaths.where((path) => File(path).existsSync()).toList();
    if (validImages.isEmpty) return pw.SizedBox();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          "$label :",
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Wrap(
          spacing: 10,
          runSpacing: 10,
          children: validImages.map((path) {
            return pw.Container(
              width: 150,
              height: 100,
              child: pw.Image(
                pw.MemoryImage(File(path).readAsBytesSync()),
                fit: pw.BoxFit.cover,
              ),
            );
          }).toList(),
        ),
        pw.SizedBox(height: 10),
      ],
    );
  }
}