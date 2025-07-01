import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:jaguar_x_print/constant/colors.dart';

class NetworkUtils {
  static Future<bool> hasInternetConnection(BuildContext context,
      {bool showMessage = true}) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        if (showMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucune connexion internet'),
              backgroundColor: redColor,
            ),
          );
        }
        return false;
      }
      return true;
    } catch (e) {
      if (showMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur de vérification de connexion'),
            backgroundColor: redColor,
          ),
        );
      }
      return false;
    }
  }
}
