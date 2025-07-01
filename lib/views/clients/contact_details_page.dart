// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/bloc/contact_cubit.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/models/contact_model.dart';
import 'package:jaguar_x_print/widgets/appbar_widget.dart';
import 'package:jaguar_x_print/widgets/clients/blocage_field.dart';
import 'package:jaguar_x_print/widgets/clients/codes_machine_widget.dart';
import 'package:jaguar_x_print/widgets/clients/collaborators/collaborators_section_widget.dart';
import 'package:jaguar_x_print/widgets/clients/comment_field.dart';
import 'package:jaguar_x_print/widgets/clients/contact_card_widget.dart';
import 'package:jaguar_x_print/widgets/clients/detail_row_widget.dart';
import 'package:jaguar_x_print/widgets/clients/facade_photo_widget.dart';
import 'package:jaguar_x_print/widgets/clients/map_widget.dart';
import 'package:jaguar_x_print/widgets/date_blocage_widget.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactDetailsPage extends StatefulWidget {
  const ContactDetailsPage({super.key});

  @override
  State<ContactDetailsPage> createState() => _ContactDetailsPageState();
}

class _ContactDetailsPageState extends State<ContactDetailsPage> {
  String dateOfLock = "";
  final TextEditingController commentController = TextEditingController();
  final TextEditingController blocageHeuresController = TextEditingController();
  LatLng? _mapCenter;
  GoogleMapController? _mapController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showMap = false;

  @override
  void initState() {
    super.initState();
    _loadBlocageHeures();
    _loadCommentaires();
  }

  Future<void> _loadCommentaires() async {
    final contactState = context.read<ContactCubit>().state;
    final contact = contactState.selectedContact;
    if (contact?.commentaire?.isNotEmpty ?? false) {
      setState(() {
        commentController.text = contact!.commentaire!;
      });
    }
  }

  Future<void> _loadBlocageHeures() async {
    final contactState = context.read<ContactCubit>().state;
    final contact = contactState.selectedContact;
    if (contact?.blocageHeures?.isNotEmpty ?? false) {
      setState(() {
        blocageHeuresController.text = contact!.blocageHeures!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: color2,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: BlocBuilder<ContactCubit, ContactState>(
        builder: (context, state) {
          final contact = state.selectedContact;

          if (contact == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  Navigator.pop(context);
                }
              });
            });

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Vérifie si les coordonnées existent déjà
          final hasExistingLocation =
              contact.latitude != null && contact.longitude != null;

          return Scaffold(
            key: _scaffoldKey,
            body: Column(
              children: [
                SizedBox(height: 0.5.h),
                const AppBarWidget(
                  imagePath: "assets/menu/client1.jpg",
                  textColor: blackColor,
                  title: 'Fiche Client',
                ),
                SizedBox(height: 0.5.h),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ContactCardWidget(contact: contact),
                        SizedBox(height: 2.h),
                        DetailRow(title: "Nom", value: contact.name ?? ""),
                        DetailRow(
                          title: "Poste Occupé",
                          value: contact.jobTitle ?? "",
                        ),
                        DetailRow(
                          title: "Nombre de têtes de lecture",
                          value: contact.nombreTetesLecture.toString(),
                        ),
                        CollaboratorsSection(
                          collaboratorsJson: contact.collaborators,
                        ),
                        SizedBox(height: 1.h),
                        DetailRow(
                          title: "Date du contrat",
                          value: "${contact.dateDebut} - ${contact.dateFin}",
                        ),
                        DetailRow(
                          title: "Durée",
                          value: _formatDuration(
                            contact.nbAnnees,
                            contact.nbMois,
                            contact.nbJours,
                          ),
                        ),
                        DetailRow(
                          title: "Montant du contrat",
                          value: "${contact.montant} Fcfa",
                        ),
                        DetailRow(
                          title: "Paiement avant le",
                          value: "${contact.jourPaiement} du mois",
                        ),
                        DetailRow(
                          title: "Date de création",
                          value: _formatDate(contact.dateCreation ?? ""),
                        ),
                        DetailRow(
                          title: "Date d'installation machine",
                          value: contact.dateInstallationMachine ?? "Aucune",
                        ),
                        SizedBox(height: 2.h),
                        //QrCodeWidget(contact: contact),

                        // SECTION DE LOCALISATION
                        if (hasExistingLocation && !_showMap)
                          _buildLocationDefinedSection(contact)
                        else
                          _buildLocationButton(contact, hasExistingLocation),


                        SizedBox(height: 2.h),

                        if (_showMap)
                          MapWidget(
                            contactId: contact.id!,
                            onMapCreated: (controller) {
                              _mapController = controller;
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _getMapCenter();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Veuillez cliquer sur le bouton "Enregistrer" plus bas pour sauvegarder les coordonnées.',
                                    ),
                                    backgroundColor: color2,
                                    duration: Duration(seconds: 5),
                                  ),
                                );
                              });
                            },
                          ),

                        SizedBox(height: 2.h),
                        FacadePhotoWidget(
                          contact: contact,
                          onImageSelected: (imagePath) {
                            if (imagePath != null) {
                              context.read<ContactCubit>().updatePhotoFacade(
                                    imagePath,
                                  );
                            }
                          },
                        ),
                        SizedBox(height: 2.h),
                        const CodesMachineWidget(),
                        SizedBox(height: 2.h),
                        DateBlocageWidget(
                          title: "Date de blocage",
                          initialValue: contact.dateOfLock,
                          onDateSelected: (selectedDate) {
                            setState(() {
                              dateOfLock = selectedDate!;
                            });
                          },
                        ),
                        SizedBox(height: 1.h),
                        BlocageField(
                          blocageHeuresController: blocageHeuresController,
                          onChanged: (value) {
                            blocageHeuresController.text =
                                _formatCurrency(value);
                          },
                        ),
                        SizedBox(height: 2.h),
                        CommentsField(commentController: commentController),
                        SizedBox(height: 2.h),
                        ElevatedButton(
                          onPressed: () async {
                            if (!mounted) return;

                            if (!_validateBlocageHeures(
                                blocageHeuresController.text)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Veuillez entrer des chiffres uniquement !"),
                                  backgroundColor: redColor,
                                ),
                              );
                              return;
                            }

                            await context
                                .read<ContactCubit>()
                                .updateContactDetails(
                                  commentController.text,
                                  blocageHeuresController.text,
                                  dateOfLock,
                                  _mapCenter,
                                );
                            context.read<ContactCubit>().updatePhotoFacade(
                                  contact.photoFacade,
                                );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Enregistré avec succès !"),
                                backgroundColor: green2Color,
                              ),
                            );

                            if (kDebugMode) {
                              print("Commentaire: ${commentController.text}");
                              print(
                                  "Heures de blocage: ${blocageHeuresController.text}");
                              print("Date de blocage : $dateOfLock");
                              print("coordonnées: $_mapCenter");
                            }

                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color2,
                            foregroundColor: blackColor,
                            padding: EdgeInsets.symmetric(
                                horizontal: 15.w, vertical: 1.5.h),
                          ),
                          child: const Text("Enregistrer",
                              style: TextStyle(fontSize: 18)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationDefinedSection(Contact contact) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color: greenColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              const Text(
                "Localisation Définie",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () => _confirmLocationEdit(contact),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: yellowColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline,
                color: redColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Rendez-vous sur la page d'entretien de ce client pour voir son itinéraire.",
                  style: TextStyle(
                    color: blackColor,
                    fontSize: 13.dp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationButton(Contact contact, bool hasExistingLocation) {
    return ElevatedButton(
      onPressed: () async {
        if (hasExistingLocation) {
          // Mode édition - ouverture directe de la carte
          setState(() => _showMap = true);
          return;
        }

        // 1. Vérifier la permission de localisation
        var status = await Permission.location.status;
        if (!status.isGranted) {
          status = await Permission.location.request();
          if (!status.isGranted) {
            _showLocationPermissionDialog(context);
            return;
          }
        }

        // 2. Vérifier si la localisation est activée
        bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
        if (!isLocationEnabled) {
          _showEnableLocationDialog(context);
          return;
        }

        setState(() {
          _showMap = true;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color2,
        foregroundColor: blackColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 5.w,
          vertical: 1.5.h,
        ),
      ),
      child: Text(
        hasExistingLocation
            ? "Cliquez sur Enregistrer"
            : "Ajouter sa localisation",
      ),
    );
  }

  Future<void> _confirmLocationEdit(Contact contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Modifier la localisation"),
        content: const Text(
          "Voulez-vous vraiment modifier la localisation de ce client ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Oui"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _showMap = true;
        _mapCenter = LatLng(contact.latitude!, contact.longitude!);
      });

      // Afficher la deuxième alerte après un court délai
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _showSaveLocationInstruction(context);
        }
      });
    }
  }

  void _showSaveLocationInstruction(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.save_alt, size: 40, color: blueColor),
        title: const Text("Enregistrement requis"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pour sauvegarder les nouvelles coordonnées :",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildInstructionStep(
                "1. Positionnez la carte sur le nouvel emplacement"),
            _buildInstructionStep(
                "2. Cliquez sur le bouton 'Enregistrer' en bas de page"),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Sans cette étape, les modifications seront perdues !",
                style: TextStyle(color: redColor),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text("J'ai compris"),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.arrow_right, size: 20, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  bool _validateBlocageHeures(String blocageHeures) {
    if (blocageHeures.isEmpty) return true;

    final RegExp digitsOnly = RegExp(r'^\d+$');
    return digitsOnly.hasMatch(blocageHeures);
  }

  void _showLocationPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Autorisation de localisation"),
          content: const Text(
            "Veuillez autoriser l'accès à votre position.",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showEnableLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Localisation désactivée"),
          content: const Text(
            "Veuillez activer la localisation sur votre téléphone.",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openLocationSettings();
              },
              child: const Text("Activer la localisation"),
            ),
          ],
        );
      },
    );
  }

  void _getMapCenter() async {
    if (_mapController != null) {
      LatLngBounds bounds = await _mapController!.getVisibleRegion();
      LatLng center = LatLng(
        (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
        (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
      );
      setState(() {
        _mapCenter = center;
      });
    }
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      final formatter = DateFormat('dd/MM/yyyy');
      return formatter.format(dateTime);
    } catch (e) {
      if (kDebugMode) {
        print("Error formatting date: $e");
      }
      return "Invalid date";
    }
  }

  String _formatDuration(int? years, int? months, int? days) {
    if (years == null || months == null || days == null) {
      return "Durée non disponible";
    }

    String formattedDuration = "";

    if (years > 0) {
      formattedDuration += "$years an${years > 1 ? 's' : ''} ";
    }

    if (months > 0) {
      formattedDuration += "$months mois ";
    }

    if (days > 0) {
      formattedDuration += "$days jour${days > 1 ? 's' : ''}";
    }

    return formattedDuration.trim();
  }

  String _formatCurrency(String value) {
    // 1. Supprimer tous les caractères non numériques et les espaces
    var cleanedValue = value.replaceAll(RegExp(r'[^\d]'), '');

    // 2. Limiter la longueur à 3 caractères
    if (cleanedValue.length > 3) {
      cleanedValue = cleanedValue.substring(0, 3);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Limite atteinte !"),
          backgroundColor: redColor,
        ),
      );
    }

    return cleanedValue;
  }
}
