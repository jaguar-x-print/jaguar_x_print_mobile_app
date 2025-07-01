import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:intl/intl.dart';
import 'package:jaguar_x_print/api/database.dart';
import 'package:jaguar_x_print/models/entretien_model.dart';
import 'package:jaguar_x_print/views/entretien/pages/pdf_service.dart';
import 'package:jaguar_x_print/views/entretien/pdf_viewer_screen.dart';
import 'package:jaguar_x_print/widgets/appbar_widget.dart';
import 'package:jaguar_x_print/widgets/menu/tab_menu.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/models/contact_model.dart';
import 'package:jaguar_x_print/widgets/card/client_name_card.dart';
import 'package:jaguar_x_print/widgets/entretien/tools/dropdown.dart';
import 'package:jaguar_x_print/widgets/fields/text_input_field.dart';

class Page6 extends StatefulWidget {
  const Page6({super.key, required this.contact});
  final Contact contact;

  @override
  State<Page6> createState() => _Page6State();
}

class _Page6State extends State<Page6> {
  late Entretien _entretien;
  final GlobalKey<SfSignaturePadState> _signatureKey = GlobalKey();
  final TextEditingController _problemePostInterventionController = TextEditingController();
  File? _signatureImage;
  File? _pdfFile;
  DateTime? _signatureTime;
  bool _isLoading = true;
  bool _isPdfGenerated = false;
  bool _isSaving = false; // Nouvel état pour suivre l'enregistrement

  @override
  void initState() {
    super.initState();
    _loadEntretien();
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  Future<void> _loadEntretien() async {
    try {
      final dbHelper = DatabaseHelper();
      List<Entretien> entretiens = await dbHelper.getEntretiensByContact(
        widget.contact.id!,
      );

      if (entretiens.isNotEmpty) {
        setState(() {
          _entretien = entretiens.last.copyWith(
            date: _formatDate(DateTime.now()),
          );
          _problemePostInterventionController.text = _entretien.problemePostIntervention ?? '';
          if (_entretien.signatureImagePath != null) {
            _signatureImage = File(_entretien.signatureImagePath!);
          }
          if (_entretien.signatureTime != null) {
            _signatureTime = DateTime.parse(_entretien.signatureTime!);
          }
          _isLoading = false;
        });
      } else {
        final now = DateTime.now();
        final formattedDate = _formatDate(now);
        final newEntretien = Entretien(
          contactId: widget.contact.id!,
          date: formattedDate,
          probRes: 'Non',
        );
        await dbHelper.insertEntretien(newEntretien);
        setState(() {
          _entretien = newEntretien;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      EasyLoading.showError('Erreur de chargement: ${e.toString()}');
    }
  }

  Future<bool> _saveSignature() async {
    try {
      if (_signatureKey.currentState == null) return false;

      final image = await _signatureKey.currentState!.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        await file.writeAsBytes(byteData.buffer.asUint8List());

        setState(() {
          _signatureImage = file;
          _signatureTime = DateTime.now();
          _entretien = _entretien.copyWith(
            signatureImagePath: file.path,
            signatureTime: _signatureTime.toString(),
          );
        });
        return true;
      }
      return false;
    } catch (e) {
      EasyLoading.showError('Erreur de sauvegarde de la signature : ${e.toString()}');
      return false;
    }
  }

  Future<void> _saveData() async {
    try {
      EasyLoading.show(status: 'Sauvegarde en cours...');

      _entretien = _entretien.copyWith(
        date: _formatDate(DateTime.now()),
        probRes: _entretien.probRes,
        problemePostIntervention: _problemePostInterventionController.text,
      );

      final dbHelper = DatabaseHelper();
      await dbHelper.updateEntretien(_entretien);

      EasyLoading.showSuccess('Données sauvegardées !');
    } catch (e) {
      EasyLoading.showError('Erreur de sauvegarde : ${e.toString()}');
    }
  }

  void _clearSignature() {
    _signatureKey.currentState?.clear();
    setState(() {
      _signatureImage = null;
      _signatureTime = null;
      _entretien = _entretien.copyWith(
        signatureImagePath: null,
        signatureTime: null,
      );
    });
  }

  Future<void> _handleSave() async {
    if (_signatureKey.currentState == null) {
      EasyLoading.showError('Signature requise !');
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 1. Sauvegarder la signature
      final signatureSaved = await _saveSignature();
      if (!signatureSaved) {
        EasyLoading.showError('Échec de la sauvegarde de la signature');
        return;
      }

      // 2. Sauvegarder les données
      await _saveData();

      // 3. Générer le PDF
      await _generatePdf();

      // 4. Mettre à jour l'interface
      setState(() {
        _isPdfGenerated = true;
        _isSaving = false;
      });

      EasyLoading.showSuccess('Toutes les opérations terminées !');
    } catch (e) {
      setState(() => _isSaving = false);
      EasyLoading.showError('Erreur lors de l\'enregistrement : ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 1.h),
          const AppBarWidget(
            imagePath: "assets/menu/entretien1.jpg",
            textColor: whiteColor,
            title: "Entretien",
          ),
          SizedBox(height: 0.5.h),
          ClientNameCard(
            contact: widget.contact,
            page: "6/6",
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(Adaptive.w(3)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EntretienDropdown(
                    label: "Problème Résolu :",
                    value: _entretien.probRes ?? "Non",
                    items: const ["Oui", "Non"],
                    onChanged: (v) {
                      setState(() {
                        _entretien = _entretien.copyWith(probRes: v);
                      });
                    },
                  ),
                  SizedBox(height: Adaptive.h(2)),
                  InputField(
                    controller: _problemePostInterventionController,
                    focus: false,
                    minLines: 5,
                    hint: "Constat après intervention...",
                    hintColor: whiteColor,
                    backColor: color3,
                    textColor: whiteColor,
                    keyboardType: TextInputType.multiline,
                    onTap: () {},
                    readOnly: _isPdfGenerated,
                  ),
                  SizedBox(height: Adaptive.h(2)),
                  Text(
                    "Signature client",
                    style: TextStyle(
                      fontSize: Adaptive.sp(15),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Adaptive.h(1)),

                  if (!_isPdfGenerated)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: Adaptive.h(20),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: blackColor,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SfSignaturePad(
                            key: _signatureKey,
                            backgroundColor: whiteColor,
                            strokeColor: blackColor,
                            minimumStrokeWidth: 1.0,
                            maximumStrokeWidth: 4.0,
                          ),
                        ),
                        SizedBox(height: Adaptive.h(1)),
                        ElevatedButton(
                          onPressed: _clearSignature,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color3,
                            foregroundColor: whiteColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Effacer la signature"),
                        ),
                      ],
                    ),

                  if (_isPdfGenerated)
                    Container(
                      padding: EdgeInsets.all(Adaptive.w(5)),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "Signature enregistrée et PDF généré",
                          style: TextStyle(
                            fontSize: Adaptive.sp(15),
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),

                  if (_signatureTime != null) ...[
                    SizedBox(height: Adaptive.h(2)),
                    Center(
                      child: Text(
                        "Heure de départ: ${DateFormat('HH:mm').format(
                          _signatureTime!,
                        )}",
                        style: TextStyle(
                          fontSize: Adaptive.sp(15),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Column(
            children: [
              _buildActionButton(
                text: 'Enregistrer',
                icon: Icons.save,
                onPressed: (_isPdfGenerated || _isSaving) ? null : _handleSave,
                color: color3,
              ),
              SizedBox(height: Adaptive.h(0.7)),
              _buildActionButton(
                text: 'Visualiser PDF',
                icon: Icons.visibility,
                onPressed: _isPdfGenerated ? _viewPdf : null,
                color: color3,
              ),
              SizedBox(height: Adaptive.h(0.7)),
              _buildActionButton(
                text: 'Sortir',
                icon: Icons.logout,
                onPressed: _exit,
                color: color3,
              ),
              SizedBox(height: Adaptive.h(0.7)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return SizedBox(
      width: Adaptive.w(80),
      height: Adaptive.h(4.5),
      child: ElevatedButton.icon(
        icon: Icon(
          icon,
          size: Adaptive.sp(14),
        ),
        label: Text(text),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: whiteColor,
          padding: EdgeInsets.symmetric(
            horizontal: Adaptive.w(3),
            vertical: Adaptive.h(1),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  Future<void> _generatePdf() async {
    try {
      EasyLoading.show(status: 'Génération PDF...');

      if (_entretien.signatureImagePath == null) {
        throw Exception("Aucun chemin de signature trouvé");
      }

      final pdfFile = await PdfService.generateEntretienPdf(
        contact: widget.contact,
        entretien: _entretien,
        signaturePath: _entretien.signatureImagePath!,
      );

      setState(() {
        _pdfFile = pdfFile;
      });

      EasyLoading.showSuccess('Génération terminée !');
    } catch (e) {
      EasyLoading.showError('Erreur de génération: ${e.toString()}');
      rethrow;
    }
  }

  void _viewPdf() async {
    if (_pdfFile == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(
          pdfPath: _pdfFile!.path,
          contact: widget.contact,
        ),
      ),
    );
  }

  void _exit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TabBarMenu(),
      ),
    );
  }
}