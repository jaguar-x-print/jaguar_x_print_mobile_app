import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaguar_x_print/api/database.dart';
import 'package:jaguar_x_print/bloc/entretien/entretien_bloc.dart';
import 'package:jaguar_x_print/bloc/entretien/entretien_event.dart';
import 'package:jaguar_x_print/bloc/entretien/entretien_state.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/models/contact_model.dart';
import 'package:jaguar_x_print/models/entretien_model.dart';
import 'package:jaguar_x_print/views/entretien/pages/page_3_6.dart';
import 'package:jaguar_x_print/widgets/appbar_widget.dart';
import 'package:jaguar_x_print/widgets/card/client_name_card.dart';
import 'package:intl/intl.dart';
import 'package:jaguar_x_print/widgets/entretien/elements/evacuation_encre.dart';
import 'package:jaguar_x_print/widgets/entretien/elements/niveau_encre.dart';
import 'package:jaguar_x_print/widgets/entretien/elements/nozzel.dart';
import 'package:jaguar_x_print/widgets/entretien/elements/photo_station_encre.dart';
import 'package:jaguar_x_print/widgets/entretien/elements/printer_environment_card.dart';

class CommencerEntretienPage extends StatefulWidget {
  const CommencerEntretienPage({super.key, required this.contact});

  final Contact contact;

  @override
  State<CommencerEntretienPage> createState() => _CommencerEntretienPageState();
}

class _CommencerEntretienPageState extends State<CommencerEntretienPage> {
  String? _evacuationEncreComment;
  String? _niveauEncreComment;
  String? _niveauEncreSelection;
  String? _nozzelComment;
  String? _photoStationEncreComment;
  String? _printerEnvironmentComment;
  List<File?> _printerEnvironmentImage = [];
  List<File?> _evacuationEncreImage = [];
  List<File?> _niveauEncreImage = [];
  List<File?> _photoStationEncreImage = [];
  List<File?> _nozzelImage = [];

  DateTime _selectedDate = DateTime.now();
  final TimeOfDay _selectedTime = TimeOfDay.now();

  bool _isSaving = false;
  bool _hasUnsavedChanges = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  bool _validateFields() {
    if (_printerEnvironmentComment == null || _printerEnvironmentComment!.isEmpty) return false;
    if (_evacuationEncreComment == null || _evacuationEncreComment!.isEmpty) return false;
    if (_niveauEncreComment == null || _niveauEncreComment!.isEmpty) return false;
    if (_niveauEncreSelection == null || _niveauEncreSelection!.isEmpty) return false;
    if (_photoStationEncreComment == null || _photoStationEncreComment!.isEmpty) return false;
    if (_nozzelComment == null || _nozzelComment!.isEmpty) return false;

    if (_printerEnvironmentImage.where((f) => f != null).isEmpty) return false;
    if (_evacuationEncreImage.where((f) => f != null).isEmpty) return false;
    if (_niveauEncreImage.where((f) => f != null).isEmpty) return false;
    if (_photoStationEncreImage.where((f) => f != null).isEmpty) return false;
    if (_nozzelImage.where((f) => f != null).isEmpty) return false;

    return true;
  }


  void _saveData() async {
    try {
      setState(() => _isSaving = true);
      EasyLoading.show(status: 'Sauvegarde en cours...');

      final entretien = Entretien(
        contactId: widget.contact.id!,
        heureArrivee: _selectedTime.format(context),
        printerEnvironmentComment: _printerEnvironmentComment,
        evacuationEncreComment: _evacuationEncreComment,
        niveauEncreComment: _niveauEncreComment,
        niveauEncreSelection: _niveauEncreSelection,
        photoStationEncreComment: _photoStationEncreComment,
        nozzelComment: _nozzelComment,
        printerEnvironmentImage: _printerEnvironmentImage
            .where((f) => f != null)
            .map((f) => f!.path)
            .toList(),
        evacuationEncreImage: _evacuationEncreImage
            .where((f) => f != null)
            .map((f) => f!.path)
            .toList(),
        niveauEncreImage: _niveauEncreImage
            .where((f) => f != null)
            .map((f) => f!.path)
            .toList(),
        photoStationEncreImage: _photoStationEncreImage
            .where((f) => f != null)
            .map((f) => f!.path)
            .toList(),
        nozzelImage: _nozzelImage
            .where((f) => f != null)
            .map((f) => f!.path)
            .toList(),
      );

      final databaseHelper = DatabaseHelper();
      final entretienId = await databaseHelper.insertEntretien(entretien);

      // Mettre à jour l'ID de l'entretien
      final updatedEntretien = entretien.copyWith(id: entretienId);

      // Mettre à jour le bloc avec l'entretien mis à jour
      context.read<EntretienBloc>().add(
        SaveEntretienEvent(updatedEntretien.toMap()),
      );

      if (kDebugMode) {
        print(updatedEntretien.toMap());
      }

      setState(() => _hasUnsavedChanges = false);
      EasyLoading.dismiss();

      // Naviguer vers la page suivante après la sauvegarde
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Page3(contact: widget.contact),
        ),
      );
    } catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: BlocListener<EntretienBloc, EntretienState>(
        listener: (context, state) {
          if (state is EntretienSavedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: greenColor,
                content: Text(
                  'Données enregistrées avec succès !',
                  style: TextStyle(
                    color: blackColor,
                  ),
                ),
              ),
            );
          }
        },
        child: Scaffold(
          body: Column(
            children: [
              const AppBarWidget(
                imagePath: "assets/menu/entretien1.jpg",
                textColor: whiteColor,
                title: "Entretien",
              ),
              SizedBox(height: 0.5.h),
              ClientNameCard(
                contact: widget.contact,
                page: '2/6',
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: Adaptive.h(1)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Row(
                        children: [
                          Text(
                            "Date: ",
                            style: TextStyle(fontSize: Adaptive.sp(16)),
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy').format(_selectedDate),
                            style: TextStyle(fontSize: Adaptive.sp(16)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: Adaptive.w(10)),
                    Row(
                      children: [
                        Text(
                          "Heure d'arrivée: ",
                          style: TextStyle(fontSize: Adaptive.sp(16)),
                        ),
                        Text(
                          _selectedTime.format(context),
                          style: TextStyle(
                            color: blackColor,
                            fontSize: Adaptive.sp(16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      PrinterEnvironmentCard(
                        onImagesPicked: (images) {
                          setState(() {
                            _printerEnvironmentImage = images;
                            _hasUnsavedChanges = true;
                          });
                        },
                        onCommentChanged: (comment) {
                          setState(() {
                            _printerEnvironmentComment = comment;
                            _hasUnsavedChanges = true;
                          });
                        },
                      ),
                      SizedBox(height: Adaptive.h(2)),
                      EvacuationEncreCard(
                        onImagesPicked: (images) {
                          setState(() {
                            _evacuationEncreImage = images;
                            _hasUnsavedChanges = true;
                          });
                        },
                        onCommentChanged: (comment) {
                          setState(() {
                            _evacuationEncreComment = comment;
                            _hasUnsavedChanges = true;
                          });
                        },
                      ),
                      SizedBox(height: Adaptive.h(2)),
                      NiveauEncreCard(
                        onImagesPicked: (images) {
                          setState(() {
                            _niveauEncreImage = images;
                            _hasUnsavedChanges = true;
                          });
                        },
                        onCommentChanged: (comment) {
                          setState(() {
                            _niveauEncreComment = comment;
                            _hasUnsavedChanges = true;
                          });
                        },
                        onNiveauChanged: (niveau) {
                          setState(() {
                            _niveauEncreSelection = niveau;
                            _hasUnsavedChanges = true;
                          });
                        },
                      ),
                      SizedBox(height: Adaptive.h(2)),
                      PhotoStationEncreCard(
                        onImagesPicked: (image) {
                          setState(() {
                            _photoStationEncreImage = image;
                            _hasUnsavedChanges = true;
                          });
                        },
                        onCommentChanged: (comment) {
                          setState(() {
                            _photoStationEncreComment = comment;
                            _hasUnsavedChanges = true;
                          });
                        },
                      ),
                      SizedBox(height: Adaptive.h(2)),
                      NozzelCard(
                        onImagesPicked: (image) {
                          setState(() {
                            _nozzelImage = image;
                            _hasUnsavedChanges = true;
                          });
                        },
                        onCommentChanged: (comment) {
                          setState(() {
                            _nozzelComment = comment;
                            _hasUnsavedChanges = true;
                          });
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.all(Adaptive.w(2)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color3,
                                foregroundColor: whiteColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: Adaptive.sp(13),
                                  ),
                                  SizedBox(width: Adaptive.w(1)),
                                  Text(
                                    'Précédent',
                                    style: TextStyle(fontSize: Adaptive.sp(14)),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _isSaving
                                  ? null
                                  : () {
                                if (_validateFields()) {
                                  _saveData();
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text(
                                        "Champs requis manquants",
                                      ),
                                      content: const Text(
                                          "Veuillez remplir toutes les sections !",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text("OK"),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color3,
                                foregroundColor: whiteColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Suivant',
                                    style: TextStyle(fontSize: Adaptive.sp(14)),
                                  ),
                                  SizedBox(width: Adaptive.w(1)),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: Adaptive.sp(13)
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) {
      return true;
    }

    final shouldPop = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Données non sauvegardées"),
        content: const Text('Voulez-vous vraiment quitter sans sauvegarder ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }
}