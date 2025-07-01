import 'package:jaguar_x_print/models/paiement_model.dart';

abstract class PaiementEvent {}

class AddPaiement extends PaiementEvent {
  final Paiement paiement;
  final int contactId;

  AddPaiement({required this.paiement, required this.contactId});
}

class UpdatePaiement extends PaiementEvent {
  final Paiement paiement;
  final int contactId;

  UpdatePaiement({required this.paiement, required this.contactId,});
}

class DeletePaiement extends PaiementEvent {
  final int paiementId;
  final int contactId;

  DeletePaiement({required this.paiementId, required this.contactId});
}

class LoadPaiements extends PaiementEvent {
  final int contactId;

  LoadPaiements({required this.contactId});
}

class PaiementPauseEvent extends PaiementEvent {}
class PaiementResumeEvent extends PaiementEvent {}