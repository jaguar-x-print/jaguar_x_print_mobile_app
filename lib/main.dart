import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/api/database.dart';
import 'package:jaguar_x_print/bloc/auth/auth_cubit.dart';
import 'package:jaguar_x_print/bloc/contact_cubit.dart';
import 'package:jaguar_x_print/bloc/courrier/courrier_bloc.dart';
import 'package:jaguar_x_print/bloc/courrier/courrier_event.dart';
import 'package:jaguar_x_print/bloc/entretien/entretien_bloc.dart';
import 'package:jaguar_x_print/bloc/entretien/entretien_event.dart';
import 'package:jaguar_x_print/bloc/paiement/paiement_bloc.dart';
import 'package:jaguar_x_print/bloc/paiement/paiement_event.dart';
import 'package:jaguar_x_print/bloc/selected_contacts_cubit.dart';
import 'package:jaguar_x_print/l10n/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:jaguar_x_print/services/notification_service.dart';
import 'package:jaguar_x_print/views/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones(); // ceci est synchrone

  final prefs = await SharedPreferences.getInstance();
  await NotificationService().initNotification(); // ← très important

  runApp(
    MyApp(prefs: prefs),
  );

  // Attraper toutes les erreurs non gérées
  FlutterError.onError = (details) {
    debugPrint('‼️ ERREUR GLOBALE: ${details.exception}');
    debugPrintStack(stackTrace: details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('‼️ ERREUR PLATEFORME: $error');
    return true;
  };


}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit()..checkAuthStatus(),
        ),
        BlocProvider(
          create: (context) => ContactCubit(),
        ),
        BlocProvider(
          create: (_) => SelectedContactsCubit(),
        ),
        BlocProvider(
          create: (context) => EntretienBloc(DatabaseHelper()),
        ),
        BlocProvider(
          create: (context) => PaiementBloc(dbHelper: DatabaseHelper()),
        ),
        BlocProvider<CourrierBloc>(
          create: (context) => CourrierBloc(DatabaseHelper()),
        ),
      ],
      child: LifecycleManager(
        child: FlutterSizer(
          builder: (context, orientation, screenType) {
            return MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: L10n.all,
              locale: const Locale('fr'),
              theme: ThemeData(
                fontFamily: 'Arial',
                useMaterial3: true,
              ),
              debugShowCheckedModeBanner: false,
              home: const SplashScreen(),
              builder: EasyLoading.init(),
            );
          },
        ),
      ),
    );
  }
}

class LifecycleManager extends StatefulWidget {
  final Widget child;

  const LifecycleManager({super.key, required this.child});

  @override
  State<LifecycleManager> createState() => _LifecycleManagerState();
}

class _LifecycleManagerState extends State<LifecycleManager> with WidgetsBindingObserver {
  // Timer pour surveiller périodiquement la mémoire
  Timer? _memoryMonitorTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startMemoryMonitoring();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _memoryMonitorTimer?.cancel();
    super.dispose();
  }

  void _startMemoryMonitoring() {
    // Surveiller la mémoire toutes les 30 secondes
    _memoryMonitorTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkMemoryUsage();
    });
  }

  Future<void> _checkMemoryUsage() async {
    try {
      final ByteData? byteData = await ServicesBinding.instance.defaultBinaryMessenger
          .send('flutter:getMemoryUsage', null);

      if (byteData != null) {
        // Convertir ByteData → String → Map
        final String jsonStr = utf8.decode(byteData.buffer.asUint8List());
        final Map<String, dynamic> usage = json.decode(jsonStr);

        final int heapSize = usage['heap_size'] ?? 0;
        final int heapUsage = usage['heap_usage'] ?? 0;

        debugPrint('📊 Utilisation mémoire: $heapUsage / $heapSize bytes');

        if (heapUsage > 150 * 1024 * 1024) {
          debugPrint('⚠️ ALERTE MÉMOIRE ÉLEVÉE: ${heapUsage ~/ (1024 * 1024)} MB');
        }
      }
    } catch (e) {
      debugPrint('Erreur de surveillance mémoire: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _releaseResources();
    } else if (state == AppLifecycleState.resumed) {
      _reinitializeResources();
    }
  }

  void _releaseResources() {
    context.read<EntretienBloc>().add(EntretienPauseEvent());
    context.read<PaiementBloc>().add(PaiementPauseEvent());
    context.read<CourrierBloc>().add(CourrierPauseEvent());
  }

  void _reinitializeResources() {
    context.read<EntretienBloc>().add(EntretienResumeEvent());
    context.read<PaiementBloc>().add(PaiementResumeEvent());
    context.read<CourrierBloc>().add(CourrierResumeEvent());
    context.read<AuthCubit>().checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}