import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/api/database.dart';
import 'package:jaguar_x_print/bloc/contact_cubit.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/models/contact_model.dart';
import 'package:jaguar_x_print/views/clients/contact_details_page.dart';
import 'package:jaguar_x_print/constant/confirmation_suppression_widget.dart';
import 'package:jaguar_x_print/widgets/card/contact_card.dart';
import 'package:jaguar_x_print/widgets/modals/add_contact_modal.dart';
import 'package:jaguar_x_print/widgets/modals/edit_contact_modal.dart';

class FicheClientPage extends StatefulWidget {
  const FicheClientPage({super.key});

  @override
  State<FicheClientPage> createState() => _FicheClientPageState();
}

class _FicheClientPageState extends State<FicheClientPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: greyColor,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: FutureBuilder<List<Contact>>(
          future: DatabaseHelper().getContacts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur : ${snapshot.error}'));
            } else {
              context.read<ContactCubit>().emit(
                ContactState(contacts: snapshot.data ?? []),
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Center(
                      child: Text(
                        "Répertoire des contacts",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher un contact...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) => setState(() => _searchQuery = value.toLowerCase(),
                        ),
                      ),
                    ),
                    BlocBuilder<ContactCubit, ContactState>(
                      builder: (context, state) {
                        List<Contact> filteredContacts = List.from(state.contacts)
                          ..sort((a, b) => a.companyName!.compareTo((b.companyName!).toLowerCase()));

                        filteredContacts = filteredContacts
                            .where(
                              (contact) => contact.companyName!.toLowerCase().contains(_searchQuery),
                            ).toList();

                        if (_searchQuery.isNotEmpty && filteredContacts.isEmpty) {
                          return _buildNoResultsFound();
                        }

                        if (filteredContacts.isEmpty) {
                          return _buildNoContactsAvailable();
                        }

                        return Column(
                          children: filteredContacts.map((contact) {
                            return GestureDetector(
                              onTap: () {
                                context.read<ContactCubit>().selectContact(contact);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ContactDetailsPage(),
                                  ),
                                );
                              },
                              child: ContactCard(
                                contact: contact,
                                onEdit: () => _showEditContactModal(
                                  context,
                                  contact,
                                ),
                                onDelete: () => _confirmDeleteContact(
                                  context,
                                  contact,
                                ),
                                onPhotoChanged: (imagePath) => _updateContactPhoto(
                                  context,
                                  contact,
                                  imagePath,
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              );
            }
          },
        ),
        bottomNavigationBar: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: GestureDetector(
            onTap: () {
              EasyLoading.show(status: "");
              _showAddContactModal(context);
              EasyLoading.dismiss();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icône + dans un rond bleu
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: blueColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: whiteColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 20),
                // Texte à droite
                const Text(
                  "Ajout de Nvx Client",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: blackColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),

      ),
    );
  }



  Widget _buildNoResultsFound() {
    return const Column(
      children: [
        SizedBox(height: 50),
        Icon(Icons.search_off, size: 80, color: greyColor),
        SizedBox(height: 16),
        Text(
          'Aucun résultat trouvé',
          style: TextStyle(fontSize: 16, color: greyColor),
        ),
      ],
    );
  }

  Widget _buildNoContactsAvailable() {
    return const Column(
      children: [
        SizedBox(height: 50),
        Icon(
          Icons.contact_page_outlined,
          size: 100,
          color: greyColor,
        ),
        SizedBox(height: 16),
        Text(
          'Aucun contact disponible',
          style: TextStyle(
            fontSize: 18,
            color: greyColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _confirmDeleteContact(BuildContext context, Contact contact) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        onConfirm: () {
          Navigator.pop(context);
          context.read<ContactCubit>().deleteContact(contact.id!);
        },
      ),
    );
  }

  void _updateContactPhoto(
      BuildContext context, Contact contact, String imagePath) async {
    final updatedContact = contact.copyWith(profilClient: imagePath);
    await DatabaseHelper().updateContact(updatedContact);
    context.read<ContactCubit>().updateContact(updatedContact);
  }

  // Modal d'ajout d'un contact
  void _showAddContactModal(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final List<TextEditingController> phoneControllers = [
      TextEditingController()
    ];
    final TextEditingController whatsappController = TextEditingController();
    final TextEditingController quartierController = TextEditingController();
    final TextEditingController villeController = TextEditingController();
    final TextEditingController groupeSAVController = TextEditingController();
    final TextEditingController montantController = TextEditingController();
    final TextEditingController dateDebutController = TextEditingController();
    final TextEditingController dateFinController = TextEditingController();
    final TextEditingController jourPaiementController =
        TextEditingController();
    final TextEditingController companyNameController = TextEditingController();
    final TextEditingController jobTitleController = TextEditingController();
    final TextEditingController dateInstallationMachineController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return AddContactModal(
          nameController: nameController,
          phoneControllers: phoneControllers,
          whatsappController: whatsappController,
          quartierController: quartierController,
          villeController: villeController,
          groupeSAVController: groupeSAVController,
          montantController: montantController,
          dateDebutController: dateDebutController,
          dateFinController: dateFinController,
          jourPaiementController: jourPaiementController,
          companyNameController: companyNameController,
          jobTitleController: jobTitleController,
          dateInstallationMachineController: dateInstallationMachineController,
        );
      },
    );
  }

  // Modal de modification d'un contact
  void _showEditContactModal(BuildContext context, Contact contact) {
    final TextEditingController nameController = TextEditingController(
      text: contact.name,
    );
    final List<TextEditingController> phoneControllers = contact.phone
        .map((phone) => TextEditingController(text: phone))
        .toList();
    final TextEditingController whatsappController = TextEditingController(
      text: contact.whatsapp,
    );
    final TextEditingController quartierController = TextEditingController(
      text: contact.quartier,
    );
    final TextEditingController villeController = TextEditingController(
      text: contact.ville,
    );
    final TextEditingController groupeSAVController = TextEditingController(
      text: contact.groupeSAV,
    );
    final TextEditingController montantController = TextEditingController(
      text: contact.montant.toString(),
    );
    final TextEditingController dateDebutController = TextEditingController(
      text: contact.dateDebut,
    );
    final TextEditingController dateFinController = TextEditingController(
      text: contact.dateFin,
    );
    final TextEditingController jourPaiementController = TextEditingController(
      text: contact.jourPaiement.toString(),
    );
    final TextEditingController companyNameController = TextEditingController(
      text: contact.companyName,
    );
    final TextEditingController jobTitleController = TextEditingController(
      text: contact.jobTitle,
    );
    final TextEditingController dateInstallationMachineController = TextEditingController(
      text: contact.dateInstallationMachine,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return EditContactModal(
          contact: contact,
          nameController: nameController,
          phoneControllers: phoneControllers,
          whatsappController: whatsappController,
          quartierController: quartierController,
          villeController: villeController,
          groupeSAVController: groupeSAVController,
          montantController: montantController,
          dateDebutController: dateDebutController,
          dateFinController: dateFinController,
          jourPaiementController: jourPaiementController,
          companyNameController: companyNameController,
          jobTitleController: jobTitleController,
          dateInstallationMachineController: dateInstallationMachineController,
        );
      },
    );
  }
}
