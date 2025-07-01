// entretien_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaguar_x_print/api/database.dart';
import 'package:jaguar_x_print/models/entretien_model.dart';

class EntretienCubit extends Cubit<List<Entretien>> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final int contactId;

  EntretienCubit({required this.contactId}) : super([]);

  Future<void> loadEntretiens() async {
    try {
      final entretiens = await _dbHelper.getEntretiensByContact(contactId);
      emit(entretiens);
    } catch (e) {
      emit([]);
    }
  }

  Future<void> deleteEntretien(int id) async {
    await _dbHelper.deleteEntretien(id);
    await loadEntretiens();
  }
}