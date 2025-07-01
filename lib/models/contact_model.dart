import 'dart:convert';
import 'package:equatable/equatable.dart';

class Contact extends Equatable {
  final int? id;
  final String name;
  final String pCountryCode;
  final String wCountryCode;
  final List<String> phone;
  final String whatsapp;
  final String? quartier;
  final String? ville;
  final String? groupeSAV;
  final String dateDebut;
  final String dateFin;
  final int? nbAnnees;
  final int? nbMois;
  final int? nbJours;
  final int? nombreTetesLecture;
  final String? montant;
  final int? jourPaiement;
  final String? dateCreation;
  final String? codeClient;
  final String photoFacade;
  final String profilClient;
  final List<String> codesMachine;
  final String? commentaire;
  final String? blocageHeures;
  final String? dateOfLock;
  final String? companyName;
  final String? jobTitle;
  final String? collaborators;
  final double? latitude;
  final double? longitude;
  final int? serverSynced;
  final String? dateInstallationMachine;

  const Contact({
    this.id,
    required this.name,
    this.nombreTetesLecture,
    required this.phone,
    required this.whatsapp,
    this.quartier,
    this.ville,
    this.groupeSAV,
    required this.dateDebut,
    required this.dateFin,
    this.nbAnnees,
    this.nbMois,
    this.nbJours,
    this.montant,
    this.jourPaiement,
    this.dateCreation,
    this.codeClient,
    required this.pCountryCode,
    required this.wCountryCode,
    this.photoFacade = '',
    this.profilClient = '',
    this.codesMachine = const [],
    this.commentaire,
    this.blocageHeures,
    this.dateOfLock,
    this.companyName,
    this.jobTitle,
    this.collaborators,
    this.latitude,
    this.longitude,
    this.serverSynced,
    this.dateInstallationMachine,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nombreTetesLecture': nombreTetesLecture,
      'pCountryCode' : pCountryCode,
      'wCountryCode' : wCountryCode,
      'phone': jsonEncode(phone),
      'whatsapp': whatsapp,
      'quartier': quartier,
      'ville': ville,
      'groupeSAV': groupeSAV,
      'dateDebut': dateDebut,
      'dateFin': dateFin,
      'nbAnnees': nbAnnees,
      'nbMois': nbMois,
      'nbJours': nbJours,
      'montant': montant,
      'jourPaiement': jourPaiement,
      'dateCreation': dateCreation,
      'codeClient': codeClient,
      'photoFacade': photoFacade,
      'profilClient': profilClient,
      'codesMachine': jsonEncode(codesMachine),
      'commentaire': commentaire,
      'blocageHeures': blocageHeures,
      'dateOfLock': dateOfLock,
      'companyName': companyName,
      'jobTitle': jobTitle,
      'collaborators': collaborators,
      'latitude': latitude,
      'longitude': longitude,
      'serverSynced': serverSynced,
      'dateInstallationMachine': dateInstallationMachine,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    List<String> codesMachine = [];
    if (map['codesMachine'] != null && map['codesMachine'].isNotEmpty) {
      try {
        codesMachine = List<String>.from(jsonDecode(map['codesMachine']));
      } catch (e) {
        // Gestion de l'erreur si la chaîne n'est pas un JSON valide
        print('Erreur lors du décodage JSON des codes machine: $e');
        codesMachine = []; // Ou une autre valeur par défaut
      }
    }
    return Contact(
      id: map['id'],
      name: map['name'],
      nombreTetesLecture: map['nombreTetesLecture'],
      pCountryCode: map['pCountryCode'],
      wCountryCode: map['wCountryCode'],
      phone: map['phone'] != null ? List<String>.from(jsonDecode(map['phone'])) : [],
      whatsapp: map['whatsapp'],
      quartier: map['quartier'],
      ville: map['ville'],
      groupeSAV: map['groupeSAV'],
      dateDebut: map['dateDebut'],
      dateFin: map['dateFin'],
      nbAnnees: map['nbAnnees'],
      nbMois: map['nbMois'],
      nbJours: map['nbJours'],
      montant: map['montant'],
      jourPaiement: map['jourPaiement'],
      dateCreation: map['dateCreation'],
      codeClient: map['codeClient'],
      photoFacade: map['photoFacade'],
      profilClient: map['profilClient'],
      codesMachine: codesMachine,
      commentaire: map['commentaire'],
      blocageHeures: map['blocageHeures'],
      dateOfLock: map['dateOfLock'],
      companyName: map['companyName'],
      jobTitle: map['jobTitle'],
      collaborators: map['collaborators'],
      latitude: map['latitude'] != null ? double.tryParse(map['latitude'].toString()) : null,
      longitude: map['longitude'] != null ? double.tryParse(map['longitude'].toString()) : null,
      serverSynced: map['serverSynced'],
      dateInstallationMachine: map['dateInstallationMachine'],
    );
  }


  Contact copyWith({
    int? id,
    String? name,
    int? nombreTetesLecture,
    String? countryCode,
    List<String>? phone,
    String? whatsapp,
    String? quartier,
    String? ville,
    String? groupeSAV,
    String? dateDebut,
    String? dateFin,
    int? nbAnnees,
    int? nbMois,
    int? nbJours,
    String? montant,
    int? jourPaiement,
    String? dateCreation,
    String? codeClient,
    String? photoFacade,
    String? profilClient,
    List<String>? codesMachine,
    String? commentaire,
    String? blocageHeures,
    String? dateOfLock,
    String? companyName,
    String? jobTitle,
    String? collaborators,
    double? latitude,
    double? longitude,
    int? serverSynced,
    String? dateInstallationMachine,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      nombreTetesLecture : nombreTetesLecture ?? this.nombreTetesLecture,
      pCountryCode: pCountryCode ?? this.pCountryCode,
      wCountryCode: wCountryCode ?? this.wCountryCode,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      quartier: quartier ?? this.quartier,
      ville: ville ?? this.ville,
      groupeSAV: groupeSAV ?? this.groupeSAV,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      nbAnnees: nbAnnees ?? this.nbAnnees,
      nbMois: nbMois ?? this.nbMois,
      nbJours: nbJours ?? this.nbJours,
      montant: montant ?? this.montant,
      jourPaiement: jourPaiement ?? this.jourPaiement,
      dateCreation: dateCreation ?? this.dateCreation,
      codeClient: codeClient ?? this.codeClient,
      photoFacade: photoFacade ?? this.photoFacade,
      profilClient: profilClient ?? this.profilClient,
      codesMachine: codesMachine ?? this.codesMachine,
      commentaire: commentaire ?? this.commentaire,
      blocageHeures: blocageHeures ?? this.blocageHeures,
      dateOfLock: dateOfLock ?? this.dateOfLock,
      companyName: companyName ?? this.companyName,
      jobTitle: jobTitle ?? this.jobTitle,
      collaborators: collaborators ?? this.collaborators,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      serverSynced: serverSynced ?? this.serverSynced,
      dateInstallationMachine: dateInstallationMachine ?? this.dateInstallationMachine,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    nombreTetesLecture,
    pCountryCode,
    wCountryCode,
    phone,
    whatsapp,
    quartier,
    ville,
    groupeSAV,
    dateDebut,
    dateFin,
    nbAnnees,
    nbMois,
    nbJours,
    montant,
    jourPaiement,
    dateCreation,
    codeClient,
    photoFacade,
    profilClient,
    codesMachine,
    commentaire,
    blocageHeures,
    dateOfLock,
    companyName,
    jobTitle,
    collaborators,
    latitude,
    longitude,
    serverSynced,
  ];
}