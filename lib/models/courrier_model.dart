import 'package:equatable/equatable.dart';

class Courrier extends Equatable {
  final int? id;
  final int? contactId;
  final DateTime? date;
  final String? dateFormatted;
  final String? documentPath;
  final String? serverDocumentUrl;

  const Courrier({
    this.id,
    this.contactId,
    this.date,
    this.dateFormatted,
    this.documentPath,
    this.serverDocumentUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contactId': contactId,
      'date': date?.toIso8601String(),
      'dateFormatted': dateFormatted,
      'documentPath': documentPath,
      'serverDocumentUrl': serverDocumentUrl,
    };
  }

  factory Courrier.fromMap(Map<String, dynamic> map) {
    return Courrier(
      id: map['id'],
      contactId: map['contactId'],
      date: DateTime.parse(map['date']),
      dateFormatted: map['dateFormatted'],
      documentPath: map['documentPath'],
      serverDocumentUrl: map['serverDocumentUrl'],
    );
  }

  Courrier copyWith({
    int? id,
    int? contactId,
    DateTime? date,
    String? dateFormatted,
    String? documentPath,
    String? serverDocumentUrl,
  }) {
    return Courrier(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      date: date ?? this.date,
      dateFormatted: dateFormatted ?? this.dateFormatted,
      documentPath: documentPath ?? this.documentPath,
      serverDocumentUrl: serverDocumentUrl ?? this.serverDocumentUrl,
    );
  }

  @override
  List<Object?> get props => [
    id,
    contactId,
    date,
    dateFormatted,
    documentPath,
    serverDocumentUrl,
  ];
}