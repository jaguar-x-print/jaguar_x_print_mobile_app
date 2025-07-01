import 'package:equatable/equatable.dart';

class Entretien extends Equatable {
  final int? id;
  final int? contactId;
  final String? date;
  final String? heureArrivee;
  final String? printerEnvironmentComment;
  final List<String>? printerEnvironmentImage;
  final String? evacuationEncreComment;
  final List<String>? evacuationEncreImage;
  final String? niveauEncreComment;
  final List<String>? niveauEncreImage;
  final String? niveauEncreSelection;
  final String? photoStationEncreComment;
  final List<String>? photoStationEncreImage;
  final String? nozzelComment;
  final List<String>? nozzelImage;
  final String? regulTension;
  final String? capaRegulTension;
  final String? priseT;
  final String? local;
  final String? temp;
  final String? encreJxP;
  final String? netJxP;
  final String? etatGenIm;
  final String? problemeDecrit;
  final String? problemeEstime;
  final String? changTete;
  final String? changCaps;
  final String? dampers;
  final String? wiper;
  final String? changPom;
  final String? graisRail;
  final String? changEncod;
  final String? changRast;
  final String? capsU;
  final String? dampersU;
  final String? wiperU;
  final String? pompeU;
  final String? roulRailU;
  final String? changEncodU;
  final String? changRastU;
  final String? probRes;
  final String? problemePostIntervention;
  final String? signatureImagePath;
  final String? signatureTime;
  final String? contratStatus;
  final String? entretienType;
  final int? nbTetesChangees;
  final List<String>? datesPremiereAnnee;
  final String? etatMachine;
  final String? prochainEntretien;

  const Entretien({
    this.id,
    this.contactId,
    this.date,
    this.heureArrivee,
    this.printerEnvironmentComment,
    this.printerEnvironmentImage,
    this.evacuationEncreComment,
    this.evacuationEncreImage,
    this.niveauEncreComment,
    this.niveauEncreImage,
    this.niveauEncreSelection,
    this.photoStationEncreComment,
    this.photoStationEncreImage,
    this.nozzelComment,
    this.nozzelImage,
    this.regulTension,
    this.capaRegulTension,
    this.priseT,
    this.local,
    this.temp,
    this.encreJxP,
    this.netJxP,
    this.etatGenIm,
    this.problemeDecrit,
    this.problemeEstime,
    this.changTete,
    this.changCaps,
    this.dampers,
    this.wiper,
    this.changPom,
    this.graisRail,
    this.changEncod,
    this.changRast,
    this.capsU,
    this.dampersU,
    this.wiperU,
    this.pompeU,
    this.roulRailU,
    this.changEncodU,
    this.changRastU,
    this.probRes,
    this.problemePostIntervention,
    this.signatureImagePath,
    this.signatureTime,
    this.contratStatus,
    this.entretienType,
    this.nbTetesChangees,
    this.datesPremiereAnnee,
    this.etatMachine,
    this.prochainEntretien,
  });

  /// Convertir un objet Entretien en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contactId': contactId,
      'date': date,
      'heureArrivee': heureArrivee,
      'printerEnvironmentComment': printerEnvironmentComment,
      'evacuationEncreComment': evacuationEncreComment,
      'niveauEncreComment': niveauEncreComment,
      'niveauEncreSelection': niveauEncreSelection,
      'photoStationEncreComment': photoStationEncreComment,
      'nozzelComment': nozzelComment,
      'printerEnvironmentImage': printerEnvironmentImage?.isNotEmpty == true
          ? printerEnvironmentImage!.join(',')
          : null,
      'evacuationEncreImage': evacuationEncreImage?.isNotEmpty == true
          ? evacuationEncreImage!.join(',')
          : null,
      'niveauEncreImage': niveauEncreImage?.isNotEmpty == true
          ? niveauEncreImage!.join(',')
          : null,
      'photoStationEncreImage': photoStationEncreImage?.isNotEmpty == true
          ? photoStationEncreImage!.join(',')
          : null,
      'nozzelImage': nozzelImage?.isNotEmpty == true
          ? nozzelImage!.join(',')
          : null,
      'regulTension': regulTension,
      'capaRegulTension': capaRegulTension,
      'priseT': priseT,
      'local': local,
      'temp': temp,
      'encreJxP': encreJxP,
      'netJxP': netJxP,
      'etatGenIm': etatGenIm,
      'problemeDecrit': problemeDecrit,
      'problemeEstime': problemeEstime,
      'changTete': changTete,
      'changCaps': changCaps,
      'changRast': changRast ?? 'Non',
      'changRastU': changRastU ?? 'Non',
      'dampers': dampers,
      'wiper': wiper,
      'changPom': changPom,
      'graisRail': graisRail,
      'changEncod': changEncod,
      'capsU': capsU,
      'dampersU': dampersU,
      'wiperU': wiperU,
      'pompeU': pompeU,
      'roulRailU': roulRailU,
      'changEncodU': changEncodU,
      'probRes': probRes,
      'problemePostIntervention': problemePostIntervention,
      'signatureImagePath': signatureImagePath,
      'signatureTime': signatureTime,
      'contratStatus': contratStatus,
      'entretienType': entretienType,
      'nbTetesChangees': nbTetesChangees,
      'datesPremiereAnnee': datesPremiereAnnee?.join('|'),
      'etatMachine': etatMachine,
      'prochainEntretien': prochainEntretien,
    };
  }

  static List<String>? _splitString(String? value) {
    if (value == null || value.isEmpty) return null;
    return value.split(',');
  }

  /// Convertir un Map en objet Entretien
  factory Entretien.fromMap(Map<String, dynamic> map) {
    return Entretien(
      id: map['id'],
      contactId: map['contactId'],
      date: map['date'],
      heureArrivee: map['heureArrivee'],
      printerEnvironmentComment: map['printerEnvironmentComment'],
      evacuationEncreComment: map['evacuationEncreComment'],
      niveauEncreComment: map['niveauEncreComment'],
      niveauEncreSelection: map['niveauEncreSelection'],
      photoStationEncreComment: map['photoStationEncreComment'],
      nozzelComment: map['nozzelComment'],
      printerEnvironmentImage: _splitString(map['printerEnvironmentImage']),
      evacuationEncreImage: _splitString(map['evacuationEncreImage']),
      niveauEncreImage: _splitString(map['niveauEncreImage']),
      photoStationEncreImage: _splitString(map['photoStationEncreImage']),
      nozzelImage: _splitString(map['nozzelImage']),
      regulTension: map['regulTension'],
      capaRegulTension: map['capaRegulTension'],
      priseT: map['priseT'],
      local: map['local'],
      temp: map['temp'],
      encreJxP: map['encreJxP'],
      netJxP: map['netJxP'],
      etatGenIm: map['etatGenIm'],
      problemeDecrit: map['problemeDecrit'],
      problemeEstime: map['problemeEstime'],
      changTete: map['changTete'],
      changCaps: map['changCaps'],
      dampers: map['dampers'],
      wiper: map['wiper'],
      changPom: map['changPom'],
      graisRail: map['graisRail'],
      changEncod: map['changEncod'],
      changRast: map['changRast'] ?? 'Non',
      changRastU: map['changRastU'] ?? 'Non',
      capsU: map['capsU'],
      dampersU: map['dampersU'],
      wiperU: map['wiperU'],
      pompeU: map['pompeU'],
      roulRailU: map['roulRailU'],
      changEncodU: map['changEncodU'],
      probRes: map['probRes'],
      problemePostIntervention: map['problemePostIntervention'],
      signatureImagePath: map['signatureImagePath'],
      signatureTime: map['signatureTime'],
      contratStatus: map['contratStatus'],
      entretienType: map['entretienType'],
      nbTetesChangees: map['nbTetesChangees'],
      datesPremiereAnnee: map['datesPremiereAnnee']?.split('|'),
      etatMachine: map['etatMachine'],
      prochainEntretien: map['prochainEntretien'],
    );
  }

  /// Créer une copie de l'objet avec des valeurs mises à jour
  Entretien copyWith({
    int? id,
    int? contactId,
    String? date,
    String? heureArrivee,
    String? printerEnvironmentComment,
    List<String>? printerEnvironmentImage,
    String? evacuationEncreComment,
    List<String>? evacuationEncreImage,
    String? niveauEncreComment,
    List<String>? niveauEncreImage,
    String? niveauEncreSelection,
    String? photoStationEncreComment,
    List<String>? photoStationEncreImage,
    String? nozzelComment,
    List<String>? nozzelImage,
    String? regulTension,
    String? capaRegulTension,
    String? priseT,
    String? local,
    String? temp,
    String? encreJxP,
    String? netJxP,
    String? etatGenIm,
    String? problemeDecrit,
    String? problemeEstime,
    String? changTete,
    String? changCaps,
    String? dampers,
    String? wiper,
    String? changPom,
    String? graisRail,
    String? changEncod,
    String? changRast,
    String? capsU,
    String? dampersU,
    String? wiperU,
    String? pompeU,
    String? roulRailU,
    String? changEncodU,
    String? changRastU,
    String? probRes,
    String? problemePostIntervention,
    String? signatureImagePath,
    String? signatureTime,
    String? contratStatus,
    String? entretienType,
    int? nbTetesChangees,
    List<String>? datesPremiereAnnee,
    String? etatMachine,
    String? prochainEntretien,
  }) {
    return Entretien(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      date: date ?? this.date,
      heureArrivee: heureArrivee ?? this.heureArrivee,
      printerEnvironmentComment:
          printerEnvironmentComment ?? this.printerEnvironmentComment,
      printerEnvironmentImage:
          printerEnvironmentImage ?? this.printerEnvironmentImage,
      evacuationEncreComment:
          evacuationEncreComment ?? this.evacuationEncreComment,
      evacuationEncreImage: evacuationEncreImage ?? this.evacuationEncreImage,
      niveauEncreComment: niveauEncreComment ?? this.niveauEncreComment,
      niveauEncreImage: niveauEncreImage ?? this.niveauEncreImage,
      niveauEncreSelection: niveauEncreSelection ?? this.niveauEncreSelection,
      photoStationEncreComment:
          photoStationEncreComment ?? this.photoStationEncreComment,
      photoStationEncreImage:
          photoStationEncreImage ?? this.photoStationEncreImage,
      nozzelComment: nozzelComment ?? this.nozzelComment,
      nozzelImage: nozzelImage ?? this.nozzelImage,
      regulTension: regulTension ?? this.regulTension,
      capaRegulTension: capaRegulTension ?? this.capaRegulTension,
      priseT: priseT ?? this.priseT,
      local: local ?? this.local,
      temp: temp ?? this.temp,
      encreJxP: encreJxP ?? this.encreJxP,
      netJxP: netJxP ?? this.netJxP,
      etatGenIm: etatGenIm ?? this.etatGenIm,
      problemeDecrit: problemeDecrit ?? this.problemeDecrit,
      problemeEstime: problemeEstime ?? this.problemeEstime,
      changTete: changTete ?? this.changTete,
      changCaps: changCaps ?? this.changCaps,
      dampers: dampers ?? this.dampers,
      wiper: wiper ?? this.wiper,
      changPom: changPom ?? this.changPom,
      graisRail: graisRail ?? this.graisRail,
      changEncod: changEncod ?? this.changEncod,
      changRast: changRast ?? this.changRast,
      changRastU: changRastU ?? this.changRastU,
      capsU: capsU ?? this.capsU,
      dampersU: dampersU ?? this.dampersU,
      wiperU: wiperU ?? this.wiperU,
      pompeU: pompeU ?? this.pompeU,
      roulRailU: roulRailU ?? this.roulRailU,
      changEncodU: changEncodU ?? this.changEncodU,
      probRes: probRes ?? this.probRes,
      problemePostIntervention:
          problemePostIntervention ?? this.problemePostIntervention,
      signatureImagePath: signatureImagePath ?? this.signatureImagePath,
      signatureTime: signatureTime ?? this.signatureTime,
      contratStatus: contratStatus ?? this.contratStatus,
      entretienType: entretienType ?? this.entretienType,
      nbTetesChangees: nbTetesChangees ?? this.nbTetesChangees,
      datesPremiereAnnee: datesPremiereAnnee ?? this.datesPremiereAnnee,
      etatMachine: etatMachine ?? this.etatMachine,
      prochainEntretien: prochainEntretien ?? this.prochainEntretien,
    );
  }

  @override
  List<Object?> get props => [
        id,
        contactId,
        date,
        heureArrivee,
        printerEnvironmentComment,
        printerEnvironmentImage,
        evacuationEncreComment,
        evacuationEncreImage,
        niveauEncreComment,
        niveauEncreImage,
        niveauEncreSelection,
        photoStationEncreComment,
        photoStationEncreImage,
        nozzelComment,
        nozzelImage,
        regulTension,
        capaRegulTension,
        priseT,
        local,
        temp,
        encreJxP,
        netJxP,
        etatGenIm,
        problemeDecrit,
        problemeEstime,
        changTete,
        changCaps,
        dampers,
        wiper,
        changPom,
        graisRail,
        changEncod,
        changRast,
        capsU,
        dampersU,
        wiperU,
        pompeU,
        roulRailU,
        changEncodU,
        changRastU,
        probRes,
        problemePostIntervention,
        signatureImagePath,
        signatureTime,
        contratStatus,
        entretienType,
        nbTetesChangees,
        datesPremiereAnnee,
        etatMachine,
        prochainEntretien,
      ];
}
