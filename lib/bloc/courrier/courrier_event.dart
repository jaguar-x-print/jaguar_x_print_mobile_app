abstract class CourrierEvent {}

class AddCourrierEvent extends CourrierEvent {
  final int contactId;
  final DateTime date;
  final String dateFormatted;
  final String documentPath;
  final String serverDocumentUrl;

  AddCourrierEvent({
    required this.contactId,
    required this.date,
    required this.dateFormatted,
    required this.documentPath,
    required this.serverDocumentUrl,
  });
}

class LoadCourriers extends CourrierEvent {
  final int contactId;

  LoadCourriers({required this.contactId});
}

class CourrierPauseEvent extends CourrierEvent {}
class CourrierResumeEvent extends CourrierEvent {}