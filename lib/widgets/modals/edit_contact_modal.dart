import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jaguar_x_print/bloc/contact_cubit.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/constant/confirmation_suppression_widget.dart';
import 'package:jaguar_x_print/models/classes/collaborator.dart';
import 'package:jaguar_x_print/models/contact_model.dart';
import 'package:jaguar_x_print/widgets/clients/custom_phone_field.dart';
import 'package:jaguar_x_print/widgets/fields/datefield.dart';
import 'package:jaguar_x_print/widgets/fields/text_input_field.dart';
import 'package:jaguar_x_print/widgets/modals/add_contact_modal.dart';

class EditContactModal extends StatefulWidget {
  final Contact contact;
  final TextEditingController nameController;
  final List<TextEditingController> phoneControllers;
  final TextEditingController whatsappController;
  final TextEditingController quartierController;
  final TextEditingController villeController;
  final TextEditingController groupeSAVController;
  final TextEditingController montantController;
  final TextEditingController dateDebutController;
  final TextEditingController dateFinController;
  final TextEditingController jourPaiementController;
  final TextEditingController companyNameController;
  final TextEditingController jobTitleController;
  final TextEditingController dateInstallationMachineController;

  const EditContactModal({
    super.key,
    required this.contact,
    required this.nameController,
    required this.phoneControllers,
    required this.whatsappController,
    required this.quartierController,
    required this.villeController,
    required this.groupeSAVController,
    required this.montantController,
    required this.dateDebutController,
    required this.dateFinController,
    required this.jourPaiementController,
    required this.companyNameController,
    required this.jobTitleController,
    required this.dateInstallationMachineController,
  });

  @override
  State<EditContactModal> createState() => _EditContactModalState();
}

class _EditContactModalState extends State<EditContactModal> {
  List<Collaborator> collaborators = [];
  late String pCountryCode;
  late String wCountryCode;
  late List<PhoneEntry> phoneEntries;
  late PhoneEntry whatsappEntry;

  @override
  void initState() {
    super.initState();
    _initializeCollaborators();
    _initializePhoneControllers();
    _initializePhoneData();
    pCountryCode = widget.contact.pCountryCode ?? 'CM';
    wCountryCode = widget.contact.wCountryCode ?? 'CM';
  }

  void _initializeCollaborators() {
    if (widget.contact.collaborators != null &&
        widget.contact.collaborators!.isNotEmpty) {
      List<dynamic> collaboratorsData = jsonDecode(
        widget.contact.collaborators!,
      );
      collaborators = collaboratorsData
          .map(
            (data) => Collaborator.fromJson(data),
          )
          .toList();
    }
  }

  void _initializePhoneControllers() {
    widget.phoneControllers.clear();
    for (String fullPhoneNumber in widget.contact.phone) {
      widget.phoneControllers.add(
        TextEditingController(text: fullPhoneNumber),
      );
    }
  }

  void _initializePhoneData() {
    // Initialisation des numéros principaux
    phoneEntries = widget.contact.phone.map((num) {
      final parsed = _parsePhoneNumber(num);
      return PhoneEntry(
        dialCode: parsed['dialCode']!,
        controller: TextEditingController(
          text: parsed['formattedNumber'] ?? '',
        ),
      );
    }).toList();

    // Initialisation WhatsApp
    if (widget.contact.whatsapp.isNotEmpty) {
      final whatsappParsed = _parsePhoneNumber(widget.contact.whatsapp);
      whatsappEntry = PhoneEntry(
        dialCode: whatsappParsed['dialCode']!,
        controller: widget.whatsappController
          ..text = whatsappParsed['formattedNumber'] ?? '',
      );
    } else {
      whatsappEntry = PhoneEntry(
        dialCode: '+237',
        controller: TextEditingController(),
      );
    }
  }

  Map<String, String> _parsePhoneNumber(String fullNumber) {
    // Nettoyer le numéro
    final cleaned = fullNumber.replaceAll(RegExp(r'\D'), '');

    // Vérifier si le numéro commence par le code pays
    String formattedNumber = cleaned;
    if (cleaned.startsWith('237') && cleaned.length > 3) {
      formattedNumber = cleaned.substring(3);
    }

    return {
      'dialCode': '+237',
      'formattedNumber': formattedNumber,
    };
  }

  void _addPhoneField() {
    setState(() {
      widget.phoneControllers.add(TextEditingController());
    });
  }

  void _removePhoneField(int index) {
    setState(() {
      widget.phoneControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Confirmer la sortie"),
                content: Text(
                  "Êtes-vous sûr de vouloir quitter ? Toutes les données non enregistrées seront perdues.",
                  style: TextStyle(
                    fontSize: Adaptive.sp(13),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      "Annuler",
                      style: TextStyle(
                        color: redColor,
                        fontSize: Adaptive.sp(17),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      "Confirmer",
                      style: TextStyle(
                        color: green2Color,
                        fontSize: Adaptive.sp(17),
                      ),
                    ),
                  ),
                ],
              ),
            ) ??
            false;
      },
      child: Padding(
        padding: EdgeInsets.all(Adaptive.w(4)),
        child: SingleChildScrollView(
          padding: MediaQuery.of(context).viewInsets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(Adaptive.w(2)),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        Adaptive.w(7),
                      ),
                      color: redColor,
                    ),
                    height: Adaptive.h(0.6),
                    width: Adaptive.w(25),
                  ),
                ),
              ),
              SizedBox(height: Adaptive.h(0.5)),
              Center(
                child: Text(
                  "Modifier un contact",
                  style: TextStyle(
                    fontSize: Adaptive.sp(20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: Adaptive.h(2)),
              Text(
                "Nom du client",
                style: TextStyle(
                  fontSize: Adaptive.sp(12),
                ),
              ),
              InputField(
                onTap: () {},
                focus: true,
                textColor: blackColor,
                backColor: whiteColor,
                hint: "Nom du client",
                prefixIcon: Icons.person_2_rounded,
                controller: widget.nameController,
              ),

              SizedBox(height: Adaptive.h(0.8)),
              Text(
                "Nom de l'entreprise",
                style: TextStyle(
                  fontSize: Adaptive.sp(12),
                ),
              ),
              InputField(
                onTap: () {},
                focus: true,
                textColor: blackColor,
                backColor: whiteColor,
                hint: "Nom de l'entreprise",
                prefixIcon: Icons.business_center_rounded,
                controller: widget.companyNameController,
              ),

              for (int i = 0; i < widget.phoneControllers.length; i++)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: Adaptive.h(0.8)),
                    Text(
                      "Téléphone N°${i + 1} du client",
                      style: TextStyle(
                        fontSize: Adaptive.sp(12),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CustomPhoneField(
                            focus: true,
                            hint: "xxx...",
                            initialCountryCode: phoneEntries[i].dialCode,
                            controller: phoneEntries[i].controller,
                            onChange: (dialCode, number) {
                              setState(() {
                                phoneEntries[i].dialCode = dialCode;
                                // SUPPRIMEZ CETTE LIGNE
                                // phoneEntries[i].controller.text = number;
                              });
                            },
                          ),
                        ),
                        if (widget.phoneControllers.length > 1)
                          IconButton(
                            onPressed: () => _removePhoneField(i),
                            icon: Icon(
                              Icons.remove_circle_rounded,
                              color: redColor,
                              size: Adaptive.sp(24),
                            ),
                          ),
                        IconButton(
                          onPressed: _addPhoneField,
                          icon: Icon(
                            Icons.add_circle_rounded,
                            color: firstColor,
                            size: Adaptive.sp(24),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

              SizedBox(height: Adaptive.h(0.8)),
              Text(
                "Contact WhatsApp",
                style: TextStyle(fontSize: Adaptive.sp(12)),
              ),
              CustomPhoneField(
                focus: true,
                hint: "xxx...",
                initialCountryCode: whatsappEntry.dialCode,
                controller: whatsappEntry.controller,
                suffixIcon: FontAwesomeIcons.whatsapp,
                onChange: (dialCode, number) {
                  setState(() {
                    whatsappEntry.dialCode = dialCode;
                    // SUPPRIMEZ CETTE LIGNE
                    // whatsappEntry.controller.text = number;
                  });
                },
              ),

              SizedBox(height: Adaptive.h(0.8)),
              Text(
                "Groupe SAV",
                style: TextStyle(
                  fontSize: Adaptive.sp(12),
                ),
              ),
              InputField(
                onTap: () {},
                focus: true,
                textColor: blackColor,
                backColor: whiteColor,
                hint: "Groupe SAV",
                prefixIcon: Icons.group_rounded,
                controller: widget.groupeSAVController,
              ),

              SizedBox(height: Adaptive.h(0.8)),
              Text(
                "Poste occupé",
                style: TextStyle(
                  fontSize: Adaptive.sp(12),
                ),
              ),
              InputField(
                onTap: () {},
                focus: true,
                textColor: blackColor,
                backColor: whiteColor,
                hint: "Poste occupé",
                prefixIcon: Icons.work,
                controller: widget.jobTitleController,
              ),

              SizedBox(height: Adaptive.h(1)),
              Text(
                "Collaborateurs",
                style: TextStyle(
                  fontSize: Adaptive.sp(14),
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Display collaborators
              for (int i = 0; i < collaborators.length; i++)
                _buildCollaboratorWidget(i),

              TextButton.icon(
                onPressed: _addCollaborator,
                icon: Icon(
                  Icons.add,
                  size: Adaptive.sp(20),
                ),
                label: Text(
                  "Ajouter un collaborateur",
                  style: TextStyle(
                    fontSize: Adaptive.sp(14),
                  ),
                ),
              ),

              SizedBox(height: Adaptive.h(0.8)),
              Text(
                "Adresse (Quartier)",
                style: TextStyle(
                  fontSize: Adaptive.sp(12),
                ),
              ),
              InputField(
                onTap: () {},
                focus: true,
                hint: "Quartier",
                textColor: blackColor,
                backColor: whiteColor,
                prefixIcon: Icons.location_city_rounded,
                controller: widget.quartierController,
              ),

              SizedBox(height: Adaptive.h(0.8)),
              Text(
                "Adresse (Ville)",
                style: TextStyle(
                  fontSize: Adaptive.sp(12),
                ),
              ),
              InputField(
                onTap: () {},
                focus: true,
                hint: "Ville",
                textColor: blackColor,
                backColor: whiteColor,
                prefixIcon: Icons.location_city_rounded,
                controller: widget.villeController,
              ),

              SizedBox(height: Adaptive.h(0.8)),
              Text(
                "Date d'installation machine",
                style: TextStyle(
                  fontSize: Adaptive.sp(12),
                ),
              ),
              DateField(
                onTap: () => _selectDate(
                  context,
                  widget.dateInstallationMachineController,
                ),
                focus: true,
                enable: true,
                hint: "jj/mm/aaaa",
                prefixIcon: Icons.date_range_rounded,
                controller: widget.dateInstallationMachineController,
                onChange: () {},
                readOnly: true,
              ),

              SizedBox(height: Adaptive.h(0.8)),
              Text(
                "Montant du contrat (Fcfa)",
                style: TextStyle(
                  fontSize: Adaptive.sp(12),
                ),
              ),
              InputField(
                onTap: () {},
                textColor: blackColor,
                backColor: whiteColor,
                focus: true,
                onChange: (value) {
                  final cursorPos =
                      widget.montantController.selection.baseOffset;
                  final formattedValue = _formatCurrency(value);
                  widget.montantController.text = formattedValue;

                  // Correction de la position du curseur
                  final int newCursorPos =
                      cursorPos + (formattedValue.length - value.length);
                  widget.montantController.selection = TextSelection.collapsed(
                    offset: newCursorPos >= 0 ? newCursorPos : 0,
                  );
                },
                hint: "Montant du contrat (Fcfa)",
                prefixIcon: FontAwesomeIcons.moneyBill,
                controller: widget.montantController,
                keyboardType: TextInputType.number,
              ),


              SizedBox(height: Adaptive.h(0.8)),
              Text(
                "Date de début du contrat",
                style: TextStyle(fontSize: Adaptive.sp(12)),
              ),
              DateField(
                onTap: () => _selectDate(
                  context,
                  widget.dateDebutController,
                ),
                focus: true,
                enable: true,
                hint: "jj/mm/aaaa",
                prefixIcon: Icons.date_range_rounded,
                controller: widget.dateDebutController,
                onChange: () {},
                readOnly: true,
              ),

              SizedBox(height: Adaptive.h(0.8)),
              Text(
                "Date de fin du contrat",
                style: TextStyle(fontSize: Adaptive.sp(12)),
              ),
              DateField(
                onTap: () => _selectDate(
                  context,
                  widget.dateFinController,
                ),
                focus: true,
                enable: true,
                hint: "jj/mm/aaaa",
                prefixIcon: Icons.date_range_rounded,
                controller: widget.dateFinController,
                onChange: () {},
                readOnly: true,
              ),

              SizedBox(height: Adaptive.h(0.8)),
              Text(
                "Jour de paiement",
                style: TextStyle(
                  fontSize: Adaptive.sp(12),
                ),
              ),
              InputField(
                onTap: () {},
                focus: true,
                textColor: blackColor,
                backColor: whiteColor,
                hint: "Jour de paiement (1-31)",
                prefixIcon: Icons.calendar_month_rounded,
                controller: widget.jourPaiementController,
                keyboardType: TextInputType.number,
              ),

              SizedBox(height: Adaptive.h(2)),
              ElevatedButton(
                onPressed: () async {
                  EasyLoading.show(status: "Updating...");
                  final updatedContact = await _validateAndCalculateContact(
                    context: context,
                    nameController: widget.nameController,
                    phoneControllers: phoneEntries.map((e) => e.controller).toList(),
                    whatsappController: widget.whatsappController,
                    quartierController: widget.quartierController,
                    villeController: widget.villeController,
                    groupeSAVController: widget.groupeSAVController,
                    montantController: widget.montantController,
                    dateDebutController: widget.dateDebutController,
                    dateFinController: widget.dateFinController,
                    jourPaiementController: widget.jourPaiementController,
                    dateInstallationMachineController: widget.dateInstallationMachineController,
                    existingContact: widget.contact,
                  );
                  if (updatedContact != null) {
                    await context.read<ContactCubit>().updateContact(
                          updatedContact,
                        );
                    EasyLoading.showSuccess("Updated successfully !");
                    Navigator.pop(context);
                  }

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: redColor,
                  foregroundColor: whiteColor,
                ),
                child: Center(
                  child: Text(
                    "Enregistrer les modifications",
                    style: TextStyle(fontSize: Adaptive.sp(17)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(String value) {
    // 1. Supprimer tous les caractères non numériques et les espaces
    var cleanedValue = value.replaceAll(RegExp(r'\D'), '');

    // 2. Limiter la longueur à 9 caractères (pour 1 000 000 max)
    if (cleanedValue.length > 6) {
      cleanedValue = cleanedValue.substring(0, 6);
    }

    // 3. Formater avec des espaces tous les 3 chiffres
    final formattedValue = _formatWithSpaces(cleanedValue);

    return formattedValue;
  }

  String _formatWithSpaces(String value) {
    if (value.length <= 3) {
      return value;
    }

    final buffer = StringBuffer();
    int count = 0;
    for (int i = value.length - 1; i >= 0; i--) {
      buffer.write(value[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write(' ');
      }
    }

    return buffer.toString().split('').reversed.join('');
  }

  Widget _buildCollaboratorWidget(int index) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Adaptive.h(0.5)),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.all(Adaptive.w(2)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Adaptive.h(0.8)),
            Text(
              "Nom du collaborateur",
              style: TextStyle(fontSize: Adaptive.sp(12)),
            ),
            InputField(
              onTap: () {},
              focus: true,
              textColor: blackColor,
              backColor: whiteColor,
              controller: collaborators[index].nameController,
              hint: "Nom du collaborateur",
              prefixIcon: Icons.person,
            ),
            SizedBox(height: Adaptive.h(0.8)),
            Text(
              "Poste occupé",
              style: TextStyle(fontSize: Adaptive.sp(12)),
            ),
            InputField(
              onTap: () {},
              focus: true,
              textColor: blackColor,
              backColor: whiteColor,
              controller: collaborators[index].jobTitleController,
              hint: "Poste occupé",
              prefixIcon: Icons.work_rounded,
            ),
            SizedBox(height: Adaptive.h(0.8)),
            Text(
              "Téléphone",
              style: TextStyle(fontSize: Adaptive.sp(12)),
            ),

            CustomPhoneField(
              focus: true,
              hint: 'xxx...',
              initialCountryCode: widget.contact.pCountryCode ?? "CM",
              suffixIcon: Icons.phone_android_rounded,
              controller: collaborators[index].phoneController,
              onChange: (dialCode, number) {
                // SUPPRIMEZ L'ASSIGNATION DU TEXTE
                // collaborators[index].phoneController.text = _formatWithSpaces(number);
              },
            ),
            SizedBox(height: Adaptive.h(0.8)),
            Text(
              "WhatsApp contact",
              style: TextStyle(fontSize: Adaptive.sp(12)),
            ),

            CustomPhoneField(
              focus: true,
              hint: "xxx...",
              initialCountryCode: widget.contact.wCountryCode ?? "CM",
              suffixIcon: FontAwesomeIcons.whatsapp,
              controller: collaborators[index].whatsappController,
              onTap: () {},
              onChange: (dialCode, number) {
                // SUPPRIMEZ L'ASSIGNATION DU TEXTE
                // collaborators[index].whatsappController.text = _formatWithSpaces(number);
              },
            ),
            Center(
              child: IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return DeleteConfirmationDialog(
                        onConfirm: () {
                          Navigator.of(context).pop();
                          _removeCollaborator(index);
                        },
                      );
                    },
                  );
                },
                icon: Icon(
                  Icons.remove_circle,
                  color: redColor,
                  size: Adaptive.sp(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addCollaborator() {
    setState(() {
      collaborators.add(Collaborator());
    });
  }

  void _removeCollaborator(int index) {
    setState(() {
      collaborators.removeAt(index);
    });
  }


  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? firstDate;

    if (controller == widget.dateFinController) {
      if (widget.dateDebutController.text.isNotEmpty) {
        final startDateParts = widget.dateDebutController.text.split('/');
        firstDate = DateTime(
          int.parse(startDateParts[2]),
          int.parse(startDateParts[1]),
          int.parse(startDateParts[0]),
        ).add(const Duration(days: 1));
      } else {
        firstDate = DateTime.now();
      }
    } else {
      firstDate = DateTime(2000);
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: firstDate,
      lastDate: DateTime(2100),
      locale: const Locale("fr", "FR"),
    );

    if (picked != null) {
      final formattedDate = "${picked.day}/${picked.month}/${picked.year}";
      controller.text = formattedDate;
    }
  }

  Future<Contact?> _validateAndCalculateContact({
    required BuildContext context,
    required TextEditingController nameController,
    required List<TextEditingController> phoneControllers,
    required TextEditingController whatsappController,
    required TextEditingController quartierController,
    required TextEditingController villeController,
    required TextEditingController groupeSAVController,
    required TextEditingController montantController,
    required TextEditingController dateDebutController,
    required TextEditingController dateFinController,
    required TextEditingController jourPaiementController,
    required TextEditingController dateInstallationMachineController,
    Contact? existingContact,
  }) async {
    // Vérification uniquement de la cohérence des dates
    if (dateFinController.text.isNotEmpty && dateDebutController.text.isNotEmpty) {
      final startDate = dateDebutController.text.split('/');
      final endDate = dateFinController.text.split('/');

      final startDateTime = DateTime(
        int.parse(startDate[2]),
        int.parse(startDate[1]),
        int.parse(startDate[0]),
      );
      final endDateTime = DateTime(
        int.parse(endDate[2]),
        int.parse(endDate[1]),
        int.parse(endDate[0]),
      );

      if (endDateTime.isBefore(startDateTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "La date de fin ne peut pas être antérieure à la date de début",
            ),
          ),
        );
        return null;
      }
    }

    // Calcul de la durée seulement si les deux dates sont fournies
    final duration = (dateDebutController.text.isNotEmpty && dateFinController.text.isNotEmpty)
        ? calculateDuration(
      dateDebutController.text,
      dateFinController.text,
    )
        : {'years': 0, 'months': 0, 'days': 0};

    final phoneNumbers = phoneControllers
        .map((controller) => controller.text)
        .toList();

    final collaboratorData = collaborators
        .map((collaborator) => collaborator.toJson())
        .toList();

    final collaboratorsJson = collaboratorData.isNotEmpty
        ? jsonEncode(collaboratorData)
        : null;

    return existingContact?.copyWith(
      name: nameController.text,
      phone: phoneNumbers,
      whatsapp: whatsappController.text,
      quartier: quartierController.text,
      ville: villeController.text,
      groupeSAV: groupeSAVController.text,
      dateDebut: dateDebutController.text.isNotEmpty ? dateDebutController.text : null,
      dateFin: dateFinController.text.isNotEmpty ? dateFinController.text : null,
      nbAnnees: duration['years'],
      nbMois: duration['months'],
      nbJours: duration['days'],
      montant: montantController.text.isNotEmpty ? montantController.text : null,
      jourPaiement: jourPaiementController.text.isNotEmpty
          ? int.tryParse(jourPaiementController.text)
          : null,
      companyName: widget.companyNameController.text.isNotEmpty
          ? widget.companyNameController.text
          : null,
      jobTitle: widget.jobTitleController.text.isNotEmpty
          ? widget.jobTitleController.text
          : null,
      collaborators: collaboratorsJson,
      dateInstallationMachine: dateInstallationMachineController.text.isNotEmpty ? dateInstallationMachineController.text : null,
    );
  }


  Map<String, int> calculateDuration(String startDate, String endDate) {
    final start = startDate.split('/');
    final end = endDate.split('/');

    final startDateTime = DateTime(
      int.parse(start[2]),
      int.parse(start[1]),
      int.parse(start[0]),
    );
    final endDateTime = DateTime(
      int.parse(end[2]),
      int.parse(end[1]),
      int.parse(end[0]),
    );

    final difference = endDateTime.difference(startDateTime);

    int years = difference.inDays ~/ 365;
    int remainingDaysAfterYears = difference.inDays % 365;
    int months = remainingDaysAfterYears ~/ 30;
    int days = remainingDaysAfterYears % 30;

    return {
      'years': years,
      'months': months,
      'days': days,
    };
  }
}
