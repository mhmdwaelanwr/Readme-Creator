// Readme Creator
// Development by: Mohamed Anwar (mhmdwaelanwr)

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// IMPORTANT: If you have successfully run 'flutterfire configure', 
// uncomment the line below and the options in Firebase.initializeApp.
// import 'firebase_options.dart'; 

import 'l10n/app_localizations.dart';
import 'providers/project_provider.dart';
import 'providers/library_provider.dart';
import 'screens/home_screen.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseInitialized = false;
  try {
    // Attempt initialization. If options are not provided, it may run in limited mode
    // or fail. We wrap it to prevent app crash.
    await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform, 
    );
    firebaseInitialized = true;
  } catch (e) {
    debugPrint('Firebase Note: App running in Local Mode. $e');
  }

  runZonedGuarded(() {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ProjectProvider()),
          ChangeNotifierProvider(create: (_) => LibraryProvider(isFirebaseAvailable: firebaseInitialized)),
        ],
        child: const MyApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('Global Error: $error');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          title: 'Readme Creator',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: provider.locale,
          themeMode: provider.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          initialRoute: '/',
          routes: {
            '/': (context) => const HomeScreen(),
          },
        );
      },
    );
  }
}
