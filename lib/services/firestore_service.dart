import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/saved_project.dart';
import '../models/snippet.dart';

class FirestoreService {
  // Static check to see if Firebase is initialized
  bool get isReady => Firebase.apps.isNotEmpty;

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getPublicTemplates() {
    if (!isReady) return Stream.value([]);
    return _db.collection('public_templates').snapshots().map((snapshot) {
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
  }) async {
    if (!isReady) return;
    await _db.collection('public_templates').add({
      'name': name,
      'description': description,
      'elements': elements,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Personal Collections
  CollectionReference get _projectsRef => _db.collection('users').doc(_auth.currentUser?.uid).collection('projects');
  CollectionReference get _snippetsRef => _db.collection('users').doc(_auth.currentUser?.uid).collection('snippets');

  Future<void> saveProject(SavedProject project) async {
    if (!isReady || _auth.currentUser == null) return;
    await _projectsRef.doc(project.id).set(project.toJson());
  }

  Stream<List<SavedProject>> getProjects() {
    if (!isReady || _auth.currentUser == null) return Stream.value([]);
    return _projectsRef.orderBy('lastModified', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => SavedProject.fromJson(doc.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<void> deleteProject(String id) async {
    if (!isReady || _auth.currentUser == null) return;
    await _projectsRef.doc(id).delete();
  }

  Future<void> saveSnippet(Snippet snippet) async {
    if (!isReady || _auth.currentUser == null) return;
    await _snippetsRef.doc(snippet.id).set(snippet.toJson());
  }

  Stream<List<Snippet>> getSnippets() {
    if (!isReady || _auth.currentUser == null) return Stream.value([]);
    return _snippetsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Snippet.fromJson(doc.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<void> deleteSnippet(String id) async {
    if (!isReady || _auth.currentUser == null) return;
    await _snippetsRef.doc(id).delete();
  }
}
