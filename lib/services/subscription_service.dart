import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class SubscriptionService extends ChangeNotifier {
  final bool isFirebaseAvailable;
  bool _isPro = false;
  bool get isPro => _isPro;

  SubscriptionService({required this.isFirebaseAvailable}) {
    if (isFirebaseAvailable) {
      FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user != null) {
          _checkSubscriptionStatus(user);
        } else {
          _isPro = false;
          notifyListeners();
        }
      });
    } else {
      // In offline/dev mode on Windows, we can default to Pro for testing
      _isPro = kDebugMode; 
      notifyListeners();
    }
  }

  Future<void> _checkSubscriptionStatus(User user) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      
      if (!doc.exists) {
        await _grantTrialPro(user);
      } else {
        _isPro = doc.data()?['isPro'] ?? false;
      }
    } catch (e) {
      debugPrint('Subscription check failed (Offline?): $e');
    }
    notifyListeners();
  }

  Future<void> _grantTrialPro(User user) async {
    _isPro = true;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'isPro': true,
        'joinDate': FieldValue.serverTimestamp(),
        'planType': 'EarlyAdopter_Trial',
      });
    } catch (e) {
      debugPrint('Cloud save failed: $e');
    }
    notifyListeners();
  }

  Future<void> updateProStatus(String uid, bool status) async {
    if (!isFirebaseAvailable) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'isPro': status});
    notifyListeners();
  }
}
