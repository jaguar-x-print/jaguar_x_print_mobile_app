import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/bloc/paiement/paiement_bloc.dart';
import 'package:jaguar_x_print/bloc/paiement/paiement_event.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/models/paiement_model.dart';

class PaiementCard extends StatelessWidget {
  final Paiement paiement;
  final Function() onModify;
  final Function() onDelete;
  final List<String> months = [
    "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
    "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
  ];

  PaiementCard({
    super.key,
    required this.paiement,
    required this.onModify,
    required this.onDelete,
  });

  // Méthode pour formater la date
  String _formatDate(String dateStr) {
    final date = DateFormat('dd/MM/yyyy').parse(dateStr);
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: const Text("Voulez-vous vraiment supprimer ce paiement ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              context.read<PaiementBloc>().add(
                DeletePaiement(
                  paiementId: paiement.id!,
                  contactId: paiement.contactId!,
                ),
              );
              Navigator.pop(ctx);
            },
            child: const Text("Supprimer", style: TextStyle(color: redColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM/yyyy').parse(paiement.date!);

    return Card(
      color: color4,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(Adaptive.w(1)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Adaptive.h(1)),
            Container(
              width: Adaptive.w(95),
              padding: EdgeInsets.symmetric(horizontal: Adaptive.w(5)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Mois de ${paiement.mois} ${date.year}",
                        style: TextStyle(
                          fontSize: Adaptive.sp(16),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: blackColor,
                          ),
                          onSelected: (value) {
                            if (value == 'modify') onModify();
                            if (value == 'delete') _showDeleteConfirmation(context);
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem<String>(
                              value: 'modify',
                              child: ListTile(
                                leading: Icon(Icons.edit),
                                title: Text('Modifier'),
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete, color:redColor,),
                                title: Text(
                                  'Supprimer',
                                  style: TextStyle(color: redColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Date: ${_formatDate(paiement.date!)}",
                    style: TextStyle(
                      fontSize: Adaptive.sp(16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Adaptive.h(0.5)),
                  Text(
                    "Payé via: ${paiement.mode}",
                    style: TextStyle(fontSize: Adaptive.sp(16)),
                  ),
                  SizedBox(height: Adaptive.h(0.5)),
                  Text(
                    "Reste à payer: ${paiement.resteAPayer} FCFA",
                    style: TextStyle(fontSize: Adaptive.sp(16)),
                  ),
                  SizedBox(height: Adaptive.h(0.5)),
                  Text(
                    "Pénalité: ${paiement.penalite} FCFA",
                    style: TextStyle(fontSize: Adaptive.sp(16)),
                  ),
                  SizedBox(height: Adaptive.h(1)),
                  Text(
                    "Reste à payer Mois de ${paiement.mois} : ${paiement.resteAPayer} Fcfa",
                    style: TextStyle(
                      fontSize: Adaptive.sp(18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}