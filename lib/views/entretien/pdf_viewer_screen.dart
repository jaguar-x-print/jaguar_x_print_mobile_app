import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/models/contact_model.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfPath;
  final Contact contact;

  const PdfViewerScreen({
    super.key,
    required this.pdfPath,
    required this.contact,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late PdfControllerPinch _pdfController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      _pdfController = PdfControllerPinch(
        document: PdfDocument.openFile(widget.pdfPath),
      );
      setState(() => _isLoading = false);
    } catch (e) {
      _showError('Erreur de chargement : $e');
      Navigator.pop(context);
    }
  }

  Future<void> _savePdf() async {
    try {
      // Demander à l'utilisateur de choisir un dossier
      final String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Choisir un dossier pour enregistrer le PDF',
      );

      if (selectedDirectory == null || selectedDirectory.isEmpty) {
        // L'utilisateur a annulé
        return;
      }

      EasyLoading.show(status: 'Sauvegarde en cours...');

      // Créer le nom du fichier
      final sanitizedName = widget.contact?.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_') ?? "document";
      final fileName = 'Rapport_entretien_${sanitizedName}_${DateFormat("yyyyMMdd_HHmmss").format(DateTime.now())}.pdf';
      final newPath = '$selectedDirectory/$fileName';

      // Copier le fichier
      await File(widget.pdfPath).copy(newPath);

      EasyLoading.dismiss();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Fichier sauvegardé dans $selectedDirectory",
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      EasyLoading.dismiss();
      _showError('Erreur de sauvegarde : $e');
    }
  }

  Future<void> _sharePdf() async {
    try {
      await Share.shareXFiles(
        [
          XFile(
            widget.pdfPath,
            mimeType: 'application/pdf',
          )
        ],
        text: 'Rapport d\'entretien Jaguar x-Print',
      );
    } catch (e) {
      _showError('Erreur de partage : $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: redColor,
      ),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rapport d\'entretien',
          style: TextStyle(fontSize: Adaptive.sp(16)),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: Adaptive.w(6),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save_alt, size: Adaptive.w(6)),
            onPressed: _savePdf,
            tooltip: 'Sauvegarder le PDF',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sharePdf,
        tooltip: 'Partager le PDF',
        backgroundColor: color3,
        child: Icon(
          Icons.share,
          color: whiteColor,
          size: Adaptive.w(7),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Container(
            padding: EdgeInsets.all(Adaptive.w(3)),
            color: yellowColor.withOpacity(0.2),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: yellowColor,
                  size: Adaptive.w(5),
                ),
                SizedBox(width: Adaptive.w(3)),
                Expanded(
                  child: Text(
                    "Veuillez bien vérifier le document avant de l'enregistrer",
                    style: TextStyle(
                      fontSize: Adaptive.sp(12),
                      color: blackColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PdfViewPinch(
              controller: _pdfController,
              scrollDirection: Axis.vertical,
              onDocumentError: (error) => _showError(error.toString()),
            ),
          ),
        ],
      ),
    );
  }
}