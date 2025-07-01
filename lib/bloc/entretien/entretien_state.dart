// entretien_state.dart
import 'package:jaguar_x_print/models/entretien_model.dart';

abstract class EntretienState {}

class EntretienInitialState extends EntretienState {}

class EntretienLoadingState extends EntretienState {}

class EntretienSavedState extends EntretienState {
  final Entretien entretien;

  EntretienSavedState({required this.entretien});
}

class EntretienErrorState extends EntretienState {
  final String message;

  EntretienErrorState({required this.message});
}
