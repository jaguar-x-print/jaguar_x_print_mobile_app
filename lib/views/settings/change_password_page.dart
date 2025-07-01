// lib/views/settings/change_password_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/widgets/fields/password_field.dart';
import 'package:jaguar_x_print/bloc/auth/auth_cubit.dart';


class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  /// Handles the actual password change logic.
  /// This is called after the user confirms in the dialog.
  Future<void> _performPasswordChange() async {
    EasyLoading.show(status: 'Changement de mot de passe...');

    String currentPassword = _currentPasswordController.text;
    String newPassword = _newPasswordController.text;

    try {
      // Récupérer l'utilisateur actuel
      final authState = context.read<AuthCubit>().state;
      if (authState is! AuthSuccess) {
        throw Exception("Utilisateur non connecté");
      }

      // DEBUG: Afficher l'état actuel du mot de passe
      debugPrint("🔐 Mot de passe actuel dans la BD: ${authState.user.passwordPaiement}");

      await context.read<AuthCubit>().updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      // Reset form fields after successful update
      _formKey.currentState?.reset();
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmNewPasswordController.clear();

      // Show success message
      EasyLoading.showSuccess('Mot de passe mis à jour avec succès !');

      // Pop the page after successful password change
      if (mounted) { // Check if the widget is still in the tree before popping
        Navigator.of(context).pop();
      }
    } on AuthFailure catch (e) {
      EasyLoading.showError('Erreur: ${e.message}'); // Access the message property of AuthFailure
    } catch (e) {
      EasyLoading.showError(
        'Une erreur inattendue est survenue: ${e.toString()}',
      );
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// Shows the confirmation dialog before initiating the password change.
  Future<void> _showConfirmationDialog() async {
    if (_formKey.currentState!.validate()) { // Validate form before showing dialog
      final bool? confirm = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Confirmer le changement de mot de passe'),
            content: const Text('Êtes-vous sûr de vouloir changer votre mot de passe de paiement ?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Non'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenColor, // Using your custom color
                  foregroundColor: whiteColor,
                ),
                child: const Text('Oui'),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        // If user confirms, proceed with password change
        await _performPasswordChange();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Changer mot de passe Paiement",
          style: TextStyle(
            color: whiteColor,
            fontSize: Adaptive.sp(18),
          ),
        ),
        centerTitle: true,
        backgroundColor: color3, // Moved backgroundColor from Text to AppBar
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: whiteColor,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Adaptive.w(4)),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Changer votre mot de passe",
                style: TextStyle(
                  fontSize: Adaptive.sp(19),
                  fontWeight: FontWeight.bold,
                  color: blackColor,
                ),
              ),
              SizedBox(height: Adaptive.h(2)),
              Text(
                "Pour des raisons de sécurité, veuillez entrer votre mot de passe actuel avant de définir un nouveau mot de passe.",
                style: TextStyle(
                  fontSize: Adaptive.sp(14),
                  color: blackColor,
                ),
              ),
              SizedBox(height: Adaptive.h(3)),
              Text(
                "Mot de passe actuel",
                style: TextStyle(fontSize: Adaptive.sp(15)),
              ), // Corrected missing closing parenthesis
              SizedBox(height: Adaptive.h(0.5)),
              PasswordField(
                controller: _currentPasswordController,
                onTap: () {},
                focus: true,
                hint: "Entrez votre mot de passe actuel",
                backColor: color3,
                suffixIconColor: whiteColor,
                prefixIconColor: whiteColor,
                textColor: whiteColor,
                textFieldColor: whiteColor,
                hintColor: whiteColor.withOpacity(0.7),
                prefixIcon: Icons.lock_person_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre mot de passe actuel';
                  }
                  return null;
                },
              ),
              SizedBox(height: Adaptive.h(3)),
              Text(
                "Nouveau mot de passe",
                style: TextStyle(fontSize: Adaptive.sp(15)),
              ),
              SizedBox(height: Adaptive.h(0.5)),
              PasswordField(
                controller: _newPasswordController,
                hint: 'Entrez votre nouveau mot de passe',
                backColor: color3,
                suffixIconColor: whiteColor,
                prefixIconColor: whiteColor,
                textColor: whiteColor,
                textFieldColor: whiteColor,
                hintColor: whiteColor.withOpacity(0.7),
                onTap: () {},
                focus: true,
                prefixIcon: Icons.password_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nouveau mot de passe';
                  }
                  if (value.length < 5) {
                    return 'Le mot de passe doit contenir au moins 5 caractères';
                  }
                  return null;
                },
              ),
              SizedBox(height: Adaptive.h(3)),
              Text(
                "Confirmer le nouveau mot de passe",
                style: TextStyle(fontSize: Adaptive.sp(15)),
              ),
              SizedBox(height: Adaptive.h(0.5)),
              PasswordField(
                controller: _confirmNewPasswordController,
                hint: 'Confirmez votre nouveau mot de passe',
                backColor: color3,
                suffixIconColor: whiteColor,
                prefixIconColor: whiteColor,
                textColor: whiteColor,
                textFieldColor: whiteColor,
                hintColor: whiteColor.withOpacity(0.7),
                onTap: () {},
                focus: true,
                prefixIcon: Icons.password_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez confirmer votre mot de passe";
                  }
                  if (value != _newPasswordController.text) {
                    return "Les mots de passe ne correspondent pas";
                  }
                  return null;
                },
              ),
              SizedBox(height: Adaptive.h(4)),
              Center(
                child: ElevatedButton(
                  onPressed: _showConfirmationDialog, // Calls the confirmation dialog
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color1,
                    foregroundColor: whiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: Adaptive.w(8),
                      vertical: Adaptive.h(2),
                    ),
                  ),
                  child: Text(
                    "Changer le mot de passe",
                    style: TextStyle(
                      fontSize: Adaptive.sp(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}