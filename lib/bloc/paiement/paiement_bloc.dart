import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:jaguar_x_print/api/database.dart';
import 'package:jaguar_x_print/bloc/paiement/paiement_event.dart';
import 'package:jaguar_x_print/bloc/paiement/paiement_state.dart';


class PaiementBloc extends Bloc<PaiementEvent, PaiementState> {
  final DatabaseHelper dbHelper;

  PaiementBloc({required this.dbHelper}) : super(PaiementInitial()) {
    on<LoadPaiements>(_onLoadPaiements);
    on<AddPaiement>(_onAddPaiement);
    on<UpdatePaiement>(_onUpdatePaiement);
    on<DeletePaiement>(_onDeletePaiement);

    // Nouveaux gestionnaires pour pause/reprise
    on<PaiementPauseEvent>((event, emit) => _onPause(event, emit));
    on<PaiementResumeEvent>((event, emit) => _onResume(event, emit));
  }

  void _onPause(PaiementPauseEvent event, Emitter<PaiementState> emit) {
    // Libérer les ressources
    emit(PaiementPaused());
  }

  void _onResume(PaiementResumeEvent event, Emitter<PaiementState> emit) {
    // Réinitialiser si nécessaire
    if (state is PaiementPaused) {
      emit(PaiementInitial());
    }
  }

  Future<void> _onLoadPaiements(
      LoadPaiements event,
      Emitter<PaiementState> emit,
      ) async {
    try {
      emit(PaiementLoading());

      // Vérification explicite dans la base de données
      final exists = await dbHelper.contactExists(event.contactId);
      if (!exists) {
        throw Exception('Contact introuvable dans la base de données');
      }

      final paiements = await dbHelper.getPaiementsByContact(event.contactId);

      // Vérification de la cohérence des données
      if (paiements.any((p) => p.contactId != event.contactId)) {
        throw Exception('Incohérence des données de paiement');
      }

      emit(PaiementSuccess(paiements));
    } catch (e) {
      emit(PaiementError('Erreur de chargement : ${e.toString()}'));
      rethrow;
    }
  }

  Future<void> _onAddPaiement(AddPaiement event, Emitter<PaiementState> emit) async {
    emit(PaiementLoading());
    try {
      await dbHelper.insertPaiement(event.paiement);
      final paiements = await dbHelper.getPaiementsByContact(event.contactId);
      add(LoadPaiements(contactId: event.contactId));

      // Émettre deux états pour forcer le rebuild
      emit(PaiementLoading()); // État intermédiaire
      emit(PaiementSuccess(paiements, message: 'Paiement ajouté avec succès'));
    } catch (e) {
      emit(PaiementError('Erreur d\'ajout: ${e.toString()}'));
    }
  }

  Future<void> _onUpdatePaiement(UpdatePaiement event, Emitter<PaiementState> emit) async {
    emit(PaiementLoading());
    try {
      await dbHelper.updatePaiement(event.paiement);
      final paiements = await dbHelper.getPaiementsByContact(event.contactId);
      emit(PaiementSuccess(paiements, message: 'Paiement modifié avec succès'));
    } catch (e) {
      emit(PaiementError('Erreur de modification: ${e.toString()}'));
    }
  }

  Future<void> _onDeletePaiement(DeletePaiement event, Emitter<PaiementState> emit) async {
    emit(PaiementLoading());
    try {
      await dbHelper.deletePaiement(event.paiementId);
      final paiements = await dbHelper.getPaiementsByContact(event.contactId);
      emit(PaiementSuccess(paiements, message: 'Paiement supprimé avec succès'));
    } catch (e) {
      emit(PaiementError('Erreur de suppression: ${e.toString()}'));
    }
  }
}

// Ajouter ce nouvel état
class PaiementPaused extends PaiementState {}