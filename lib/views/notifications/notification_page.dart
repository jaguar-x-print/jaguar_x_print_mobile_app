import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/bloc/contact_cubit.dart';
import 'package:jaguar_x_print/models/contact_model.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/services/notification_service.dart';
import 'dart:math';

class ScheduleNotificationsPage extends StatefulWidget {
  const ScheduleNotificationsPage({super.key});

  @override
  State<ScheduleNotificationsPage> createState() =>
      _ScheduleNotificationsPageState();
}

class _ScheduleNotificationsPageState extends State<ScheduleNotificationsPage> {
  final Map<Contact, Color> contactColors = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final NotificationService _notificationService = NotificationService();
  final Map<int, DateTime> _lastScheduledMap = {}; // Stocke la dernière date de programmation par contact

  @override
  void initState() {
    super.initState();
    _notificationService.initNotification();
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

  // Vérifie si les notifications ont déjà été créées ce mois-ci
  bool _isNotificationScheduledThisMonth(Contact contact) {
    final lastScheduled = _lastScheduledMap[contact.id];
    if (lastScheduled == null) return false;

    final now = DateTime.now();
    return lastScheduled.month == now.month && lastScheduled.year == now.year;
  }

  Future<void> _schedulePaymentReminders(
      Contact contact,
      DateTime nextPaymentDate,
      ) async {
    final now = DateTime.now();

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

        await _notificationService.scheduleNotification(
          id: contact.id ?? 1 * 100 + daysBefore, // ID unique
          title: title,
          body: body,
          scheduledDate: notificationDate,
        );

        debugPrint(
          "⏰ Rappel $daysBefore jours programmé pour ${contact.name} le $notificationDate",
        );
      }
    }

    // Notification immédiate si jour de paiement = aujourd'hui
    if (now.day == contact.jourPaiement!) {
      final immediateDate = now.add(
        const Duration(seconds: 10),
      );
      await _notificationService.scheduleNotification(
        id: contact.id ?? 1 * 100 + 1000, // ID différent
        title: "Paiement dû aujourd'hui!",
        body:
        "Le paiement de ${contact.name} est dû aujourd'hui. Montant: ${contact.montant} Fcfa",
        scheduledDate: immediateDate,
      );
      debugPrint(
        "⏰ Notification immédiate programmée pour ${contact.name}",
      );
    }

    // Enregistrer la date de programmation
    _lastScheduledMap[contact.id!] = DateTime.now();
  }

  void _showPaymentDetails(BuildContext context, Contact contact) {
    final now = DateTime.now();
    final paymentDay = contact.jourPaiement ?? 1;
    final isScheduled = _isNotificationScheduledThisMonth(contact);

    // Calculer la prochaine date de paiement
    DateTime nextPaymentDate;
    if (now.day < paymentDay) {
      // Ce mois-ci si le jour n'est pas encore passé
      nextPaymentDate = DateTime(
        now.year,
        now.month,
        paymentDay,
      );
    } else {
      // Sinon le mois prochain
      nextPaymentDate = DateTime(
        now.year,
        now.month + 1,
        paymentDay,
      );
    }

    // Calculer les dates de rappel
    final reminderDates = {
      '6 jours avant': nextPaymentDate.subtract(const Duration(days: 6)),
      '3 jours avant': nextPaymentDate.subtract(const Duration(days: 3)),
      '2 jours avant': nextPaymentDate.subtract(const Duration(days: 2)),
      'Jour même': nextPaymentDate,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barre de glissement en haut
              Center(
                child: Container(
                  width: 80,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: color1,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Titre
              Center(
                child: Text(
                  "Détails de paiement",
                  style: TextStyle(
                    fontSize: Adaptive.sp(20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Informations client
              ListTile(
                leading: const Icon(Icons.business),
                title: const Text("Client"),
                subtitle: Text(
                  contact.companyName ?? 'Nom inconnu',
                  style: const TextStyle(fontSize: 18),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text("Jour de paiement"),
                subtitle: Text(
                  "Le ${contact.jourPaiement} de chaque mois",
                  style: const TextStyle(fontSize: 18),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.payment),
                title: const Text("Montant"),
                subtitle: Text(
                  "${contact.montant} Fcfa",
                  style: const TextStyle(fontSize: 18),
                ),
              ),

              const Divider(),
              const SizedBox(height: 10),

              // Prochaine date de paiement
              Center(
                child: Text(
                  "Prochain paiement: ${_formatDate(nextPaymentDate)}",
                  style: TextStyle(
                    fontSize: Adaptive.sp(18),
                    fontWeight: FontWeight.bold,
                    color: color1,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Rappels programmés
              const Text(
                "Rappels de paiement à programmer:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),

              ...reminderDates.entries.map((entry) => ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(entry.key),
                subtitle: Text(_formatDate(entry.value)),
              )),

              const SizedBox(height: 30),

              // Bouton pour créer les notifications
              if (isScheduled)
                const Center(
                  child: Column(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 50),
                      SizedBox(height: 16),
                      Text(
                        "Notifications déjà créées ce mois-ci",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Vous pourrez recréer les notifications le mois prochain",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                )
              else
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _schedulePaymentReminders(
                        contact,
                        nextPaymentDate,
                      );
                      Navigator.pop(context); // Fermer le bottom sheet
                      setState(() {}); // Rafraîchir l'interface
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Notifications créées avec succès!",
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Erreur: ${e.toString()}",
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color1,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Créer les notifications sus-citées",
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Programmer les notifications",
          style: TextStyle(
            color: whiteColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: color1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: whiteColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<ContactCubit, ContactState>(
        builder: (context, state) {
          if (state.contacts.isEmpty) {
            return const Center(
              child: Text(
                "Aucun contact disponible.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final filteredContacts = state.contacts
              .where((contact) => (contact.companyName ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
              .toList();

          return Column(
            children: [
              // Barre de recherche
              Padding(
                padding: EdgeInsets.all(
                  Adaptive.w(4),
                ),
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

              // Liste des contacts
              Expanded(
                child: filteredContacts.isEmpty
                    ? const Center(
                  child: Text(
                    "Aucun résultat trouvé",
                    style: TextStyle(fontSize: 16),
                  ),
                )
                    : ListView.builder(
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = filteredContacts[index];
                    final cardColor = contactColors[contact] ??
                        generateRandomColor(contact);
                    contactColors[contact] = cardColor;
                    final textColor = getTextColor(cardColor);
                    final isScheduled = _isNotificationScheduledThisMonth(contact);

                    return GestureDetector(
                      onTap: () => _showPaymentDetails(
                        context,
                        contact,
                      ),
                      child: Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: Adaptive.w(4),
                          vertical: Adaptive.h(1),
                        ),
                        color: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(
                            Adaptive.w(3),
                          ),
                          child: Row(
                            children: [
                              // Cercle avec initiales
                              Container(
                                width: Adaptive.w(12),
                                height: Adaptive.w(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: whiteColor,
                                  border: Border.all(
                                    color: blackColor,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    contact.companyName!
                                        .substring(0, 2)
                                        .toUpperCase(),
                                    style: TextStyle(
                                      fontSize: Adaptive.sp(18),
                                      fontWeight: FontWeight.bold,
                                      color: blackColor,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: Adaptive.w(4)),

                              // Nom de l'entreprise
                              Expanded(
                                child: Text(
                                  contact.companyName ?? 'Nom inconnu',
                                  style: TextStyle(
                                    fontSize: Adaptive.sp(18),
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ),

                              // Icône de notification ou coche verte
                              if (isScheduled)
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: Adaptive.sp(22),
                                )
                              else
                                Icon(
                                  Icons.notifications_active_outlined,
                                  color: textColor,
                                  size: Adaptive.sp(22),
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