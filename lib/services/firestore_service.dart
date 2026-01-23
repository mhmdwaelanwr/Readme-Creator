import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/saved_project.dart';
import '../models/snippet.dart';

class FirestoreService {
  bool get isReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  FirebaseFirestore? get _db => isReady ? FirebaseFirestore.instance : null;
  FirebaseAuth? get _auth => isReady ? FirebaseAuth.instance : null;

  // --- App Configuration (Admin) ---
  Stream<DocumentSnapshot> getAppConfig() {
    final db = _db;
    if (db == null) return const Stream.empty();
    return db.collection('settings').doc('app_config').snapshots();
  }

  Future<void> updateAppConfig(Map<String, dynamic> data) async {
    final db = _db;
    if (db == null) return;
    await db.collection('settings').doc('app_config').set(data, SetOptions(merge: true));
  }

  // --- User Management (Admin) ---
  Future<void> updateUserStatus(String uid, Map<String, dynamic> updates) async {
    final db = _db;
    if (db == null) return;
    await db.collection('users').doc(uid).update(updates);
  }

  // --- Templates (Admin & Public) ---
  Stream<List<Map<String, dynamic>>> getPublicTemplates() {
    final db = _db;
    if (db == null) return Stream.value([]);
    
    return db.collection('public_templates').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> savePublicTemplate({
    required String name,
    required String description,
    required List<Map<String, dynamic>> elements,
    String? category,
  }) async {
    final db = _db;
    if (db == null) return;
    await db.collection('public_templates').add({
      'name': name,
      'description': description,
      'elements': elements,
      'category': category ?? 'General',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTemplate(String id) async {
    final db = _db;
    if (db == null) return;
    await db.collection('public_templates').doc(id).delete();
  }

  // --- Personal Collections ---
  DocumentReference? get _userDoc {
    final auth = _auth;
    final db = _db;
    if (auth?.currentUser == null || db == null) return null;
    return db.collection('users').doc(auth!.currentUser!.uid);
  }

  Future<void> saveProject(SavedProject project) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await userDoc.collection('projects').doc(project.id).set(project.toJson());
  }

  Stream<List<SavedProject>> getProjects() {
    final userDoc = _userDoc;
    if (userDoc == null) return Stream.value([]);
    
    return userDoc.collection('projects')
        .orderBy('lastModified', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => SavedProject.fromJson(doc.data())).toList();
    });
  }

  Future<void> deleteProject(String id) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await userDoc.collection('projects').doc(id).delete();
  }

  Future<void> saveSnippet(Snippet snippet) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await userDoc.collection('snippets').doc(snippet.id).set(snippet.toJson());
  }

  Stream<List<Snippet>> getSnippets() {
    final userDoc = _userDoc;
    if (userDoc == null) return Stream.value([]);
    
    return userDoc.collection('snippets').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Snippet.fromJson(doc.data())).toList();
    });
  }

  Future<void> deleteSnippet(String id) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await userDoc.collection('snippets').doc(id).delete();
  }
}
