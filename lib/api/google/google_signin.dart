// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:jaguar_x_print/api/database.dart';
import 'package:jaguar_x_print/models/courrier_model.dart';
import 'package:jaguar_x_print/models/entretien_model.dart';
import 'package:jaguar_x_print/models/paiement_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:jaguar_x_print/models/user_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';

// Classe pour gérer l'authentification Google
class GoogleSignInApi {
  static final _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/drive',
      'https://www.googleapis.com/auth/drive.metadata.readonly',
    ],
  );

  static Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();
  static Future<void> signOut() => _googleSignIn.signOut();
}

// Fonction pour obtenir le client HTTP authentifié
Future<http.Client?> _getAuthClient() async {
  final GoogleSignInAccount? account = await GoogleSignInApi.login();
  if (account == null) return null;

  final GoogleSignInAuthentication auth = await account.authentication;
  final accessToken = auth.accessToken;

  return GoogleAuthClient(accessToken!);
}

// Fonction pour sauvegarder sur Google Drive avec progression
Future<void> saveToGoogleDrive({
  Function(double progress)? onProgress,
  required BuildContext context,
}) async {
  try {
    // Vérification de la connexion internet
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Aucune connexion internet',
            style: TextStyle(color: whiteColor),
          ),
          backgroundColor: redColor,
        ),
      );
      return;
    }
    final authClient = await _getAuthClient();
    if (authClient == null) throw Exception('Authentification échouée');

    // Obtenir le fichier de base de données
    final dbPath = await getDatabasesPath();
    final dbFile = File(join(dbPath, 'jaguar.db'));

    // Vérifier l'existence du fichier
    if (!await dbFile.exists()) {
      throw Exception('Base de données introuvable');
    }

    // Sauvegarder sur Google Drive
    final driveApi = drive.DriveApi(authClient);
    // Modifier dans saveToGoogleDrive
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final driveFile = drive.File()
      ..name = 'jaguar_$timestamp.db'
      ..description = 'Sauvegarde du ${DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.now())}'
      ..parents = ['root'];

    final fileStream = dbFile.openRead();
    final fileLength = await dbFile.length();

    int uploadedBytes = 0;
    final response = await driveApi.files.create(
      driveFile,
      uploadMedia: drive.Media(
        fileStream.transform(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              uploadedBytes += data.length;
              onProgress?.call(uploadedBytes / fileLength);
              sink.add(data);
            },
          ),
        ),
        fileLength,
      ),
    );

    if (kDebugMode) {
      print("Sauvegarde réussie. ID: ${response.id}");
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Erreur de sauvegarde',
          style: TextStyle(color: whiteColor),
        ),
        backgroundColor: redColor,
      ),
    );
    if (kDebugMode) {
      print("Erreur sauvegarde: ${e.toString()}");
    }
    rethrow;
  } finally {
    // Réinitialiser la connexion
    //await DatabaseHelper.database;
  }
}

// Classe pour gérer l'authentification HTTP
class GoogleAuthClient extends http.BaseClient {
  final String _accessToken;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _client.send(request);
  }
}

// Ajout de la fonction getUsers à DatabaseHelper
extension DatabaseHelperExtension on DatabaseHelper {
  Future<List<UserModel>> getUsers() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) {
      return UserModel.fromMap(maps[i]);
    });
  }

  Future<List<Entretien>> getEntretiens() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('entretiens');
    return List.generate(maps.length, (i) {
      return Entretien.fromMap(maps[i]);
    });
  }

  Future<List<Paiement>> getPaiements() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('paiements');
    return List.generate(maps.length, (i) {
      return Paiement.fromMap(maps[i]);
    });
  }

  Future<List<Courrier>> getCourriers() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('courriers');
    return List.generate(maps.length, (i) {
      return Courrier.fromMap(maps[i]);
    });
  }

  Future<Map<String, dynamic>> getAllData() async {
    final db = await DatabaseHelper.database;

    // Récupérer les données des différentes tables
    final users = await db.query('users');
    final entretiens = await db.query('entretiens');
    final paiements = await db.query('paiements');
    final courriers = await db.query('courriers');
    final contacts = await db.query('contacts');

    // Retourner toutes les données sous forme de Map
    return {
      'users': users,
      'entretiens': entretiens,
      'paiements': paiements,
      'courriers': courriers,
      'contacts': contacts,
    };
  }
}

// Fonction pour vérifier la connectivité
Future<bool> isConnected() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}

// Ajouter dans la classe DatabaseHelperExtension
Future<List<drive.File>> listGoogleDriveBackups() async {
  final authClient = await _getAuthClient();
  if (authClient == null) throw Exception('Authentification échouée');

  final driveApi = drive.DriveApi(authClient);

  final response = await driveApi.files.list(
    q: "name contains 'jaguar.db' and trashed = false",
    spaces: 'drive',
    orderBy: 'createdTime desc',
    $fields: 'files(id, name, createdTime, modifiedTime, size)',
  );

  return response.files ?? [];
}

Future<void> restoreFromGoogleDrive({
  Function(double progress)? onProgress,
  bool mergeData = false,
  required BuildContext context,
  String? fileId,
}) async {
  File? tempFile;
  try {
    // Vérification de la connexion internet
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Aucune connexion internet',
            style: TextStyle(color: whiteColor),
          ),
          backgroundColor: redColor,
        ),
      );
      return;
    }

    // Authentification
    final authClient = await _getAuthClient();
    if (authClient == null) throw Exception('Authentification échouée');

    final driveApi = drive.DriveApi(authClient);
    drive.File? file;

    if (fileId != null) {
      // Récupération du fichier spécifique
      final fileResponse = await driveApi.files.get(
        fileId,
        $fields: 'id, name, size, createdTime',
      );
      file = fileResponse as drive.File?;
    } else {
      // Recherche de la dernière sauvegarde
      final response = await driveApi.files.list(
        q: "name contains 'jaguar_backup' and trashed = false",
        spaces: 'drive',
        orderBy: 'createdTime desc',
        pageSize: 1,
        $fields: 'files(id, name, size, createdTime)',
      );

      if (response.files?.isEmpty ?? true) {
        throw Exception('Aucune sauvegarde trouvée');
      }
      file = response.files!.first;
    }

    // Téléchargement du fichier
    final media = await driveApi.files.get(
      fileId!,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final directory = await getApplicationDocumentsDirectory();
    tempFile = File(
      '${directory.path}/jaguar_restore_${DateTime.now().millisecondsSinceEpoch}.db',
    );

    await _downloadFile(
      media: media,
      outputFile: tempFile,
      onProgress: onProgress,
      fileSize: int.tryParse(file?.size ?? '0'),
      context: context,
    );

    // Remplacement de la base de données
    final dbPath = await getDatabasesPath();
    final originalDb = File(join(dbPath, 'jaguar.db'));

    // Fermeture des connexions existantes
    //await DatabaseHelper.closeDatabase();

    // Copie du fichier restauré
    await tempFile.copy(originalDb.path);

    // Fusion des données si nécessaire
    if (mergeData) {
      await _mergeDatabases(originalDb, tempFile);
    }

    // Réouverture de la base de données
    await DatabaseHelper.database;

    if (kDebugMode) {
      print('Restauration réussie : ${file?.name}');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Base de données restaurée : ${file?.name}'),
        backgroundColor: greenColor,
      ),
    );

  } on SocketException catch (_) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connexion internet perdue pendant la restauration'),
        backgroundColor: redColor,
      ),
    );
  } on drive.DetailedApiRequestError catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur Google Drive : ${e.message}'),
        backgroundColor: redColor,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur de restauration : ${e.toString()}'),
        backgroundColor: redColor,
      ),
    );
    rethrow;
  } finally {
    await tempFile?.delete();
  }
}

Future<void> _downloadFile({
  required drive.Media media,
  required File outputFile,
  required Function(double)? onProgress,
  required int? fileSize,
  required BuildContext context,
}) async {
  final completer = Completer<void>();
  final fileStream = outputFile.openWrite();

  int downloadedBytes = 0;
  final totalBytes = fileSize ?? 0;

  media.stream.listen(
    (data) {
      // Vérification périodique de la connexion
      if (downloadedBytes % 10000 == 0) {
        Connectivity().checkConnectivity().then((result) {
          if (result == ConnectivityResult.none) {
            throw const SocketException('Connexion internet perdue');
          }
        });
      }
      downloadedBytes += data.length;
      fileStream.add(data);
      if (totalBytes > 0) {
        onProgress?.call(downloadedBytes / totalBytes);
      }
    },
    onDone: () async {
      await fileStream.close();
      completer.complete();
    },
    onError: (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connexion interrompue pendant le transfert'),
          backgroundColor: redColor,
        ),
      );
      fileStream.close();
      completer.completeError(e);
    },
  );

  await completer.future;
}

Future<void> _mergeDatabases(File mainDb, File backupDb) async {
  // Ouvrir les deux bases de données
  final main = await openDatabase(mainDb.path);
  final backup = await openDatabase(backupDb.path);

  try {
    await main.transaction((txn) async {
      // Fusion des contacts
      final contacts = await backup.query('contacts');
      for (var contact in contacts) {
        final existing = await txn.query(
          'contacts',
          where: 'phone = ?',
          whereArgs: [contact['phone']],
        );

        if (existing.isEmpty) {
          await txn.insert('contacts', contact);
        }
      }

      // Fusion similaire pour les autres tables
      await _mergeTable(txn, backup, 'users', 'uid');
      await _mergeTable(txn, backup, 'entretiens', 'id');
      await _mergeTable(txn, backup, 'paiements', 'id');
      await _mergeTable(txn, backup, 'courriers', 'id');
    });
  } finally {
    await main.close();
    await backup.close();
  }
}

Future<void> _mergeTable(
    Transaction txn, Database sourceDb, String table, String uniqueKey) async {
  final data = await sourceDb.query(table);

  for (var entry in data) {
    final exists = await txn.query(
      table,
      where: '$uniqueKey = ?',
      whereArgs: [entry[uniqueKey]],
    );

    if (exists.isEmpty) {
      await txn.insert(table, entry);
    }
  }
}


/*
// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/models/courrier_model.dart';
import 'package:jaguar_x_print/models/entretien_model.dart';
import 'package:jaguar_x_print/models/paiement_model.dart';
import 'package:jaguar_x_print/models/user_model.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:jaguar_x_print/api/database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';


class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn.standard(
    scopes: [
      drive.DriveApi.driveFileScope,
      'https://www.googleapis.com/auth/drive.metadata.readonly',
    ],
  );

  static GoogleSignInAccount? _currentUser;
  static DateTime? _tokenExpiration;

  static Future<Map<String, String>?> getAuthHeaders({bool forceRefresh = false}) async {
    try {
      // Vérifier si le token est expiré ou va bientôt expirer
      final isTokenExpired = _tokenExpiration == null ||
          _tokenExpiration!.isBefore(DateTime.now().add(const Duration(minutes: 1)));

      if (_currentUser == null || isTokenExpired || forceRefresh) {
        // Tentative de connexion silencieuse pour rafraîchir le token
        _currentUser = await _googleSignIn.signInSilently();

        if (_currentUser == null) {
          // Si aucune session silencieuse, connexion explicite
          _currentUser = await _googleSignIn.signIn();
        }
      }

      if (_currentUser != null) {
        final auth = await _currentUser!.authentication;

        // Mettre à jour la date d'expiration du token (1 heure par défaut)
        _tokenExpiration = DateTime.now().add(const Duration(hours: 1));

        return {
          'Authorization': 'Bearer ${auth.accessToken}',
          'Content-Type': 'application/json',
        };
      }
      return null;
    } catch (e) {
      debugPrint('Erreur de récupération des headers: $e');
      return null;
    }
  }

  static Future<GoogleSignInAccount?> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      if (_currentUser != null) {
        // Rafraîchir le token après la connexion
        await getAuthHeaders(forceRefresh: true);
      }
      return _currentUser;
    } catch (e) {
      debugPrint('Erreur de connexion: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _tokenExpiration = null;
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}

Future<void> saveToGoogleDrive({
  Function(double progress)? onProgress,
  required BuildContext context,
}) async {
  try {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune connexion internet'),
          backgroundColor: redColor,
        ),
      );
      return;
    }

    final headers = await GoogleAuthService.getAuthHeaders();
    if (headers == null) throw Exception('Authentification échouée');

    final authClient = GoogleAuthClient(headers);
    final dbPath = await getDatabasesPath();
    final dbFile = File(join(dbPath, 'jaguar.db'));

    if (!await dbFile.exists()) {
      throw Exception('Base de données introuvable');
    }

    final driveApi = drive.DriveApi(authClient);
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final driveFile = drive.File()
      ..name = 'jaguar_$timestamp.db'
      ..description = 'Sauvegarde du ${DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.now())}'
      ..parents = ['root'];

    final fileStream = dbFile.openRead();
    final fileLength = await dbFile.length();

    int uploadedBytes = 0;
    final response = await driveApi.files.create(
      driveFile,
      uploadMedia: drive.Media(
        fileStream.transform(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              uploadedBytes += data.length;
              onProgress?.call(uploadedBytes / fileLength);
              sink.add(data);
            },
          ),
        ),
        fileLength,
      ),
    );

    if (kDebugMode) {
      print("Sauvegarde réussie. ID: ${response.id}");
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sauvegarde réussie !'),
        backgroundColor: greenColor,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur de sauvegarde: ${e.toString()}'),
        backgroundColor: redColor,
      ),
    );
    rethrow;
  }
}

Future<List<drive.File>> listGoogleDriveBackups() async {
  try {
    final headers = await GoogleAuthService.getAuthHeaders();
    if (headers == null) throw Exception('Authentification échouée');

    final authClient = GoogleAuthClient(headers);
    final driveApi = drive.DriveApi(authClient);

    final response = await driveApi.files.list(
      q: "name contains 'jaguar_' and name contains '.db' and trashed=false",
      orderBy: 'createdTime desc',
      $fields: "files(id, name, createdTime)",
    );
    return response.files ?? [];
  } on drive.DetailedApiRequestError catch (e) {
    if (e.status == 401) {
      debugPrint('Token expiré, tentative de reconnexion...');

      // Nouvelle tentative avec rafraîchissement forcé
      final refreshedHeaders = await GoogleAuthService.getAuthHeaders(forceRefresh: true);

      if (refreshedHeaders == null) {
        throw Exception('Reconnexion échouée: utilisateur non authentifié');
      }

      final driveApi = drive.DriveApi(GoogleAuthClient(refreshedHeaders));
      final response = await driveApi.files.list(
        q: "name contains 'jaguar_' and name contains '.db' and trashed=false",
        orderBy: 'createdTime desc',
        $fields: "files(id, name, createdTime)",
      );
      return response.files ?? [];
    } else {
      debugPrint('Erreur Google Drive: ${e.message}');
      rethrow;
    }
  } catch (e) {
    debugPrint('Erreur inattendue: $e');
    rethrow;
  }
}

Future<void> restoreFromGoogleDrive({
  required String fileId,
  Function(double progress)? onProgress,
  required BuildContext context,
}) async {
  File? tempFile;
  try {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune connexion internet'),
          backgroundColor: redColor,
        ),
      );
      return;
    }

    final headers = await GoogleAuthService.getAuthHeaders();
    if (headers == null) throw Exception('Authentification échouée');

    final authClient = GoogleAuthClient(headers);
    final driveApi = drive.DriveApi(authClient);

    // Récupération des infos du fichier
    final file = await driveApi.files.get(
      fileId,
      $fields: 'id, name, size',
    ) as drive.File;

    // Téléchargement du fichier
    final media = await driveApi.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final directory = await getApplicationDocumentsDirectory();
    tempFile = File(
      '${directory.path}/jaguar_restore_${DateTime.now().millisecondsSinceEpoch}.db',
    );

    await _downloadFile(
      media: media,
      outputFile: tempFile,
      onProgress: onProgress,
      fileSize: int.tryParse(file.size ?? '0') ?? 0,
    );

    final dbPath = await getDatabasesPath();
    final originalDb = File(join(dbPath, 'jaguar.db'));

    final db = await DatabaseHelper.database;
    await db.close();

    await tempFile.copy(originalDb.path);
    await DatabaseHelper.database;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Base restaurée: ${file.name}'),
        backgroundColor: greenColor,
      ),
    );
  } on SocketException {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connexion internet perdue'),
        backgroundColor: redColor,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur de restauration: ${e.toString()}'),
        backgroundColor: redColor,
      ),
    );
  } finally {
    await tempFile?.delete();
  }
}

Future<void> _downloadFile({
  required drive.Media media,
  required File outputFile,
  required Function(double)? onProgress,
  required int fileSize,
}) async {
  final completer = Completer<void>();
  final fileStream = outputFile.openWrite();

  int downloadedBytes = 0;

  media.stream.listen(
        (data) {
      downloadedBytes += data.length;
      fileStream.add(data);
      if (fileSize > 0) {
        onProgress?.call(downloadedBytes / fileSize);
      }
    },
    onDone: () async {
      await fileStream.close();
      completer.complete();
    },
    onError: (e) {
      fileStream.close();
      completer.completeError(e);
    },
  );

  await completer.future;
}

// Extension pour DatabaseHelper
extension DatabaseHelperExtension on DatabaseHelper {
  Future<List<UserModel>> getUsers() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => UserModel.fromMap(maps[i]));
  }

  Future<List<Entretien>> getEntretiens() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('entretiens');
    return List.generate(maps.length, (i) => Entretien.fromMap(maps[i]));
  }

  Future<List<Paiement>> getPaiements() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('paiements');
    return List.generate(maps.length, (i) => Paiement.fromMap(maps[i]));
  }

  Future<List<Courrier>> getCourriers() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('courriers');
    return List.generate(maps.length, (i) => Courrier.fromMap(maps[i]));
  }
}
*/