import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/bloc/selected_contacts_cubit.dart';
import 'package:jaguar_x_print/models/contact_model.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'dart:math';

import 'package:jaguar_x_print/views/paiements/paiement_details_page.dart';
import 'package:jaguar_x_print/widgets/fields/password_field.dart';
import 'package:jaguar_x_print/bloc/auth/auth_cubit.dart';
import 'package:jaguar_x_print/models/user_model.dart';

class ListePayementsPage extends StatefulWidget {
  const ListePayementsPage({super.key});

  @override
  State<ListePayementsPage> createState() => _ListePayementsPageState();
}

class _ListePayementsPageState extends State<ListePayementsPage> {
  Map<Contact, Color> contactColors = {};
  bool isPasswordCorrect = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
    return luminance < 0.2 ? Colors.white : Colors.black;
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

  Future<bool> _checkPassword(BuildContext context) async {
    final passwordController = TextEditingController();
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocBuilder<AuthCubit, AuthState>(
          builder: (blocContext, authState) {
            UserModel? currentUser;
            if (authState is AuthSuccess) {
              currentUser = authState.user;
            }

            if (currentUser != null && currentUser.passwordPaiement != null) {
              debugPrint("✅ Mot de passe de paiement récupéré depuis la BD: ${currentUser.passwordPaiement}");
            } else {
              debugPrint("❌ Aucun mot de passe de paiement trouvé pour l'utilisateur");
            }

            return AlertDialog(
              title: const Text('Accès sécurisé'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Veuillez entrer le mot de passe de paiement :'),
                  const SizedBox(height: 20),
                  PasswordField(
                    focus: true,
                    hint: "Mot de passe",
                    onTap: () {},
                    controller: passwordController,
                    prefixIcon: Icons.password_rounded,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: greenColor),
                  onPressed: () {
                    if (currentUser == null) {
                      ScaffoldMessenger.of(blocContext).showSnackBar(
                        const SnackBar(
                          content: Text("Erreur: Utilisateur non connecté."),
                          backgroundColor: redColor,
                        ),
                      );
                      Navigator.pop(dialogContext, false);
                      return;
                    }

                    if (passwordController.text == currentUser.passwordPaiement) {
                      ScaffoldMessenger.of(blocContext).showSnackBar(
                        const SnackBar(
                          content: Text("Mot de passe correct !"),
                          backgroundColor: greenColor,
                        ),
                      );
                      setState(() {
                        isPasswordCorrect = true;
                      });
                      Navigator.pop(dialogContext, true);
                    } else {
                      ScaffoldMessenger.of(blocContext).showSnackBar(
                        const SnackBar(
                          content: Text("Mot de passe incorrect"),
                          backgroundColor: redColor,
                        ),
                      );
                    }
                  },
                  child: const Text("Valider", style: TextStyle(color: whiteColor)),
                ),
              ],
            );
          },
        );
      },
    ).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          debugPrint("👤 Utilisateur connecté: ${state.user.email}");
          debugPrint("🔑 Mot de passe paiement: ${state.user.passwordPaiement}");
        }
      },
      child: !isPasswordCorrect
          ? Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthSuccess) {
                debugPrint("🔑 Mot de passe de paiement actuel: ${authState.user.passwordPaiement}");
              } else {
                debugPrint("⚠️ Aucun utilisateur connecté");
              }

              final authorized = await _checkPassword(context);
              if (authorized) {
                setState(() => isPasswordCorrect = true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: greenColor,
              padding: EdgeInsets.symmetric(
                horizontal: Adaptive.w(8),
                vertical: Adaptive.h(2),
              ),
            ),
            child: Text(
              "Accéder aux Paiements",
              style: TextStyle(
                fontSize: Adaptive.sp(18),
                color: whiteColor,
              ),
            ),
          ),
        ),
      )
          : Scaffold(
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
                Padding(
                  padding: EdgeInsets.all(Adaptive.w(4)),
                  child: Center(
                    child: Text(
                      "Liste des Paiements des Clients",
                      style: TextStyle(
                        fontSize: Adaptive.sp(16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                      ? Center(
                    child: Text(
                      "Sélectionnez un contact",
                      style: TextStyle(fontSize: Adaptive.sp(18)),
                    ),
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
                              builder: (context) => PaiementDetailsPage(
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
      ),
    );
  }
}