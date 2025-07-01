import 'dart:convert';

import 'package:flutter/foundation.dart';
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
import 'package:jaguar_x_print/services/notification_service.dart';
import 'package:jaguar_x_print/widgets/fields/datefield.dart';
import 'package:jaguar_x_print/widgets/fields/text_input_field.dart';
import 'package:permission_handler/permission_handler.dart';

import '../clients/custom_phone_field.dart';

class AddContactModal extends StatefulWidget {
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

  const AddContactModal({
    super.key,
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
  State<AddContactModal> createState() => _AddContactModalState();
}

class _AddContactModalState extends State<AddContactModal> {
  List<Collaborator> collaborators = [];
  late String pCountryCode = "CM";
  late String wCountryCode = "CM";
  late String phoneDialCode = "CM";
  late String whatsappDialCode = "CM";
  int _nombreTetesLecture = 1;
  late List<PhoneEntry> phoneEntries;
  bool _isFormModified = false;
  bool _showContractFields = false;

  // Méthode pour suivre les modifications
  void _onFieldChanged() {
    if (!_isFormModified) {
      setState(() {
        _isFormModified = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialisation avec les contrôleurs existants
    phoneEntries = widget.phoneControllers
        .map((c) => PhoneEntry(dialCode: pCountryCode, controller: c))
        .toList();
  }

  void _addPhoneField() {
    setState(() {
      phoneEntries.add(PhoneEntry(
        dialCode: pCountryCode,
        controller: TextEditingController(),
      ));
    });
  }

  void _removePhoneField(int index) {
    setState(() {
      final removed = phoneEntries.removeAt(index);
      // Synchroniser la liste originale avec les contrôleurs parents
      widget.phoneControllers.remove(removed.controller);
    });
  }

  Future<void> _savePaymentReminder(Contact contact) async {
    if (contact.jourPaiement! <= 0) {
      debugPrint("❌ Jour de paiement invalide ou non défini");
      return;
    }



    final notificationService = NotificationService();
    await notificationService.initNotification();

    final now = DateTime.now();

    // Calculer la date de paiement du mois prochain
    DateTime nextPaymentDate = DateTime(now.year, now.month + 1, contact.jourPaiement!);

    // Ajuster si la date est invalide (ex: 31 février)
    if (nextPaymentDate.month != (now.month + 1) % 12) {
      nextPaymentDate = DateTime(nextPaymentDate.year, nextPaymentDate.month + 1, 0);
    }

    // Créer les dates de rappel
    final reminderDates = {
      6: nextPaymentDate.subtract(const Duration(days: 6)), // 6 jours avant
      3: nextPaymentDate.subtract(const Duration(days: 3)), // 3 jours avant
      2: nextPaymentDate.subtract(const Duration(days: 2)), // 2 jours avant
      0: nextPaymentDate, // Jour même
    };

    // Planifier les notifications de rappel
    for (final entry in reminderDates.entries) {
      final daysBefore = entry.key;
      final notificationDate = entry.value;

      // Vérifier que la date est dans le futur
      if (notificationDate.isAfter(now)) {
        final title = daysBefore == 0
            ? "Paiement dû aujourd'hui!"
            : "Rappel: Paiement dans $daysBefore jours";

        final body = daysBefore == 0
            ? "Le paiement de ${contact.name} est dû aujourd'hui. Montant: ${contact.montant} Fcfa"
            : "Rappel: Le paiement de ${contact.name} est prévu dans $daysBefore jours. Montant: ${contact.montant} Fcfa";

        await notificationService.scheduleNotification(
          id: contact.id ?? 1 * 100 + daysBefore, // ID unique
          title: title,
          body: body,
          scheduledDate: notificationDate,
        );

        debugPrint("⏰ Rappel $daysBefore jours programmé pour ${contact.name} le $notificationDate");
      }
    }

    // Notification immédiate si jour de paiement = aujourd'hui
    if (now.day == contact.jourPaiement!) {
      final immediateDate = now.add(const Duration(seconds: 10));
      await notificationService.scheduleNotification(
        id: contact.id ?? 1 * 100 + 1000, // ID différent
        title: "Paiement dû aujourd'hui!",
        body: "Le paiement de ${contact.name} est dû aujourd'hui. Montant: ${contact.montant} Fcfa",
        scheduledDate: immediateDate,
      );
      debugPrint("⏰ Notification immédiate programmée pour ${contact.name}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Vérifie si des champs ont été modifiés avant de demander la confirmation
        if (_isFormModified) {
          final shouldPop = await showDialog<bool>(
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
          );
          return shouldPop ?? false;
        } else {
          // Si aucun champ n'a été modifié, on quitte sans confirmation
          return true;
        }
      },
      child: Padding(
        padding: EdgeInsets.all(Adaptive.w(4)),
        child: SingleChildScrollView(
          padding: MediaQuery.of(context).viewInsets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(Adaptive.w(2)),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Adaptive.w(7)),
                      color: redColor,
                    ),
                    height: Adaptive.h(0.6),
                    width: Adaptive.w(25),
                  ),
                ),
              ),
              Center(
                child: Text(
                  "Ajouter un contact",
                  style: TextStyle(
                    fontSize: Adaptive.sp(20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: Adaptive.h(2)),
              Text(
                "Nom de l'entreprise",
                style: TextStyle(fontSize: Adaptive.sp(12)),
              ),
              InputField(
                onTap: () {},
                focus: true,
                textColor: blackColor,
                backColor: whiteColor,
                hint: "Nom de l'entreprise",
                prefixIcon: Icons.business_center_rounded,
                controller: widget.companyNameController,
                onChange: (_) => _onFieldChanged(),
              ),
              //_buildErrorText(_errors['entreprise']),

              SizedBox(height: Adaptive.h(0.8)),
              Text(
                "Nom du client",
                style: TextStyle(fontSize: Adaptive.sp(12)),
              ),
              InputField(
                onTap: () {},
                focus: true,
                textColor: blackColor,
                backColor: whiteColor,
                hint: "Nom du client",
                prefixIcon: Icons.person_2_rounded,
                controller: widget.nameController,
                onChange: (_) => _onFieldChanged(),
              ),
              //_buildErrorText(_errors['name']),
              SizedBox(height: Adaptive.h(0.8)),
              Text(
                "Nombre de têtes d'impression",
                style: TextStyle(fontSize: Adaptive.sp(12)),
              ),
              Row(
                children: [
                  Radio<int>(
                    value: 1,
                    groupValue: _nombreTetesLecture,
                    onChanged: (int? value) {
                      setState(() {
                        _nombreTetesLecture = value!;
                      });
                    },
                  ),
                  const Text('1'),
                  Radio<int>(
                    value: 2,
                    groupValue: _nombreTetesLecture,
                    onChanged: (int? value) {
                      setState(() {
                        _nombreTetesLecture = value!;
                      });
                    },
                  ),
                  const Text('2'),
                ],
              ),

              for (int i = 0; i < phoneEntries.length; i++)
                Column(
                  key: ValueKey(phoneEntries[i].controller),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: Adaptive.h(0.8)),
                    Text(
                      "Téléphone N°${i + 1} du client",
                      style: TextStyle(fontSize: Adaptive.sp(12)),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CustomPhoneField(
                            hint: "xxx...",
                            focus: true,
                            suffixIcon: Icons.phone_android_rounded,
                            initialCountryCode: phoneEntries[i].dialCode,
                            controller: phoneEntries[i].controller,
                            onChange: (dialCode, number) {
                              setState(() {
                                phoneEntries[i].dialCode = dialCode;
                              });
                              _onFieldChanged();
                            },
                          ),
                        ),
                        if (i != widget.phoneControllers.length - 1)
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return DeleteConfirmationDialog(
                                    onConfirm: () {
                                      Navigator.of(context).pop();
                                      _removePhoneField(i);
                                    },
                                  );
                                },
                              );
                            },
                            icon: Icon(
                              Icons.remove_circle_rounded,
                              color: redColor,
                              size: Adaptive.sp(24),
                            ),
                          ),
                        if (i == widget.phoneControllers.length - 1)
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
                    //_buildErrorText(_errors['phone${i + 1}']),
                  ],
                ),

              SizedBox(height: Adaptive.h(0.8)),
              Text(
                "Contact WhatsApp",
                style: TextStyle(fontSize: Adaptive.sp(12)),
              ),
              CustomPhoneField(
                hint: 'xxx...',
                focus: true,
                suffixIcon: FontAwesomeIcons.whatsapp,
                initialCountryCode: wCountryCode,
                controller: widget.whatsappController,
                onChange: (dialCode, formattedNumber) {
                  if (kDebugMode) {
                    print('Numéro complet: $dialCode$formattedNumber');
                  }
                  setState(() {
                    wCountryCode = dialCode;
                  });
                  _onFieldChanged();
                },
              ),
              //_buildErrorText(_errors['whatsapp']),

              SizedBox(height: Adaptive.h(0.8)),
              Text(
                "Groupe SAV",
                style: TextStyle(fontSize: Adaptive.sp(12)),
              ),
              InputField(
                onTap: () {},
                focus: true,
                textColor: blackColor,
                backColor: whiteColor,
                hint: "Groupe SAV",
                prefixIcon: Icons.group_rounded,
                controller: widget.groupeSAVController,
                onChange: (_) => _onFieldChanged(),
              ),
              //_buildErrorText(_errors['groupeSAV']),

              SizedBox(height: Adaptive.h(0.8)),
              Text(
                "Poste occupé",
                style: TextStyle(fontSize: Adaptive.sp(12)),
              ),
              InputField(
                onTap: () {},
                focus: true,
                hint: "Poste occupé",
                textColor: blackColor,
                backColor: whiteColor,
                prefixIcon: Icons.work,
                controller: widget.jobTitleController,
                onChange: (_) => _onFieldChanged(),
              ),
              //_buildErrorText(_errors['jobTitle']),

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
                style: TextStyle(fontSize: Adaptive.sp(12)),
              ),
              InputField(
                onTap: () {},
                focus: true,
                textColor: blackColor,
                backColor: whiteColor,
                hint: "Quartier",
                prefixIcon: Icons.house_rounded,
                controller: widget.quartierController,
                onChange: (_) => _onFieldChanged(),
              ),
              //_buildErrorText(_errors['quartier']),

              SizedBox(height: Adaptive.h(0.8)),
              Text(
                "Adresse (Ville)",
                style: TextStyle(fontSize: Adaptive.sp(12)),
              ),
              InputField(
                onTap: () {},
                focus: true,
                hint: "Ville",
                textColor: blackColor,
                backColor: whiteColor,
                prefixIcon: Icons.location_city_rounded,
                controller: widget.villeController,
                onChange: (_) => _onFieldChanged(),
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

              SizedBox(height: Adaptive.h(2)),
              Center(
                child: ElevatedButton(
                  onPressed: () => _showContractConfirmationDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: redColor,
                    foregroundColor: blackColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: Adaptive.w(18),
                      vertical: Adaptive.h(1),
                    ),
                  ),
                  child: Text(
                    _showContractFields
                        ? "Masquer les détails du contrat"
                        : "Afficher les détails du contrat",
                    style: TextStyle(fontSize: Adaptive.sp(14)),
                  ),
                ),
              ),
              SizedBox(height: Adaptive.h(1)),
              if(_showContractFields)...[
                SizedBox(height: Adaptive.h(0.8)),
                Text(
                  "Montant du contrat (Fcfa)",
                  style: TextStyle(fontSize: Adaptive.sp(12)),
                ),
                InputField(
                  onTap: () {},
                  focus: true,
                  textColor: blackColor,
                  backColor: whiteColor,
                  onChange: (value) {
                    _onFieldChanged();
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
                  onTap: () => _selectDate(context, widget.dateDebutController),
                  focus: true,
                  enable: true,
                  hint: "jj/mm/aaaa",
                  prefixIcon: Icons.date_range_rounded,
                  controller: widget.dateDebutController,
                  onChange: () {
                    _onFieldChanged();
                  },
                  readOnly: true,
                ),

                SizedBox(height: Adaptive.h(0.8)),
                Text(
                  "Date de fin du contrat",
                  style: TextStyle(fontSize: Adaptive.sp(12)),
                ),
                DateField(
                  onTap: () => _selectDate(context, widget.dateFinController),
                  focus: true,
                  enable: true,
                  hint: "jj/mm/aaaa",
                  prefixIcon: Icons.date_range_rounded,
                  controller: widget.dateFinController,
                  onChange: () {
                    _onFieldChanged();
                  },
                  readOnly: true,
                ),

                SizedBox(height: Adaptive.h(0.8)),
                Text(
                  "Jour de paiement",
                  style: TextStyle(fontSize: Adaptive.sp(12)),
                ),
                InputField(
                  onTap: () {

                  },
                  focus: true,
                  textColor: blackColor,
                  backColor: whiteColor,
                  hint: "Jour de paiement (1-31)",
                  prefixIcon: Icons.calendar_month_rounded,
                  controller: widget.jourPaiementController,
                  keyboardType: TextInputType.number,
                  onChange: (_) => _onFieldChanged(),
                ),
              ],


              SizedBox(height: Adaptive.h(2)),
              ElevatedButton(
                onPressed: () async {
                  EasyLoading.show(status: "Saving...");

                  final contact = await _validateAndCalculateContact(
                    context: context,
                    nameController: widget.nameController,
                    phoneControllers: widget.phoneControllers,
                    whatsappController: widget.whatsappController,
                    quartierController: widget.quartierController,
                    villeController: widget.villeController,
                    groupeSAVController: widget.groupeSAVController,
                    montantController: widget.montantController,
                    dateDebutController: widget.dateDebutController,
                    dateFinController: widget.dateFinController,
                    jourPaiementController: widget.jourPaiementController,
                  );

                  if (contact != null) {
                    await context.read<ContactCubit>().addContact(contact);
                    // Planifier la notification SEULEMENT si les champs contrat sont visibles
                    if (_showContractFields && contact.jourPaiement! > 0) {
                      debugPrint('Ok pour la notification');
                    }
                    EasyLoading.showSuccess("Enregistré avec succès");
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Contact enregistré avec succès !"),
                        backgroundColor: greenColor,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color2,
                  foregroundColor: blackColor,
                ),
                child: Center(
                  child: Text(
                    "Enregistrer",
                    style: TextStyle(fontSize: Adaptive.sp(13.5)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Méthode pour afficher la confirmation
  void _showContractConfirmationDialog(){
    if(!_showContractFields){
      showDialog(
        context: context,
        builder: (context) => AlertDialog (
          title: const Text("Détails du contrat"),
          content: const Text(
            "Disposez-vous des informations nécessaires sur le contrat de ce client?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Annuler",
                style: TextStyle(
                  color: redColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _showContractFields = true);
              },
              child: const Text(
                "Continuer",
                style: TextStyle(
                  color: redColor,
                ),
              ),
            ),
          ]
        ),
      );
    } else {
      setState(() => _showContractFields = false);
    }
  }

  String _formatCurrency(String value) {
    // 1. Supprimer tous les caractères non numériques et les espaces
    var cleanedValue = value.replaceAll(RegExp(r'[^\d]'), '');

    // 2. Limiter la longueur à 9 caractères (pour 1 000 000 max)
    if (cleanedValue.length > 6) {
      cleanedValue = cleanedValue.substring(0, 6);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Limite atteinte !"),
          backgroundColor: redColor,
        ),
      );
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
    final collaborator = collaborators[index];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: Adaptive.h(0.5)),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: greyColor),
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
              controller: collaborator.nameController,
              hint: "Nom du collaborateur",
              prefixIcon: Icons.person,
              onChange: (_) => _onFieldChanged(),
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
              controller: collaborator.jobTitleController,
              hint: "Poste occupé",
              prefixIcon: Icons.work_rounded,
              onChange: (_) => _onFieldChanged(),
            ),
            SizedBox(height: Adaptive.h(0.8)),
            Text(
              "Téléphone",
              style: TextStyle(fontSize: Adaptive.sp(12)),
            ),
            CustomPhoneField(
              focus: true,
              hint: "xxx...",
              controller: collaborator.phoneController,
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
              controller: collaborator.whatsappController,
              suffixIcon: FontAwesomeIcons.whatsapp,
              onChange: (dialCode, number) {
                // SUPPRIMEZ L'ASSIGNATION DU TEXTE
                // collaborators[index].phoneController.text = _formatWithSpaces(number);
              },
            ),
            SizedBox(height: Adaptive.h(1)),
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
  }) async {
    final phoneNumbers = phoneEntries
        .map(
          (e) => "${e.dialCode} ${e.controller.text}",
    )
        .toList();

    final collaboratorData = collaborators
        .map(
          (collaborator) => collaborator.toJson(),
    )
        .toList();

    // Convert collaborators to JSON string:
    final collaboratorsJson = jsonEncode(collaboratorData);

    // Créer le contact
    return Contact(
      name: nameController.text,
      pCountryCode: pCountryCode,
      wCountryCode: wCountryCode,
      phone: phoneNumbers,
      whatsapp: "$wCountryCode ${widget.whatsappController.text}",
      quartier: quartierController.text,
      ville: villeController.text,
      groupeSAV: groupeSAVController.text,
      dateDebut: _showContractFields ? widget.dateDebutController.text : "",
      dateFin: _showContractFields ? widget.dateFinController.text : "",
      montant: _showContractFields ? widget.montantController.text : "",
      jourPaiement: _showContractFields
          ? int.tryParse(widget.jourPaiementController.text) ?? 0
          : 0,
      nbAnnees: 0,
      nbMois: 0,
      nbJours: 0,
      dateCreation: DateTime.now().toString(),
      codeClient: "Nouveau",
      photoFacade: '',
      codesMachine: const [],
      companyName: widget.companyNameController.text,
      jobTitle: widget.jobTitleController.text,
      collaborators: collaboratorsJson,
      nombreTetesLecture: _nombreTetesLecture,
    );
  }

  Map<String, int> calculateDuration(String startDate, String endDate) {
    // Vérifier si les dates sont vides
    if (startDate.isEmpty || endDate.isEmpty) {
      return {
        'years': 0,
        'months': 0,
        'days': 0,
      };
    }

    try {
      final startParts = startDate.split('/');
      final endParts = endDate.split('/');

      // Vérifier que les dates ont le bon nombre de parties
      if (startParts.length < 3 || endParts.length < 3) {
        return {
          'years': 0,
          'months': 0,
          'days': 0,
        };
      }

      final startDateTime = DateTime(
        int.parse(startParts[2]),
        int.parse(startParts[1]),
        int.parse(startParts[0]),
      );
      final endDateTime = DateTime(
        int.parse(endParts[2]),
        int.parse(endParts[1]),
        int.parse(endParts[0]),
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
    } catch (e) {
      // Retourner 0 en cas d'erreur de parsing
      return {
        'years': 0,
        'months': 0,
        'days': 0,
      };
    }
  }
}

class PhoneEntry {
  String dialCode;
  TextEditingController controller;

  PhoneEntry({
    required this.dialCode,
    required this.controller,
  });
}
