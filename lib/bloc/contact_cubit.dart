import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jaguar_x_print/api/database.dart';
import 'package:jaguar_x_print/models/contact_model.dart';

class ContactState extends Equatable {
  final List<Contact> contacts;
  final Contact? selectedContact;

  const ContactState({required this.contacts, this.selectedContact});

  @override
  List<Object?> get props => [contacts, selectedContact];
}

class ContactCubit extends Cubit<ContactState> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  ContactCubit() : super(const ContactState(contacts: [])) {
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final contacts = await _databaseHelper.getContacts();
    emit(ContactState(contacts: contacts));
  }

  Future<void> addContact(Contact contact) async {
    await _databaseHelper.insertContact(contact);
    _loadContacts();
  }

  void selectContact(Contact contact) {
    emit(ContactState(contacts: state.contacts, selectedContact: contact));
  }

  Future<void> deleteContact(int id) async {
    await _databaseHelper.deleteContact(id);
    _loadContacts();
  }

  Future<void> updateContact(Contact contact) async {
    await _databaseHelper.updateContact(contact);
    _loadContacts();
  }

  Future<void> addCodeMachineFromCodeMachine(int contactId, String newCode) async {
    final db = await DatabaseHelper.database;
    final contact = await _databaseHelper.getContactById(contactId);

    if (contact != null) {
      final updatedCodesMachine = [...contact.codesMachine, newCode];
      final updatedContact = contact.copyWith(codesMachine: updatedCodesMachine);

      await db.update(
        'contacts',
        updatedContact.toMap(),
        where: 'id = ?',
        whereArgs: [contactId],
      );

      await _loadContacts();
    }
    _loadContacts();
  }

  Future<void> modifyCodeMachineFromCodeMachine(
    int contactId, String oldCode, String newCode) async {
    final db = await DatabaseHelper.database;
    final contact = await _databaseHelper.getContactById(contactId);

    if (contact != null) {
      final updatedCodesMachine = contact.codesMachine.map((code) {
        if (code == oldCode) {
          return newCode;
        }
        return code;
      }).toList();

      final updatedContact = contact.copyWith(codesMachine: updatedCodesMachine);

      await db.update(
        'contacts',
        updatedContact.toMap(),
        where: 'id = ?',
        whereArgs: [contactId],
      );

      await _loadContacts();
    }
    _loadContacts();
  }

  Future<void> updateContactDetailsFromCodeMachine(
      String commentaire,
      String blocageHeures,
      String? dateBlocage,
      ) async {
    if (state.selectedContact != null) {
      final updatedContact = state.selectedContact!.copyWith(
        commentaire: commentaire,
        blocageHeures: blocageHeures,
        dateOfLock: dateBlocage,
      );
      await _databaseHelper.updateContact(updatedContact);
      _loadContacts();
    }
  }

  Future<void> updateContactCodes(int contactId, List<String> codes) async {
    final db = await DatabaseHelper.database;
    await db.update(
      'contacts',
      {'codesMachine': jsonEncode(codes)},
      where: 'id = ?',
      whereArgs: [contactId],
    );
    _loadContacts();
  }

  Future<void> addCodeMachine(String codeMachine) async {
    if (state.selectedContact != null) {
      final updatedCodesMachine = List<String>.from(state.selectedContact!.codesMachine)..add(codeMachine);
      final updatedContact = state.selectedContact!.copyWith(codesMachine: updatedCodesMachine);
      await _databaseHelper.updateContact(updatedContact);
      final updatedContacts = state.contacts.map((contact) {
        return contact == state.selectedContact ? updatedContact : contact;
      }).toList();
      emit(ContactState(contacts: updatedContacts, selectedContact: updatedContact));
    }
    _loadContacts();
  }

  Future<void> updateCodeMachine(String codeMachine) async {
    if (state.selectedContact != null) {
      final updatedContact = state.selectedContact!.copyWith(codesMachine: [codeMachine]);
      await _databaseHelper.updateContact(updatedContact);
      final updatedContacts = state.contacts.map((contact) {
        return contact == state.selectedContact ? updatedContact : contact;
      }).toList();
      emit(ContactState(contacts: updatedContacts, selectedContact: updatedContact));
    }
    _loadContacts();
  }

  Future<void> updatePhotoFacade(String imagePath) async {
    if (state.selectedContact != null) {
      final updatedContact = state.selectedContact!.copyWith(photoFacade: imagePath);
      await _databaseHelper.updateContact(updatedContact);
      final updatedContacts = state.contacts.map((contact) {
        return contact == state.selectedContact ? updatedContact : contact;
      }).toList();
      emit(ContactState(contacts: updatedContacts, selectedContact: updatedContact));
    }
  }

  Future<void> updateContactDetails(
      String commentaire,
      String blocageHeures,
      String? dateBlocage,
      LatLng? coordinates,
      ) async {
    if (state.selectedContact != null) {
      final updatedContact = state.selectedContact!.copyWith(
        commentaire: commentaire,
        blocageHeures: blocageHeures,
        dateOfLock: dateBlocage,
        latitude: coordinates?.latitude,
        longitude: coordinates?.longitude,
      );
      await _databaseHelper.updateContact(updatedContact);
      _loadContacts();
    }
  }

  Future<void> updateCollaborator(
      Map<String, dynamic> oldCollaborator,
      Map<String, dynamic> updatedCollaborator) async {
    if (state.selectedContact != null) {
      final collaboratorsJson = state.selectedContact!.collaborators;
      if (collaboratorsJson != null) {
        try {
          final collaborators = jsonDecode(collaboratorsJson) as List<dynamic>;
          final index = collaborators.indexWhere((element) =>
              mapEquals(element as Map<String, dynamic>, oldCollaborator));
          if (index != -1) {
            collaborators[index] = updatedCollaborator;
            final updatedCollaboratorsJson = jsonEncode(collaborators);
            final updatedContact = state.selectedContact!.copyWith(
              collaborators: updatedCollaboratorsJson,
            );
            await _databaseHelper.updateContact(updatedContact);
            _loadContacts();
          }
        } catch (e) {
          if (kDebugMode) {
            print('Erreur lors de la mise à jour du collaborateur: $e');
          }
        }
      }
    }
  }

  Future<void> deleteCollaborator(Map<String, dynamic> collaboratorToDelete) async {
    if (state.selectedContact != null) {
      final collaboratorsJson = state.selectedContact!.collaborators;
      if (collaboratorsJson != null) {
        try {
          final collaborators = jsonDecode(collaboratorsJson) as List<dynamic>;
          final updatedCollaborators = collaborators.where((collaborator) =>
          !mapEquals(collaborator as Map<String, dynamic>, collaboratorToDelete)).toList();
          final updatedCollaboratorsJson = jsonEncode(updatedCollaborators);
          final updatedContact = state.selectedContact!.copyWith(
            collaborators: updatedCollaboratorsJson,
          );
          await _databaseHelper.updateContact(updatedContact);
          _loadContacts();
        } catch (e) {
          if (kDebugMode) {
            print('Erreur lors de la suppression du collaborateur: $e');
          }
        }
      }
    }
  }

  void pause() {
    // Annuler les opérations en cours si nécessaire
    // Exemple: _subscription?.cancel();
  }

  // Nouvelle méthode pour réinitialiser
  void resume() {
    if (state.contacts.isEmpty) {
      _loadContacts();
    }
  }

  // Modification de la méthode disposeTemporarily
  void disposeTemporarily() {
    pause();
  }

  // Modification de la méthode reinitialize
  void reinitialize() {
    resume();
  }
}