import 'package:equatable/equatable.dart';

class Paiement extends Equatable {
  final int? id;
  final int? contactId;
  final String? mois;
  final String? date;
  final String? mode;
  final String? resteAPayer;
  final String? penalite;

  const Paiement({
    this.id,
    this.contactId,
    this.mois,
    this.date,
    this.mode,
    this.resteAPayer,
    this.penalite,
  });

  // Conversion en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contactId': contactId,
      'mois': mois,
      'date': date,
      'mode': mode,
      'resteAPayer': resteAPayer,
      'penalite': penalite,
    };
  }

  // Création depuis une Map (depuis la base de données)
  factory Paiement.fromMap(Map<String, dynamic> map) {
    return Paiement(
      id: map['id'],
      contactId: map['contactId'],
      mois: map['mois'],
      date: map['date'],
      mode: map['mode'],
      resteAPayer: map['resteAPayer'],
      penalite: map['penalite'],
    );
  }

  // Méthode de copie avec modification
  Paiement copyWith({
    int? id,
    int? contactId,
    String? mois,
    String? date,
    String? mode,
    String? resteAPayer,
    String? penalite,
  }) {
    return Paiement(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      mois: mois ?? this.mois,
      date: date ?? this.date,
      mode: mode ?? this.mode,
      resteAPayer: resteAPayer ?? this.resteAPayer,
      penalite: penalite ?? this.penalite,
    );
  }

  // Override des props pour Equatable
  @override
  List<Object?> get props => [
    id,
    contactId,
    mois,
    date,
    mode,
    resteAPayer,
    penalite,
  ];
}