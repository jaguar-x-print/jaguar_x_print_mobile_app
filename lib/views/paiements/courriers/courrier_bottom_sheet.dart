import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/bloc/courrier/courrier_bloc.dart';
import 'package:jaguar_x_print/bloc/courrier/courrier_event.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/models/courrier_model.dart';
import 'package:jaguar_x_print/widgets/fields/text_input_field.dart';
import 'package:path_provider/path_provider.dart';

class CourrierBottomSheet extends StatefulWidget {
  final VoidCallback onCourrierAdded;
  final int contactId;
  final Courrier? existingCourrier;

  const CourrierBottomSheet({
    super.key,
    required this.onCourrierAdded,
    required this.contactId,
    this.existingCourrier,
  });

  @override
  State<CourrierBottomSheet> createState() => _CourrierBottomSheetState();
}

class _CourrierBottomSheetState extends State<CourrierBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  PlatformFile? _selectedFile;
  final TextEditingController _dateController = TextEditingController();

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd MMMM yyyy', 'fr_FR').format(
          picked,
        );
      });
    }
  }

  // Modifier _pickDocument pour lire les bytes
  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );

    if (result != null) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  // Modifier la méthode _submit
  void _submit() async {
    if (_formKey.currentState!.validate() && _selectedFile != null) {
      try {
        // Sauvegarde locale
        final localFile = await _saveFileLocally(_selectedFile!);

        // Upload du fichier vers le serveur
        final uploadResponse = await _uploadFileToServer(_selectedFile!);
        final serverUrl = uploadResponse['url'];

        // Envoyer l'événement au Bloc avec l'URL du serveur
        context.read<CourrierBloc>().add(
          AddCourrierEvent(
            contactId: widget.contactId,
            date: _selectedDate!,
            dateFormatted: _dateController.text,
            documentPath: localFile.path,
            serverDocumentUrl: serverUrl,
          ),
        );

        Navigator.pop(context);
        widget.onCourrierAdded.call();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<File> _saveFileLocally(PlatformFile platformFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final file = File('${appDir.path}/${platformFile.name}');
    return file.writeAsBytes(platformFile.bytes!);
  }

  Future<Map<String, dynamic>> _uploadFileToServer(PlatformFile platformFile) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.118:3000/api/upload'),
    );

    // Ajout du fichier
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      platformFile.bytes!,
      filename: platformFile.name,
      contentType: _getMediaType(platformFile.extension),
    ));

    // En-têtes et traitement de la réponse
    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception(
        'Échec de l\'upload: ${jsonDecode(responseData)['error']}',
      );
    }

    return jsonDecode(responseData);
  }

  MediaType _getMediaType(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return MediaType('application', 'pdf');
      case 'jpg':
        return MediaType('image', 'jpg');
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            InputField(
              focus: true,
              onTap: _pickDate,
              prefixIcon: Icons.calendar_today_rounded,
              controller: _dateController,
              hint: "Date du courrier",
              textColor: blackColor,
              backColor: whiteColor,
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Champ obligatoire';
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: const Text('Joindre un document'),
              onPressed: _pickDocument,
              style: ElevatedButton.styleFrom(
                backgroundColor: greenYellowColor,
                foregroundColor: blackColor,
              ),
            ),
            if (_selectedFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Document sélectionné : ${_selectedFile!.name}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: firstColor,
                foregroundColor: whiteColor,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Ajouter le courrier'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.all(Adaptive.w(2)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  Adaptive.w(7),
                ),
                color: firstColor,
              ),
              height: Adaptive.h(0.6),
              width: Adaptive.w(25),
            ),
          ),
        ),
        SizedBox(height: Adaptive.h(1)),
        Center(
          child: Text(
            "Ajouter un courrier",
            style: TextStyle(
              fontSize: Adaptive.sp(18),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: Adaptive.h(2)),
      ],
    );
  }
}
