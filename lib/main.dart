// Readme Creator
// Development by: Mohamed Anwar (mhmdwaelanwr)

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// UNCOMMENT THIS AFTER RUNNING FLUTTERFIRE CONFIGURE:
// import 'firebase_options.dart'; 

import 'l10n/app_localizations.dart';
import 'providers/project_provider.dart';
import 'providers/library_provider.dart';
import 'screens/home_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    bool firebaseInitialized = false;
    try {
      // PRO TIP: When firebase_options.dart is ready, change this to:
      // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      await Firebase.initializeApp();
      firebaseInitialized = true;
      debugPrint('Firebase Core: Connected');
    } catch (e) {
      debugPrint('Firebase Core: Running in Offline Mode ($e)');
    }

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
    debugPrint('Critical System Error: $error');
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
