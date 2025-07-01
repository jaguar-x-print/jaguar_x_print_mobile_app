import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaguar_x_print/api/google/google_signin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jaguar_x_print/api/database.dart'; // This should be your DatabaseHelper import
import 'package:jaguar_x_print/models/user_model.dart';

part './auth_state.dart';

// REMOVE THIS SECTION:
// class AuthFailure implements Exception {
// final String message;
// AuthFailure(this.message);
// @override
// String toString() => 'AuthFailure: $message';
// }

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial()) {
    _init();
  }

  final DatabaseHelper _dbHelper = DatabaseHelper();
  late SharedPreferences _prefs;

  // This will hold the UID of the currently logged-in user
  String? _currentUserId;

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    await checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final uid = _prefs.getString('uid');
      if (uid != null) {
        final user = await _dbHelper.getUser(uid);
        if (user != null) {
          _currentUserId = user.uid; // Set the current user ID
          emit(AuthSuccess(user));
        } else {
          // Corrected: Emit AuthFailure as an AuthState
          emit(AuthFailure("Utilisateur non trouvé en base"));
        }
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      // Corrected: Emit AuthFailure as an AuthState
      emit(AuthFailure("Erreur de connexion : ${e.toString()}"));
    }
  }

  Future<void> authenticate(UserModel user) async {
    emit(AuthLoading());
    try {
      await _dbHelper.upsertUser(user);
      await _prefs.setString('uid', user.uid ?? "");
      _currentUserId = user.uid;
      emit(AuthSuccess(user));
    } catch (e) {
      // Corrected: Emit AuthFailure as an AuthState
      emit(
        AuthFailure("Échec de l'authentification : ${e.toString()}"),
      );
    }
  }

  // New method to update the passwordPaiement
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUserId == null) {
      throw AuthFailure('Aucun utilisateur connecté.');
    }

    try {
      final user = await _dbHelper.getUser(_currentUserId!);
      if (user == null) {
        throw AuthFailure('Utilisateur introuvable.');
      }

      final isInitialSetup = user.passwordPaiement == null || user.passwordPaiement!.isEmpty;

      if (!isInitialSetup && user.passwordPaiement != currentPassword) {
        throw AuthFailure('Le mot de passe actuel est incorrect.');
      }


      // Mettre à jour le mot de passe
      await _dbHelper.updatePasswordPaiement(_currentUserId!, newPassword);

      // Mettre à jour l'état
      final updatedUser = user.copyWith(passwordPaiement: newPassword);
      emit(AuthSuccess(updatedUser));

      // DEBUG: Afficher le nouveau mot de passe
      debugPrint("🔄 Mot de passe de paiement mis à jour: $newPassword");
    } catch (e) {
      if (e is AuthFailure) {
        rethrow;
      } else {
        throw AuthFailure('Erreur: ${e.toString()}');
      }
    }
  }


  Future<void> logout() async {
    await _prefs.remove('uid');
    GoogleSignInApi.signOut();
    _currentUserId = null; // Clear the current user ID on logout
    emit(AuthInitial());
  }

  @override
  void onChange(Change<AuthState> change) {
    super.onChange(change);
    debugPrint('AuthState changed: $change');
  }
}