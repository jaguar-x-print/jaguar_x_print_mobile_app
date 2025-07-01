// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/bloc/contact_cubit.dart';
import 'package:jaguar_x_print/bloc/selected_contacts_cubit.dart';
import 'package:jaguar_x_print/models/contact_model.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/models/entretien_model.dart';
import 'package:jaguar_x_print/views/entretien/choix_de_page.dart';
import 'dart:math';

class EntretienPage extends StatefulWidget {
  const EntretienPage({super.key});

  @override
  State<EntretienPage> createState() => _EntretienPageState();
}

class _EntretienPageState extends State<EntretienPage> {
  Map<Contact, Color> contactColors = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late final Entretien entretient;

  @override
  void initState() {
    super.initState();
    context.read<SelectedContactsCubit>().loadContacts();
  }

  Color generateRandomColor(Contact contact) {
    final random = Random(contact.name.hashCode);
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1.0,
    );
  }

  Color getTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance < 0.2 ? whiteColor : blackColor;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SelectedContactsCubit, List<Contact>>(
        builder: (context, selectedContacts) {
          // Tri et filtrage des contacts
          List<Contact> filteredContacts = List.from(selectedContacts)
            ..sort((a, b) => (a.companyName ?? '')
                .toLowerCase()
                .compareTo((b.companyName ?? '').toLowerCase()));

          filteredContacts = filteredContacts
              .where((contact) => (contact.companyName ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
              .toList();

          return Column(
            children: [
              Text(
                "Clients associés aux entretiens",
                style: TextStyle(
                  fontSize: Adaptive.sp(16),
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Barre de recherche
              Padding(
                padding: EdgeInsets.all(Adaptive.w(4)),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un contact...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),

              // Affichage des résultats
              Expanded(
                child: selectedContacts.isEmpty
                    ? const Center(
                  child: Text("Sélectionnez un contact"),
                )
                    : filteredContacts.isEmpty
                    ? _buildNoResultsFound()
                    : ListView.builder(
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = filteredContacts[index];
                    final cardColor = contactColors[contact] ??
                        generateRandomColor(contact);
                    contactColors[contact] = cardColor;
                    final textColor = getTextColor(cardColor);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EntretienHomePage(
                              contact: contact,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: EdgeInsets.all(Adaptive.w(2)),
                        color: cardColor,
                        child: Padding(
                          padding: EdgeInsets.all(Adaptive.w(3)),
                          child: Row(
                            children: [
                              Container(
                                width: Adaptive.w(4.5),
                                height: Adaptive.h(4.5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: whiteColor,
                                  border: Border.all(
                                    color: blackColor,
                                    width: 1.0,
                                  ),
                                ),
                                margin: const EdgeInsets.only(right: 10),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      contact.companyName!,
                                      style: TextStyle(
                                        fontSize: Adaptive.sp(24),
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}