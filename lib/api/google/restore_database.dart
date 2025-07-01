import 'package:jaguar_x_print/api/database.dart';
import 'package:sqflite/sqflite.dart';

Future<void> restoreData(Map<String, dynamic> data) async {
  final db = await DatabaseHelper.database;

  try {
    await db.transaction((txn) async {
      // Vérification des données avant suppression
      if (data.isEmpty) throw Exception('Données de restauration invalides');

      await _clearExistingData(txn);
      await _restoreTables(txn, data);
    });
  } catch (e) {
    throw Exception('Échec de la restauration: ${e.toString()}');
  }
}

Future<void> _clearExistingData(Transaction txn) async {
  await txn.delete('courriers');
  await txn.delete('paiements');
  await txn.delete('entretiens');
  await txn.delete('users');
  await txn.delete('contacts');
}

Future<void> _restoreTables(Transaction txn, Map<String, dynamic> data) async {
  // Vérification null-safe avec listes par défaut
  final List<dynamic> contacts = data['contacts'] ?? [];
  final List<dynamic> users = data['users'] ?? [];
  final List<dynamic> entretiens = data['entretiens'] ?? [];
  final List<dynamic> paiements = data['paiements'] ?? [];
  final List<dynamic> courriers = data['courriers'] ?? [];

  // Validation des données
  _validateDataStructure(contacts, users, entretiens, paiements, courriers);

  // Restauration avec batch insert
  final batch = txn.batch();

  for (var contact in contacts.cast<Map<String, dynamic>>()) {
    batch.insert('contacts', _sanitizeData(contact));
  }

  for (var user in users.cast<Map<String, dynamic>>()) {
    batch.insert('users', _sanitizeData(user));
  }

  for (var entretien in entretiens.cast<Map<String, dynamic>>()) {
    batch.insert('entretiens', _sanitizeData(entretien));
  }

  for (var paiement in paiements.cast<Map<String, dynamic>>()) {
    batch.insert('paiements', _sanitizeData(paiement));
  }

  for (var courrier in courriers.cast<Map<String, dynamic>>()) {
    batch.insert('courriers', _sanitizeData(courrier));
  }

  await batch.commit();
}

Map<String, dynamic> _sanitizeData(Map<String, dynamic> data) {
  return data.map((key, value) {
    // Convertit les null en valeurs par défaut selon le schéma
    if (value == null) {
      return MapEntry(key, _getDefaultValueForColumn(key));
    }
    return MapEntry(key, value);
  });
}

dynamic _getDefaultValueForColumn(String columnName) {
  // Ajouter les conversions nécessaires selon votre schéma de base de données
  switch (columnName) {
    case 'montant':
      return '0';
    case 'dateCreation':
      return DateTime.now().toIso8601String();
    default:
      return '';
  }
}

void _validateDataStructure(
    List<dynamic> contacts,
    List<dynamic> users,
    List<dynamic> entretiens,
    List<dynamic> paiements,
    List<dynamic> courriers,
    ) {
  final requiredTables = {
    'contacts': contacts,
    'users': users,
    'entretiens': entretiens,
    'paiements': paiements,
    'courriers': courriers,
  };

  for (var entry in requiredTables.entries) {
    if (entry.value.isEmpty) {
      print('Avertissement: Table ${entry.key} vide pendant la restauration');
    }
  }
}