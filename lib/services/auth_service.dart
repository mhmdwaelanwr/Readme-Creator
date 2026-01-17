import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  // Use a getter that safely checks initialization
  bool get isReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static const String adminEmail = "mhmdwaelanwr@gmail.com"; 

  // NEVER call .instance outside of a method that checks isReady first
  FirebaseAuth get _auth => FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get user {
    if (!isReady) return Stream.value(null);
    return _auth.authStateChanges();
  }

  User? get currentUser {
    if (!isReady) return null;
    return _auth.currentUser;
  }

  bool get isAdmin => isReady && currentUser?.email == adminEmail;

  Future<UserCredential?> signInWithGoogle() async {
    if (!isReady) return null;
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Google Auth Error: $e');
      return null;
    }
  }

  Future<UserCredential?> signInWithGitHub() async {
    if (!isReady) return null;
    try {
      GithubAuthProvider githubProvider = GithubAuthProvider();
      if (kIsWeb) {
        return await _auth.signInWithPopup(githubProvider);
      } else {
        return await _auth.signInWithProvider(githubProvider);
      }
    } catch (e) {
      debugPrint('GitHub Auth Error: $e');
      return null;
    }
  }

  Future<UserCredential?> signInAnonymously() async {
    if (!isReady) return null;
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      debugPrint('Anonymous Auth Error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    if (!isReady) return;
    try {
      if (await _googleSignIn.isSignedIn()) await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (_) {}
  }
}
