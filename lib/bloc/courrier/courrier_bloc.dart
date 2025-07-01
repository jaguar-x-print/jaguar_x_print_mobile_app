import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaguar_x_print/api/database.dart';
import 'package:jaguar_x_print/bloc/courrier/courrier_event.dart';
import 'package:jaguar_x_print/bloc/courrier/courrier_state.dart';
import 'package:jaguar_x_print/models/courrier_model.dart';

class CourrierBloc extends Bloc<CourrierEvent, CourrierState> {
  final DatabaseHelper dbHelper;

  CourrierBloc(this.dbHelper) : super(CourrierInitial()) {
    on<AddCourrierEvent>((event, emit) async {
      emit(CourrierLoading());
      try {
        final courrier = Courrier(
          contactId: event.contactId,
          date: event.date,
          dateFormatted: event.dateFormatted,
          documentPath: event.documentPath,
          serverDocumentUrl: event.serverDocumentUrl,
        );
        await dbHelper.insertCourrier(courrier);
        emit(CourrierAdded());
      } catch (e) {
        emit(CourrierError(e.toString()));
      }
    });

    // Nouveaux gestionnaires pour pause/reprise
    on<CourrierPauseEvent>((event, emit) => _onPause(event, emit));
    on<CourrierResumeEvent>((event, emit) => _onResume(event, emit));
  }

  void _onPause(CourrierPauseEvent event, Emitter<CourrierState> emit) {
    // Libérer les ressources
    emit(CourrierPaused());
  }

  void _onResume(CourrierResumeEvent event, Emitter<CourrierState> emit) {
    // Réinitialiser si nécessaire
    if (state is CourrierPaused) {
      emit(CourrierInitial());
    }
  }
}
// Ajouter ce nouvel état
class CourrierPaused extends CourrierState {}