import 'package:flutter/foundation.dart';
import 'package:jaguar_x_print/models/courrier_model.dart';
import 'package:jaguar_x_print/models/entretien_model.dart';
import 'package:jaguar_x_print/models/paiement_model.dart';
import 'package:jaguar_x_print/models/user_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:jaguar_x_print/models/contact_model.dart';
import 'package:intl/intl.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static const int _version = 4; // Increment the database version

  // Récupérer l'instance de la base de données
  static Future<Database> get database async {
    if (_database != null) return _database!;

    //await _deleteDatabase(); // Uncomment for debugging to force recreation
    _database = await _initDatabase();
    return _database!;
  }

  // Supprime la base de données existante
  static Future<void> _deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'jaguar.db');
    await deleteDatabase(path);
  }

  // Réinitialisation manuelle de la base de données
  static Future<void> resetDatabase() async {
    await _deleteDatabase(); // Ensure deletion before re-initialization
    _database = await _initDatabase();
  }

// Méthode pour gérer les mises à jour de schéma
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Ajouter la nouvelle colonne pour les utilisateurs existants
      await db.execute('''
        ALTER TABLE contacts
        ADD COLUMN dateInstallationMachine TEXT DEFAULT '01/01/2025'
      ''');
    }
    if (oldVersion < 4) {
      // Add passwordPaiement column for existing users
      await db.execute('''
        ALTER TABLE users
        ADD COLUMN passwordPaiement TEXT DEFAULT '123'
      ''');
    }
  }

  // Initialisation de la base de données
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'jaguar.db');

    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Création des tables
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contacts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        nombreTetesLecture INTEGER,
        pCountryCode TEXT,
        wCountryCode TEXT,
        phone TEXT,
        whatsapp TEXT,
        quartier TEXT,
        ville TEXT,
        groupeSAV TEXT,
        dateDebut TEXT,
        dateFin TEXT,
        nbAnnees INTEGER,
        nbMois INTEGER,
        nbJours INTEGER,
        montant TEXT,
        jourPaiement INTEGER,
        dateCreation TEXT,
        codeClient TEXT,
        photoFacade TEXT,
        profilClient TEXT,
        codesMachine TEXT,
        commentaire TEXT,
        blocageHeures TEXT,
        dateOfLock TEXT,
        companyName TEXT,
        jobTitle TEXT,
        collaborators TEXT,
        latitude REAL,
        longitude REAL,
        serverSynced INTEGER DEFAULT 0,
        dateInstallationMachine TEXT DEFAULT '01/01/2025'
      )
    ''');

    await db.execute('''
      CREATE TABLE users(
        uid TEXT PRIMARY KEY,
        username TEXT,
        email TEXT UNIQUE,
        passwordPaiement TEXT DEFAULT '123',
        profilePhotoUrl TEXT
      )
    ''');

    await db.execute('''
    CREATE TABLE entretiens(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      contactId INTEGER,
      date TEXT,
      prochainEntretien TEXT,
      heureArrivee TEXT,
      printerEnvironmentComment TEXT,
      printerEnvironmentImage TEXT,
      evacuationEncreComment TEXT,
      evacuationEncreImage TEXT,
      niveauEncreComment TEXT,
      niveauEncreImage TEXT,
      niveauEncreSelection TEXT,
      photoStationEncreComment TEXT,
      photoStationEncreImage TEXT,
      nozzelComment TEXT,
      nozzelImage TEXT,
      regulTension TEXT,
      capaRegulTension TEXT,
      priseT TEXT,
      local TEXT,
      temp TEXT,
      encreJxP TEXT,
      netJxP TEXT,
      etatGenIm TEXT,
      problemeDecrit TEXT,
      problemeEstime TEXT,
      changTete TEXT,
      changCaps TEXT,
      dampers TEXT,
      wiper TEXT,
      changPom TEXT,
      graisRail TEXT,
      changEncod TEXT,
      capsU TEXT,
      dampersU TEXT,
      wiperU TEXT,
      pompeU TEXT,
      roulRailU TEXT,
      changEncodU TEXT,
      probRes TEXT,
      problemePostIntervention TEXT,
      signatureImagePath TEXT,
      signatureTime TEXT,
      contratStatus TEXT,
      entretienType TEXT,
      nbTetesChangees INTEGER,
      datesPremiereAnnee TEXT ,
      etatMachine TEXT,
      changRast TEXT DEFAULT 'Non',
      changRastU TEXT DEFAULT 'Non',
      FOREIGN KEY (contactId) REFERENCES contacts(id) ON DELETE CASCADE
    )
  ''');

    await db.execute('''
    CREATE TABLE paiements(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      contactId INTEGER,
      mois TEXT,
      date TEXT,
      mode TEXT,
      resteAPayer TEXT,
      penalite TEXT,
      FOREIGN KEY (contactId) REFERENCES contacts(id) ON DELETE CASCADE
    )
  ''');

    await db.execute('''
    CREATE TABLE courriers(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      contactId INTEGER,
      date TEXT,
      dateFormatted TEXT,
      documentPath TEXT,
      serverDocumentUrl TEXT,
      FOREIGN KEY (contactId) REFERENCES contacts(id) ON DELETE CASCADE
    )
  ''');
  }

  // Pour SQLite (mobile)
  Future<List<Contact>> getAllContactsForSync() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
    );
    if (kDebugMode) {
      print(maps);
    }
    return List.generate(maps.length, (i) => Contact.fromMap(maps[i]));
  }

  Future<void> markContactAsSynced(int id) async {
    final db = await database;
    await db.update(
      'contacts',
      {'serverSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Ajoutez cette méthode
  Future<List<UserModel>> getAllUsersForSync() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => UserModel.fromMap(maps[i]));
  }

  // Méthode pour récupérer les courriers non synchronisés
  Future<List<Courrier>> getUnsyncedCourriers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'courriers',
      //where: 'serverDocumentUrl IS NULL',
    );
    return List.generate(maps.length, (i) => Courrier.fromMap(maps[i]));
  }

// Méthode pour mettre à jour un courrier
  Future<int> updateCourrier(Courrier courrier) async {
    final db = await database;
    return db.update(
      'courriers',
      courrier.toMap(),
      where: 'id = ?',
      whereArgs: [courrier.id],
    );
  }

  // Ajouter les méthodes CRUD
  Future<int> insertCourrier(Courrier courrier) async {
    final db = await database;
    return await db.insert('courriers', courrier.toMap());
  }

  Future<int> deleteCourrier(int id) async {
    final db = await database;
    return await db.delete(
      'courriers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Courrier>> getCourriersByContact(int contactId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'courriers',
      where: 'contactId = ?',
      whereArgs: [contactId],
    );
    return List.generate(maps.length, (i) => Courrier.fromMap(maps[i]));
  }

  // Méthodes CRUD pour paiements
  Future<int> insertPaiement(Paiement paiement) async {
    final db = await database;
    return await db.insert('paiements', paiement.toMap());
  }

  Future<List<Paiement>> getPaiementsByContact(int contactId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'paiements',
      where: 'contactId = ?',
      whereArgs: [contactId],
    );
    return List.generate(maps.length, (i) => Paiement.fromMap(maps[i]));
  }

  // Vérifie l'existence d'un contact dans la base de données
  Future<bool> contactExists(int contactId) async {
    final db = await database;
    final result = await db.query(
      'contacts',
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [contactId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<int> updatePaiement(Paiement paiement) async {
    final db = await database;
    return await db.update(
      'paiements',
      paiement.toMap(),
      where: 'id = ?',
      whereArgs: [paiement.id],
    );
  }

  Future<int> deletePaiement(int id) async {
    final db = await database;
    return await db.delete(
      'paiements',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Méthode d'insertion
  Future<int> insertEntretien(Entretien entretien) async {
    final db = await database;
    return await db.insert('entretiens', entretien.toMap());
  }

  // Méthode de récupération par contact
  Future<List<Entretien>> getEntretiensByContact(int contactId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'entretiens',
      where: 'contactId = ?',
      whereArgs: [contactId],
    );
    return List.generate(maps.length, (i) => Entretien.fromMap(maps[i]));
  }

  // Méthode de mise à jour
  Future<int> updateEntretien(Entretien entretien) async {
    final db = await database;
    return await db.update(
      'entretiens',
      entretien.toMap(),
      where: 'id = ?',
      whereArgs: [entretien.id],
    );
  }

  // Méthode de suppression
  Future<int> deleteEntretien(int id) async {
    final db = await database;
    return await db.delete(
      'entretiens',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateNextMaintenanceDate(int contactId, DateTime date) async {
    final db = await database;
    return await db.update(
      'entretiens',
      {'nextMaintenanceDate': DateFormat('dd/MM/yyyy').format(date)},
      where: 'contactId = ?',
      whereArgs: [contactId],
    );
  }

  // Insert a new user into the database
  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<int> upsertUser(UserModel user) async {
    final existing = await getUserByEmail(user.email!);
    return existing != null ? await updateUser(user) : await insertUser(user);
  }

  // Get user by UID
  Future<UserModel?> getUser(String uid) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
    );
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  // Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  // Update user
  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'uid = ?',
      whereArgs: [user.uid],
    );
  }

  // Update passwordPaiement for a user
  Future<void> updatePasswordPaiement(String uid, String newPassword) async {
    final db = await database;
    await db.update(
      'users',
      {'passwordPaiement': newPassword},
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  // Delete user
  Future<int> deleteUser(String uid) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  // Insert a new contact into the database
  Future<int> insertContact(Contact contact) async {
    final db = await database;
    return await db.insert('contacts', contact.toMap());
  }

  // Get all contacts from the database
  Future<List<Contact>> getContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('contacts');
    return List.generate(maps.length, (i) {
      return Contact.fromMap(maps[i]);
    });
  }

  // Update an existing contact in the database
  Future<int> updateContact(Contact contact) async {
    final db = await database;
    return await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  // Delete a contact from the database
  Future<int> deleteContact(int id) async {
    final db = await database;
    return await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all contacts from the database (optional method)
  Future<int> deleteAllContacts() async {
    final db = await database;
    return await db.delete('contacts');
  }

  // Récupérer les heures de blocage pour un contact spécifique
  Future<String?> getBlocageHeures(int contactId) async {
    final db = await database;
    final result = await db.query(
      'contacts',
      columns: ['blocageHeures'],
      where: 'id = ?',
      whereArgs: [contactId],
    );

    if (result.isNotEmpty) {
      return result.first['blocageHeures'] as String?;
    }
    return null;
  }

  // Get contact by ID
  Future<Contact?> getContactById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    }
    return null;
  }
}