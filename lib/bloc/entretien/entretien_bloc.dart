import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaguar_x_print/api/database.dart';
import 'package:jaguar_x_print/models/entretien_model.dart';
import 'package:jaguar_x_print/bloc/entretien/entretien_event.dart';
import 'package:jaguar_x_print/bloc/entretien/entretien_state.dart';

class EntretienBloc extends Bloc<EntretienEvent, EntretienState> {
  final DatabaseHelper _databaseHelper;

  EntretienBloc(this._databaseHelper) : super(EntretienInitialState()) {
    on<SaveEntretienEvent>((event, emit) async {
      try {
        emit(EntretienLoadingState());

        final entretien = Entretien.fromMap(event.data);

        emit(EntretienSavedState(entretien: entretien));
      } catch (e, stackTrace) {
        emit(EntretienErrorState(message: 'Erreur: ${e.toString()}'));
        debugPrintStack(stackTrace: stackTrace);
      }
    });
    // Nouveaux gestionnaires pour pause/reprise
    on<EntretienPauseEvent>((event, emit) => _onPause(event, emit));
    on<EntretienResumeEvent>((event, emit) => _onResume(event, emit));
  }

  void _onPause(EntretienPauseEvent event, Emitter<EntretienState> emit) {
    // Libérer les ressources
    // Exemple: _subscription?.cancel();
    emit(EntretienPausedState());
  }

  void _onResume(EntretienResumeEvent event, Emitter<EntretienState> emit) {
    // Réinitialiser si nécessaire
    if (state is EntretienPausedState) {
      emit(EntretienInitialState());
      // Ajouter un événement pour recharger si nécessaire
    }
  }
}

// Ajouter ce nouvel état
class EntretienPausedState extends EntretienState {}
