import 'package:jaguar_x_print/models/paiement_model.dart';

abstract class PaiementState {}

class PaiementInitial extends PaiementState {}

class PaiementLoading extends PaiementState {}

class PaiementSuccess extends PaiementState {
  final List<Paiement> paiements;
  final String message;

  PaiementSuccess(this.paiements, {this.message = ''});
}

class PaiementError extends PaiementState {
  final String message;

  PaiementError(this.message);
}