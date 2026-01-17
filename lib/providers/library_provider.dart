import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/saved_project.dart';
import '../models/snippet.dart';
import '../services/preferences_service.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class LibraryProvider with ChangeNotifier {
  final PreferencesService _prefsService = PreferencesService();
  final bool isFirebaseAvailable;
  
  late final FirestoreService _firestoreService;
  late final AuthService _authService;

  List<SavedProject> _projects = [];
  List<Snippet> _snippets = [];

  List<SavedProject> get projects => _projects;
  List<Snippet> get snippets => _snippets;

  LibraryProvider({this.isFirebaseAvailable = false}) {
    if (isFirebaseAvailable) {
      _firestoreService = FirestoreService();
      _authService = AuthService();
    }
    _init();
  }

  Future<void> _init() async {
    // 1. Handle Auth only if Firebase is ready
    if (isFirebaseAvailable && _authService.currentUser == null) {
      try {
        await _authService.signInAnonymously();
      } catch (e) {
        debugPrint('Silent Auth failed: $e');
      }
    }

    // 2. Always load local for persistence
    await _loadLocalLibrary();

    // 3. Sync if online
    if (isFirebaseAvailable) {
      _listenToCloudChanges();
    }
  }

  Future<void> _loadLocalLibrary() async {
    final projectsJson = await _prefsService.loadStringList(PreferencesService.keySavedProjects);
    if (projectsJson != null) {
      _projects = projectsJson.map((str) => SavedProject.fromJson(jsonDecode(str))).toList();
    }

    final snippetsJson = await _prefsService.loadStringList(PreferencesService.keySavedSnippets);
    if (snippetsJson != null) {
      _snippets = snippetsJson.map((str) => Snippet.fromJson(jsonDecode(str))).toList();
    }
    notifyListeners();
  }

  void _listenToCloudChanges() {
    if (!isFirebaseAvailable) return;

    _firestoreService.getProjects().listen((cloudProjects) {
      if (cloudProjects.isNotEmpty) {
        _projects = cloudProjects;
        _saveLocalLibrary();
        notifyListeners();
      }
    });

    _firestoreService.getSnippets().listen((cloudSnippets) {
      if (cloudSnippets.isNotEmpty) {
        _snippets = cloudSnippets;
        _saveLocalLibrary();
        notifyListeners();
      }
    });
  }

  Future<void> _saveLocalLibrary() async {
    final projectsJson = _projects.map((p) => jsonEncode(p.toJson())).toList();
    await _prefsService.saveStringList(PreferencesService.keySavedProjects, projectsJson);

    final snippetsJson = _snippets.map((s) => jsonEncode(s.toJson())).toList();
    await _prefsService.saveStringList(PreferencesService.keySavedSnippets, snippetsJson);
  }

  void saveProject({
    required String name,
    required String description,
    required List<String> tags,
    required String jsonContent,
    String? id,
  }) {
    final now = DateTime.now();
    final projectId = id ?? const Uuid().v4();
    
    final project = SavedProject(
      id: projectId,
      name: name,
      description: description,
      tags: tags,
      lastModified: now,
      jsonContent: jsonContent,
    );

    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      _projects[index] = project;
    } else {
      _projects.add(project);
    }

    _saveLocalLibrary();
    
    if (isFirebaseAvailable) {
      _firestoreService.saveProject(project);
    }
    
    notifyListeners();
  }

  void deleteProject(String id) {
    _projects.removeWhere((p) => p.id == id);
    _saveLocalLibrary();
    if (isFirebaseAvailable) {
      _firestoreService.deleteProject(id);
    }
    notifyListeners();
  }

  void saveSnippet({required String name, required String elementJson}) {
    final snippet = Snippet(
      id: const Uuid().v4(),
      name: name,
      elementJson: elementJson,
    );
    _snippets.add(snippet);
    _saveLocalLibrary();
    if (isFirebaseAvailable) {
      _firestoreService.saveSnippet(snippet);
    }
    notifyListeners();
  }

  void deleteSnippet(String id) {
    _snippets.removeWhere((s) => s.id == id);
    _saveLocalLibrary();
    if (isFirebaseAvailable) {
      _firestoreService.deleteSnippet(id);
    }
    notifyListeners();
  }
}
