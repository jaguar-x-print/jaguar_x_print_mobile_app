// selected_contacts_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaguar_x_print/api/database.dart';
import 'package:jaguar_x_print/models/contact_model.dart';

class SelectedContactsCubit extends Cubit<List<Contact>> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  SelectedContactsCubit() : super([]);

  // Charger les contacts depuis SQLite
  Future<void> loadContacts() async {
    try {
      final contacts = await _databaseHelper.getContacts();
      emit(contacts);
    } catch (e) {
      throw Exception("Erreur lors du chargement des contacts : $e");
    }
  }

  // Ajouter un contact et le sauvegarder dans SQLite
  Future<void> addContact(Contact contact) async {
    try {
      if (!state.contains(contact)) {
        await _databaseHelper.insertContact(contact);
        final updatedContacts = await _databaseHelper.getContacts();
        emit(updatedContacts);
      }
    } catch (e) {
      throw Exception("Erreur lors de l'ajout du contact : $e");
    }
  }

  // Supprimer un contact et le retirer de SQLite
  Future<void> removeContact(Contact contact) async {
    try {
      if (contact.id != null) {
        await _databaseHelper.deleteContact(contact.id!);
        final updatedContacts = await _databaseHelper.getContacts();
        emit(updatedContacts);
      }
    } catch (e) {
      throw Exception("Erreur lors de la suppression du contact : $e");
    }
  }

  // Mettre à jour la liste des contacts
  Future<void> setContacts(List<Contact> contacts) async {
    try {
      await _databaseHelper.deleteAllContacts();
      for (final contact in contacts) {
        await _databaseHelper.insertContact(contact);
      }
      final updatedContacts = await _databaseHelper.getContacts();
      emit(updatedContacts);
    } catch (e) {
      throw Exception("Erreur lors de la mise à jour des contacts : $e");
    }
  }
}