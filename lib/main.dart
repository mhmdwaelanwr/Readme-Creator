// Markdown Creator Pro - The Ultimate Tech Doc Suite
// Developed by: Mohamed Anwar (mhmdwaelanwr)

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'package:markdown_creator/l10n/app_localizations.dart';
import 'package:markdown_creator/providers/project_provider.dart';
import 'package:markdown_creator/providers/library_provider.dart';
import 'package:markdown_creator/screens/home_screen.dart';
import 'package:markdown_creator/core/theme/app_theme.dart';
import 'package:markdown_creator/services/auth_service.dart';
import 'package:markdown_creator/services/subscription_service.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Safety check for ads on Desktop
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
      unawaited(MobileAds.instance.initialize());
    }

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    bool firebaseInitialized = false;
    try {
      await Firebase.initializeApp(); 
      
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      firebaseInitialized = true;
      debugPrint('🛡️ Firebase Engine: ACTIVE');
    } catch (e) {
      debugPrint('⚠️ Firebase Engine: OFFLINE MODE (Subscription services limited)');
    }

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ProjectProvider()),
          ChangeNotifierProvider(
            create: (_) => LibraryProvider(isFirebaseAvailable: firebaseInitialized),
          ),
          ChangeNotifierProvider(
            create: (_) => SubscriptionService(isFirebaseAvailable: firebaseInitialized),
          ),
          Provider(create: (_) => AuthService()),
        ],
        child: const MarkdownCreatorApp(),
      ),
    );
  }, (error, stack) {
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
    debugPrint('❌ Global Crash Guard: $error');
    debugPrint(stack.toString());
  });
}

class MarkdownCreatorApp extends StatelessWidget {
  const MarkdownCreatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          title: 'Markdown Creator Pro',
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
