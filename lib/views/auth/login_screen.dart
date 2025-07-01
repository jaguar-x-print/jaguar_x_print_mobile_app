import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jaguar_x_print/api/database.dart';
import 'package:jaguar_x_print/api/google/google_signin.dart';
import 'package:jaguar_x_print/bloc/auth/auth_cubit.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/constant/network_utils.dart';
import 'package:jaguar_x_print/models/user_model.dart';
import 'package:jaguar_x_print/views/page_principale.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Connexion réussie !'),
                  backgroundColor: green2Color,
                ),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const PagePrincipale(),
                ),
              );
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: redColor,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return _buildLoginForm(context);
          },
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo/jaguar.png',
              width: 42.w,
              height: 42.w,
            ),
            Text(
              'Jaguar x-Print',
              style: TextStyle(
                fontSize: 30.dp,
                color: firstColor,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Connexion',
              style: TextStyle(
                fontSize: 20.dp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: blackColor,
                foregroundColor: whiteColor,
              ),
              icon: const FaIcon(
                FontAwesomeIcons.google,
                color: redColor,
              ),
              onPressed: () async {
                try {
                  // Vérification active de la connexion
                  final hasConnection =
                      await NetworkUtils.hasInternetConnection(
                    context,
                  );
                  if (!hasConnection) return;

                  // Tentative de connexion Google avec timeout
                  final googleUser = await GoogleSignInApi.login().timeout(
                    const Duration(seconds: 30),
                  );

                  if (googleUser != null && mounted) {
                    final dbHelper = DatabaseHelper();
                    final existingUser =
                        await dbHelper.getUserByEmail(googleUser.email);

                    // Création/mise à jour du modèle utilisateur
                    final user = UserModel(
                      uid: existingUser?.uid ?? googleUser.id,
                      username: googleUser.displayName ?? 'Utilisateur Google',
                      email: googleUser.email,
                      profilePhotoUrl: googleUser.photoUrl ?? '',
                    );

                    try {
                      if (existingUser == null) {
                        await dbHelper.insertUser(user);
                        print('Nouvel utilisateur enregistré');
                      } else {
                        await dbHelper.updateUser(user);
                        print('Utilisateur mis à jour');
                      }
                    } catch (e) {
                      print('Erreur DB : $e');
                    }

                    // Navigation
                    context.read<AuthCubit>().authenticate(user);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PagePrincipale(),
                      ),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Annulation de la connexion Google",
                        ),
                        backgroundColor: firstColor,
                      ),
                    );
                  }
                } on TimeoutException {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Délai dépassé - Vérifiez votre connexion',
                        ),
                        backgroundColor: redColor,
                      ),
                    );
                  }
                } on SocketException catch (_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Accès internet perdu pendant la connexion',
                        ),
                        backgroundColor: redColor,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Aucun accès internet !',
                        ),
                        backgroundColor: redColor,
                      ),
                    );
                  }
                }
              },
              label: Text(
                "Se connecter avec Google",
                style: TextStyle(fontSize: 17.dp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
