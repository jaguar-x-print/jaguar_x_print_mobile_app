import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:jaguar_x_print/api/database.dart';
import 'package:jaguar_x_print/models/courrier_model.dart';

class CourrierSyncService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final String _apiUrl = 'http://192.168.134.118:3000/api/sync/courriers';

  Future<void> syncCourriers() async {
    final unsyncedCourriers = await _dbHelper.getUnsyncedCourriers();

    for (final courrier in unsyncedCourriers) {
      try {
        final file = File(courrier.documentPath!);
        final response = await _uploadFile(file, courrier);

        await _dbHelper.updateCourrier(
          courrier.copyWith(serverDocumentUrl: response['url']),
        );
      } catch (e) {
        print('Échec synchronisation courrier ${courrier.id}: $e');
      }
    }
  }

  Future<Map<String, dynamic>> _uploadFile(File file, Courrier courrier) async {
    try {
      if (!await file.exists()) {
        throw Exception('Fichier introuvable: ${file.path}');
      }

      final request = http.MultipartRequest('POST', Uri.parse(_apiUrl))
        ..fields['id'] = courrier.id?.toString() ?? ''
        ..fields['contactId'] = courrier.contactId.toString()
        ..fields['date'] = courrier.date!.toIso8601String()
        ..fields['documentPath'] = courrier.documentPath!
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: _getMediaType(file.path),
        ));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData);

      if (response.statusCode != 200) {
        final errorMsg = jsonResponse['error'] ??
            jsonResponse['errors']?.first['msg'] ??
            'Erreur inconnue';
        throw Exception('Code ${response.statusCode}: $errorMsg');
      }

      return jsonResponse;
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } on FormatException {
      throw Exception('Réponse serveur invalide');
    } catch (e) {
      throw Exception('Erreur technique: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  MediaType _getMediaType(String path) {
    final extension = path.split('.').last.toLowerCase();

    return switch (extension) {
      'pdf' => MediaType('application', 'pdf'),
      'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
      'png' => MediaType('image', 'png'),
      _ => MediaType('application', 'octet-stream'),
    };
  }
}

class ContactSyncService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final String _apiUrl = 'http://192.168.134.118:3000/api/sync/contacts';

  Future<void> syncContacts({Function(double progress)? onProgress}) async {
    final unsyncedContacts = await _dbHelper.getAllContactsForSync();
    final total = unsyncedContacts.length;
    int processed = 0;

    final client = http.Client();
    try {
      final response = await client.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(unsyncedContacts.map((c) => c.toMap()).toList()),
      );

      if (response.statusCode == 200) {
        for (var contact in unsyncedContacts) {
          await _dbHelper.markContactAsSynced(contact.id!);
          processed++;
          onProgress?.call(processed / total);
        }
      }
    } finally {
      client.close();
    }
  }
}