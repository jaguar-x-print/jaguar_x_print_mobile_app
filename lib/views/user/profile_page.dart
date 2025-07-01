// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:intl/intl.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/api/database.dart';
import 'package:jaguar_x_print/api/google/google_signin.dart';
import 'package:jaguar_x_print/api/sync/sync_file.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/constant/network_utils.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  double _uploadProgress = 0.0;
  double _restoreProgress = 0.0;
  double _syncProgress = 0.0;
  bool _isSyncing = false;
  bool _isUploading = false;
  bool _isRestoring = false;
  Timer? _restartTimer;

  @override
  void dispose() {
    _restartTimer?.cancel();
    super.dispose();
  }

  void _showRestartDialog() {
    int _remainingSeconds = 10;
    Timer? _timer;
    bool _isDialogOpen = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          _timer?.cancel();
          _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (_remainingSeconds > 0) {
              setState(() => _remainingSeconds--);
            } else {
              timer.cancel();
              if (_isDialogOpen) {
                Navigator.of(context).pop();
                _restartApp();
              }
            }
          });

          return AlertDialog(
            title: const Text('Redémarrage requis'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('L\'application doit redémarrer pour appliquer les changements.'),
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: _remainingSeconds / 10,
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(height: 10),
                Text(
                  'Redémarrage automatique dans $_remainingSeconds secondes',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  _isDialogOpen = false;
                  _timer?.cancel();
                  Navigator.of(context).pop();
                  _restartApp();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // Nouvelle méthode de redémarrage
  void _restartApp() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Phoenix.rebirth(context);
    });
  }

  // Ajoutez cette méthode dans la classe _ProfilePageState
  Future<void> _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler', style: TextStyle(color: greyColor)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(confirmText, style: TextStyle(color: confirmColor)),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion Cloud'),
        centerTitle: true,
        backgroundColor: greenColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            _buildActionCard(
              icon: Icons.cloud_upload,
              title: "Sauvegarde Cloud",
              subtitle: "Stockez vos données sur Google Drive",
              color: blueColor,
              child: _buildBackupSection(),
            ),
            SizedBox(height: 4.h),
            _buildActionCard(
              icon: Icons.cloud_download,
              title: "Restauration Cloud",
              subtitle: "Récupérez vos données depuis Google Drive",
              color: greenColor,
              child: _buildRestoreSection(),
            ),
            SizedBox(height: 4.h),

            _buildActionCard(
              icon: Icons.sync,
              title: "Synchronisation Serveur",
              subtitle: "Envoyez les données locales vers MySQL",
              color: color1,
              child: _buildSyncSection(),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Widget child,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 8.w),
                SizedBox(width: 4.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: greyColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 4.h),
            child,
          ],
        ),
      ),
    );
  }

  // Section de sauvegarde
  Widget _buildBackupSection() {
    return Column(
      children: [
        if (_isUploading) ...[
          LinearProgressIndicator(
            value: _uploadProgress,
            backgroundColor: greyColor.withOpacity(0.3),
            color: blueColor,
            minHeight: 1.h,
            borderRadius: BorderRadius.circular(10),
          ),
          SizedBox(height: 1.h),
          Text(
            'Progression : ${(_uploadProgress * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
              color: blueColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2.h),
        ],
        ElevatedButton.icon(
          icon: const Icon(Icons.save_alt, size: 24),
          label: const Text('SAUVEGARDER MAINTENANT'),
          style: ElevatedButton.styleFrom(
            backgroundColor: blueColor,
            foregroundColor: whiteColor,
            padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _isUploading
              ? null
              : () => _showConfirmationDialog(
            title: 'Confirmer la sauvegarde',
            message: 'Voulez-vous vraiment sauvegarder vos données sur le Cloud ?',
            confirmText: 'SAUVEGARDER',
            confirmColor: blueColor,
            onConfirm: _performBackup,
          ),
        ),
      ],
    );
  }

  // Section de restauration
  Widget _buildRestoreSection() {
    return Column(
      children: [
        if (_isRestoring) ...[
          LinearProgressIndicator(
            value: _restoreProgress,
            backgroundColor: greyColor.withOpacity(0.3),
            color: greenColor,
            minHeight: 1.h,
            borderRadius: BorderRadius.circular(10),
          ),
          SizedBox(height: 1.h),
          Text(
            'Progression : ${(_restoreProgress * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
              color: greenColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2.h),
        ],
        ElevatedButton.icon(
          icon: Icon(
            Icons.restore,
            size: Adaptive.sp(24),
            color: blackColor,
          ),
          label: const Text('RESTAURER MAINTENANT'),
          style: ElevatedButton.styleFrom(
            backgroundColor: greenColor,
            foregroundColor: blackColor,
            padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _isRestoring
              ? null
              : () async {
            // Appel DIRECT de votre fonction existante
            await showBackupSelection(context);
          },
        ),
      ],
    );
  }

  // Section de synchronisation
  Widget _buildSyncSection() {
    return Column(
      children: [
        if (_isSyncing) ...[
          LinearProgressIndicator(
            value: _syncProgress,
            backgroundColor: greyColor.withOpacity(0.3),
            color: color1,
            minHeight: 1.h,
            borderRadius: BorderRadius.circular(10),
          ),
          SizedBox(height: 1.h),
          Text(
            'Progression : ${(_syncProgress * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
              color: color1,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2.h),
        ],
        ElevatedButton.icon(
          icon: const Icon(Icons.sync, size: 24),
          label: Text('SYNCHRONISER MAINTENANT'),
          style: ElevatedButton.styleFrom(
            backgroundColor: color1,
            foregroundColor: whiteColor,
            padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _isSyncing
              ? null
              : () async {
            await _showConfirmationDialog(
              title: 'Confirmer la synchronisation',
              message: 'Voulez-vous synchroniser les données avec le serveur ?',
              confirmText: 'SYNCHRONISER',
              confirmColor: color1,
              onConfirm: () async {
                try {
                  // Début du processus global
                  EasyLoading.show(status: 'Préparation de la synchronisation...');

                  // Synchronisation utilisateurs
                  EasyLoading.show(status: 'Synchronisation des utilisateurs...');
                  await Future.delayed(const Duration(seconds: 2));
                  await _performSync();

                  // Synchronisation contacts
                  EasyLoading.show(status: 'Synchronisation des contacts...');
                  await Future.delayed(const Duration(seconds: 2));
                  await ContactSyncService().syncContacts();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Synchronisation contacts réussie !)'),
                      backgroundColor: greenColor,
                    ),
                  );

                  // Synchronisation courriers
                  EasyLoading.show(status: 'Synchronisation des courriers...');
                  await Future.delayed(const Duration(seconds: 2));
                  await CourrierSyncService().syncCourriers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Synchronisation courriers réussie !)'),
                      backgroundColor: greenColor,
                    ),
                  );

                  // Fin du processus
                  EasyLoading.showSuccess('Synchronisation terminée !');
                  await Future.delayed(const Duration(seconds: 1));
                } catch (e) {
                  EasyLoading.showError('Erreur: ${e.toString()}');
                } finally {
                  EasyLoading.dismiss();
                }
              },
            );
          },
        ),
      ],
    );
  }

  // Ajoutez cette méthode de synchronisation

  Future<void> _performSync() async {
    try {
      final users = await DatabaseHelper().getAllUsersForSync();

      // Conversion sécurisée avec vérification
      final usersData = users.map((user) {
        if (user.uid == null || user.email == null) {
          throw FormatException('Utilisateur invalide: ${user.toString()}');
        }
        return user.toMap()..removeWhere((k, v) => v == null);
      }).toList();

      // Vérification finale
      if (usersData.isEmpty) {
        throw Exception('Aucun utilisateur à synchroniser');
      }

      final response = await http.post(
        Uri.parse('http://192.168.134.118:3000/api/sync/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(usersData),
      ).timeout(const Duration(seconds: 30));

      final body = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception('Erreur ${response.statusCode}: ${body['error']}');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Synchronisation réussie (${body['valid']}/${body['received']} utilisateurs)',
          ),
          backgroundColor: greenColor,
        ),
      );

    } on FormatException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Données corrompues: ${e.message}'),
          backgroundColor: yellowColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: redColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _performBackup() async {
    if (!await NetworkUtils.hasInternetConnection(context)) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      await saveToGoogleDrive(
        context: context,
        onProgress: (progress) => setState(() => _uploadProgress = progress),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sauvegarde réussie !'),
          backgroundColor: greenColor,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : ${e.toString()}'),
          backgroundColor: redColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> showBackupSelection(BuildContext context) async {
    // Sauvegarder le contexte du ProfilePage
    final profileContext = context;
    final backups = await listGoogleDriveBackups();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir une sauvegarde'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: backups.length,
            itemBuilder: (context, index) {
              final backup = backups[index];
              return ListTile(
                title: Text(backup.name ?? 'Sauvegarde sans nom'),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(backup.createdTime!),
                ),
                onTap: () async {
                  // Fermer la boîte de dialogue avec le contexte local
                  Navigator.pop(context);

                  try {
                    if (!await NetworkUtils.hasInternetConnection(profileContext)) return;

                    // Vérifier si le widget est toujours monté avant setState
                    if (!mounted) return;
                    setState(() {
                      _isRestoring = true;
                      _restoreProgress = 0.0;
                    });

                    await restoreFromGoogleDrive(
                      context: profileContext,
                      fileId: backup.id!,
                      onProgress: (progress) {
                        if (mounted) {
                          setState(() => _restoreProgress = progress);
                        }
                      },
                    );

                    // Vérifier monté avant d'afficher le SnackBar
                    if (mounted) {
                      ScaffoldMessenger.of(profileContext).showSnackBar(
                        const SnackBar(
                          content: Text('Restauration réussie !'),
                          backgroundColor: greenColor,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      if (mounted) {
                        //_showRestartDialog();
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(profileContext).showSnackBar(
                        SnackBar(
                          content: Text('Erreur : ${e.toString()}'),
                          backgroundColor: redColor,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _isRestoring = false);
                    }
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }


}
