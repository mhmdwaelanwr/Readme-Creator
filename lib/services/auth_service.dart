import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:math';

class AuthService {
  // Flag to check if Firebase is fully initialized with options
  bool get isReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // Official developer email for Owner privileges
  static const String adminEmail = "mhmdwaelanwr@gmail.com"; 

  FirebaseAuth get _auth => FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Tokens storage for integration services
  String? githubToken;
  String? googleAccessToken;

  Stream<User?> get user {
    if (!isReady) return Stream.value(null);
    return _auth.authStateChanges();
  }

  User? get currentUser {
    if (!isReady) return null;
    return _auth.currentUser;
  }

  bool get isAdmin => isReady && currentUser?.email == adminEmail;

  // --- Social Logins ---

  Future<UserCredential?> signInWithGoogle() async {
    if (!isReady) return null;
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      googleAccessToken = googleAuth.accessToken;

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
      githubProvider.addScope('repo'); 
      githubProvider.addScope('user');

      UserCredential credential;
      if (kIsWeb) {
        credential = await _auth.signInWithPopup(githubProvider);
      } else {
        credential = await _auth.signInWithProvider(githubProvider);
      }

      if (credential.credential is OAuthCredential) {
        githubToken = (credential.credential as OAuthCredential).accessToken;
      }

      return credential;
    } catch (e) {
      debugPrint('GitHub Auth Error: $e');
      return null;
    }
  }

  Future<UserCredential?> signInWithApple() async {
    if (!isReady) return null;
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final AuthCredential credential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Apple Auth Error: $e');
      return null;
    }
  }

  // --- Native Login ---

  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    if (!isReady) return null;
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    if (!isReady) return null;
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // --- Phone Authentication ---

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    if (!isReady) return;
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<UserCredential?> signInWithPhoneCredential(String verificationId, String smsCode) async {
    if (!isReady) return null;
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  // --- Utility ---

  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
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
      githubToken = null;
      googleAccessToken = null;
      if (await _googleSignIn.isSignedIn()) await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (_) {}
  }
}
