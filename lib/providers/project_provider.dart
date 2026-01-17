import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../models/readme_element.dart';
import '../models/snippet.dart';
import '../utils/templates.dart';
import '../utils/markdown_importer.dart';
import '../services/firestore_service.dart';

enum DeviceMode { desktop, tablet, mobile }

class ProjectProvider with ChangeNotifier {
  final PreferencesService _prefsService = PreferencesService();
  final FirestoreService _firestoreService = FirestoreService();
  
  final List<ReadmeElement> _elements = [];
  List<ProjectTemplate> _cloudTemplates = [];
  String? _selectedElementId;
  ThemeMode _themeMode = ThemeMode.system;
  
  final Map<String, String> _variables = {
    'PROJECT_NAME': 'My Project',
    'GITHUB_USERNAME': 'username',
    'CURRENT_YEAR': DateTime.now().year.toString(),
  };

  // State variables
  String _licenseType = 'None';
  bool _includeContributing = false;
  bool _includeSecurity = false;
  bool _includeSupport = false;
  bool _includeCodeOfConduct = false;
  bool _includeIssueTemplates = false;
  Color _primaryColor = Colors.blue;
  Color _secondaryColor = Colors.green;
  bool _showGrid = false;
  List<String> _snapshots = [];
  String _listBullet = '*';
  int _sectionSpacing = 1;
  DeviceMode _deviceMode = DeviceMode.desktop;
  bool _exportHtml = false;
  String? _geminiApiKey;
  String? _githubToken;
  Locale? _locale;
  String _targetLanguage = 'en';

  final List<String> _undoStack = [];
  final List<String> _redoStack = [];

  // Getters
  List<ReadmeElement> get elements => _elements;
  List<ProjectTemplate> get cloudTemplates => _cloudTemplates;
  String? get selectedElementId => _selectedElementId;
  ThemeMode get themeMode => _themeMode;
  Map<String, String> get variables => _variables;
  String get licenseType => _licenseType;
  bool get includeContributing => _includeContributing;
  bool get includeSecurity => _includeSecurity;
  bool get includeSupport => _includeSupport;
  bool get includeCodeOfConduct => _includeCodeOfConduct;
  bool get includeIssueTemplates => _includeIssueTemplates;
  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;
  bool get showGrid => _showGrid;
  List<String> get snapshots => _snapshots;
  String get listBullet => _listBullet;
  int get sectionSpacing => _sectionSpacing;
  DeviceMode get deviceMode => _deviceMode;
  bool get exportHtml => _exportHtml;
  String get geminiApiKey => _geminiApiKey ?? '';
  String get githubToken => _githubToken ?? '';
  Locale? get locale => _locale;
  String get targetLanguage => _targetLanguage;

  ProjectProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadPreferences();
    _listenToCloudTemplates();
  }

  // --- Cloud Logic ---
  
  void _listenToCloudTemplates() {
    _firestoreService.getPublicTemplates().listen((data) {
      _cloudTemplates = data.map((map) {
        final List<dynamic> elementsJson = map['elements'] ?? [];
        return ProjectTemplate(
          name: map['name'] ?? 'Cloud Template',
          description: map['description'] ?? '',
          elements: elementsJson.map((e) => ReadmeElement.fromJson(e)).toList(),
        );
      }).toList();
      notifyListeners();
    });
  }

  // Combine local and cloud templates for UI
  List<ProjectTemplate> get allTemplates => [...Templates.all, ..._cloudTemplates];

  // --- Core Logic ---

  void _safeNotify() {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          notifyListeners();
        } catch (_) {}
      });
    } catch (_) {
      try {
        notifyListeners();
      } catch (_) {}
    }
  }

  Future<void> _loadPreferences() async {
    _themeMode = await _prefsService.loadThemeMode();
    final loadedElements = await _prefsService.loadElements();
    if (loadedElements.isNotEmpty) {
      _elements.clear();
      _elements.addAll(loadedElements);
    }
    final loadedVariables = await _prefsService.loadVariables();
    if (loadedVariables.isNotEmpty) _variables.addAll(loadedVariables);

    _licenseType = await _prefsService.loadString(PreferencesService.keyLicenseType) ?? 'None';
    _includeContributing = await _prefsService.loadBool(PreferencesService.keyIncludeContributing) ?? false;
    _includeSecurity = await _prefsService.loadBool(PreferencesService.keyIncludeSecurity) ?? false;
    _includeSupport = await _prefsService.loadBool(PreferencesService.keyIncludeSupport) ?? false;
    _includeCodeOfConduct = await _prefsService.loadBool(PreferencesService.keyIncludeCodeOfConduct) ?? false;
    _includeIssueTemplates = await _prefsService.loadBool(PreferencesService.keyIncludeIssueTemplates) ?? false;

    final pColor = await _prefsService.loadInt(PreferencesService.keyPrimaryColor);
    if (pColor != null) _primaryColor = Color(pColor);

    final sColor = await _prefsService.loadInt(PreferencesService.keySecondaryColor);
    if (sColor != null) _secondaryColor = Color(sColor);

    _showGrid = await _prefsService.loadBool(PreferencesService.keyShowGrid) ?? false;
    _snapshots = await _prefsService.loadStringList(PreferencesService.keySnapshots) ?? [];
    _listBullet = await _prefsService.loadString(PreferencesService.keyListBullet) ?? '*';
    _sectionSpacing = await _prefsService.loadInt(PreferencesService.keySectionSpacing) ?? 1;
    _exportHtml = await _prefsService.loadBool(PreferencesService.keyExportHtml) ?? false;
    _geminiApiKey = await _prefsService.loadString(PreferencesService.keyGeminiApiKey);
    _githubToken = await _prefsService.loadString(PreferencesService.keyGithubToken);

    final localeCode = await _prefsService.loadString(PreferencesService.keyLocale);
    if (localeCode != null) _locale = Locale(localeCode);
    _targetLanguage = await _prefsService.loadString(PreferencesService.keyTargetLanguage) ?? 'en';

    _safeNotify();
  }

  void setLocale(Locale? locale) async {
    _locale = locale;
    if (locale != null) {
      await _prefsService.saveString(PreferencesService.keyLocale, locale.languageCode);
    } else {
      await _prefsService.remove(PreferencesService.keyLocale);
    }
    _safeNotify();
  }

  void setTargetLanguage(String languageCode) {
    _targetLanguage = languageCode;
    _saveState();
    _safeNotify();
  }

  Future<void> _saveState() async {
    await _prefsService.saveThemeMode(_themeMode);
    await _prefsService.saveElements(_elements);
    await _prefsService.saveVariables(_variables);
    await _prefsService.saveString(PreferencesService.keyLicenseType, _licenseType);
    await _prefsService.saveBool(PreferencesService.keyIncludeContributing, _includeContributing);
    await _prefsService.saveBool(PreferencesService.keyIncludeSecurity, _includeSecurity);
    await _prefsService.saveBool(PreferencesService.keyIncludeSupport, _includeSupport);
    await _prefsService.saveBool(PreferencesService.keyIncludeCodeOfConduct, _includeCodeOfConduct);
    await _prefsService.saveBool(PreferencesService.keyIncludeIssueTemplates, _includeIssueTemplates);
    await _prefsService.saveInt(PreferencesService.keyPrimaryColor, _primaryColor.toARGB32());
    await _prefsService.saveInt(PreferencesService.keySecondaryColor, _secondaryColor.toARGB32());
    await _prefsService.saveBool(PreferencesService.keyShowGrid, _showGrid);
    await _prefsService.saveStringList(PreferencesService.keySnapshots, _snapshots);
    await _prefsService.saveString(PreferencesService.keyListBullet, _listBullet);
    await _prefsService.saveInt(PreferencesService.keySectionSpacing, _sectionSpacing);
    await _prefsService.saveBool(PreferencesService.keyExportHtml, _exportHtml);
    if (_geminiApiKey != null) await _prefsService.saveString(PreferencesService.keyGeminiApiKey, _geminiApiKey!);
    if (_githubToken != null) await _prefsService.saveString(PreferencesService.keyGithubToken, _githubToken!);
    await _prefsService.saveString(PreferencesService.keyTargetLanguage, _targetLanguage);
  }

  String exportToJson() {
    final Map<String, dynamic> data = {
      'elements': _elements.map((e) => e.toJson()).toList(),
      'variables': _variables,
      'licenseType': _licenseType,
      'includeContributing': _includeContributing,
      'includeSecurity': _includeSecurity,
      'includeSupport': _includeSupport,
      'includeCodeOfConduct': _includeCodeOfConduct,
      'includeIssueTemplates': _includeIssueTemplates,
      'primaryColor': _primaryColor.toARGB32(),
      'secondaryColor': _secondaryColor.toARGB32(),
      'showGrid': _showGrid,
      'listBullet': _listBullet,
      'sectionSpacing': _sectionSpacing,
      'exportHtml': _exportHtml,
      'version': 1,
    };
    return jsonEncode(data);
  }

  void importFromJson(String jsonString) {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      if (data['elements'] != null) {
        _elements.clear();
        final List<dynamic> elementsList = data['elements'];
        _elements.addAll(elementsList.map((e) => ReadmeElement.fromJson(e)).toList());
      }
      if (data['variables'] != null) {
        _variables.clear();
        _variables.addAll(Map<String, String>.from(data['variables']));
      }
      if (data['licenseType'] != null) _licenseType = data['licenseType'];
      if (data['includeContributing'] != null) _includeContributing = data['includeContributing'];
      if (data['includeSecurity'] != null) _includeSecurity = data['includeSecurity'];
      if (data['includeSupport'] != null) _includeSupport = data['includeSupport'];
      if (data['includeCodeOfConduct'] != null) _includeCodeOfConduct = data['includeCodeOfConduct'];
      if (data['includeIssueTemplates'] != null) _includeIssueTemplates = data['includeIssueTemplates'];
      if (data['primaryColor'] != null) _primaryColor = Color(data['primaryColor']);
      if (data['secondaryColor'] != null) _secondaryColor = Color(data['secondaryColor']);
      if (data['showGrid'] != null) _showGrid = data['showGrid'];
      if (data['listBullet'] != null) _listBullet = data['listBullet'];
      if (data['sectionSpacing'] != null) _sectionSpacing = data['sectionSpacing'];
      if (data['exportHtml'] != null) _exportHtml = data['exportHtml'];
      _selectedElementId = null;
      _saveState();
      _safeNotify();
    } catch (e) {
      debugPrint('Error importing JSON: $e');
      rethrow;
    }
  }

  Future<void> importMarkdown(String markdown) async {
    _recordHistory();
    try {
      final newElements = await compute(_parseMarkdownIsolate, markdown);
      _elements.clear();
      _elements.addAll(newElements);
      _selectedElementId = null;
      _saveState();
      _safeNotify();
    } catch (e) {
      debugPrint('Error importing Markdown: $e');
      rethrow;
    }
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.system) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    }
    _saveState();
    _safeNotify();
  }

  ReadmeElement? get selectedElement {
    if (_selectedElementId == null) return null;
    try {
      return _elements.firstWhere((e) => e.id == _selectedElementId);
    } catch (e) {
      return null;
    }
  }

  void _recordHistory() {
    _undoStack.add(exportToJson());
    _redoStack.clear();
    if (_undoStack.length > 20) _undoStack.removeAt(0);
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(exportToJson());
    importFromJson(_undoStack.removeLast());
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(exportToJson());
    importFromJson(_redoStack.removeLast());
  }

  void addElement(ReadmeElementType type) {
    insertElement(_elements.length, type);
  }

  void addElementObject(ReadmeElement element) {
    _recordHistory();
    _elements.add(element);
    _selectedElementId = element.id;
    _saveState();
    _safeNotify();
  }

  void insertElement(int index, ReadmeElementType type) {
    _recordHistory();
    final newElement = _createElementByType(type);
    _elements.insert(index.clamp(0, _elements.length), newElement);
    _selectedElementId = newElement.id;
    _saveState();
    _safeNotify();
  }

  ReadmeElement _createElementByType(ReadmeElementType type) {
    switch (type) {
      case ReadmeElementType.heading: return HeadingElement();
      case ReadmeElementType.paragraph: return ParagraphElement();
      case ReadmeElementType.image: return ImageElement();
      case ReadmeElementType.linkButton: return LinkButtonElement();
      case ReadmeElementType.codeBlock: return CodeBlockElement();
      case ReadmeElementType.list: return ListElement();
      case ReadmeElementType.badge: return BadgeElement();
      case ReadmeElementType.table: return TableElement();
      case ReadmeElementType.icon: return IconElement();
      case ReadmeElementType.embed: return EmbedElement();
      case ReadmeElementType.githubStats: return GitHubStatsElement();
      case ReadmeElementType.contributors: return ContributorsElement();
      case ReadmeElementType.mermaid: return MermaidElement();
      case ReadmeElementType.toc: return TOCElement();
      case ReadmeElementType.socials: return SocialsElement();
      case ReadmeElementType.blockquote: return BlockquoteElement();
      case ReadmeElementType.divider: return DividerElement();
      case ReadmeElementType.collapsible: return CollapsibleElement();
      case ReadmeElementType.dynamicWidget: return DynamicWidgetElement();
      case ReadmeElementType.raw: return RawElement();
    }
  }

  void addSnippet(Snippet snippet) {
    insertSnippet(_elements.length, snippet);
  }

  void insertSnippet(int index, Snippet snippet) {
    _recordHistory();
    try {
      final json = jsonDecode(snippet.elementJson);
      json.remove('id');
      final newElement = ReadmeElement.fromJson(json);
      _elements.insert(index.clamp(0, _elements.length), newElement);
      _selectedElementId = newElement.id;
      _saveState();
      _safeNotify();
    } catch (e) {
      debugPrint('Error adding snippet: $e');
    }
  }

  void removeElement(String id) {
    _recordHistory();
    _elements.removeWhere((e) => e.id == id);
    if (_selectedElementId == id) _selectedElementId = null;
    _saveState();
    _safeNotify();
  }

  void selectElement(String id) {
    _selectedElementId = id;
    _safeNotify();
  }

  void reorderElements(int oldIndex, int newIndex) {
    _recordHistory();
    if (oldIndex < newIndex) newIndex -= 1;
    final item = _elements.removeAt(oldIndex);
    _elements.insert(newIndex, item);
    _saveState();
    _safeNotify();
  }

  void moveElementUp(String id) {
    final index = _elements.indexWhere((e) => e.id == id);
    if (index > 0) {
      _recordHistory();
      final item = _elements.removeAt(index);
      _elements.insert(index - 1, item);
      _saveState();
      _safeNotify();
    }
  }

  void moveElementDown(String id) {
    final index = _elements.indexWhere((e) => e.id == id);
    if (index != -1 && index < _elements.length - 1) {
      _recordHistory();
      final item = _elements.removeAt(index);
      _elements.insert(index + 1, item);
      _saveState();
      _safeNotify();
    }
  }

  void duplicateElement(String id) {
    _recordHistory();
    final index = _elements.indexWhere((e) => e.id == id);
    if (index != -1) {
      _elements.insert(index + 1, _elements[index].copy());
      _selectedElementId = _elements[index + 1].id;
      _saveState();
      _safeNotify();
    }
  }

  void clearElements() {
    _recordHistory();
    _elements.clear();
    _selectedElementId = null;
    _saveState();
    _safeNotify();
  }

  void updateElement() {
    _saveState();
    _safeNotify();
  }

  void updateVariable(String key, String value) {
    _recordHistory();
    _variables[key] = value;
    _saveState();
    _safeNotify();
  }

  void setLicenseType(String type) {
    _recordHistory();
    _licenseType = type;
    _saveState();
    _safeNotify();
  }

  void setIncludeContributing(bool value) { _includeContributing = value; notifyListeners(); }
  void setIncludeSecurity(bool value) { _includeSecurity = value; notifyListeners(); }
  void setIncludeSupport(bool value) { _includeSupport = value; notifyListeners(); }
  void setIncludeCodeOfConduct(bool value) { _includeCodeOfConduct = value; notifyListeners(); }
  void setIncludeIssueTemplates(bool value) { _includeIssueTemplates = value; notifyListeners(); }

  void setPrimaryColor(Color color) {
    _recordHistory();
    _primaryColor = color;
    _saveState();
    _safeNotify();
  }

  void setSecondaryColor(Color color) {
    _recordHistory();
    _secondaryColor = color;
    _saveState();
    _safeNotify();
  }

  void toggleGrid() { _showGrid = !_showGrid; _safeNotify(); }

  void saveSnapshot() {
    final snapshot = exportToJson();
    _snapshots.insert(0, snapshot);
    if (_snapshots.length > 10) _snapshots.removeLast();
    _saveState();
    _safeNotify();
  }

  void restoreSnapshot(int index) {
    if (index >= 0 && index < _snapshots.length) importFromJson(_snapshots[index]);
  }

  void deleteSnapshot(int index) {
    if (index >= 0 && index < _snapshots.length) {
      _snapshots.removeAt(index);
      _saveState();
      _safeNotify();
    }
  }

  void setListBullet(String bullet) { _listBullet = bullet; _saveState(); _safeNotify(); }
  void setSectionSpacing(int spacing) { _sectionSpacing = spacing; _saveState(); _safeNotify(); }
  void setDeviceMode(DeviceMode mode) { _deviceMode = mode; _safeNotify(); }

  void loadTemplate(ProjectTemplate template) {
    _recordHistory();
    _elements.clear();
    _elements.addAll(template.elements.map((e) => e.copy()).toList());
    _selectedElementId = null;
    _saveState();
    _safeNotify();
  }

  void setExportHtml(bool value) { _exportHtml = value; _saveState(); _safeNotify(); }
  void setGeminiApiKey(String key) { _geminiApiKey = key; _saveState(); _safeNotify(); }
  void setGitHubToken(String token) { _githubToken = token; _saveState(); _safeNotify(); }
}

List<ReadmeElement> _parseMarkdownIsolate(String markdown) {
  return MarkdownImporter().parse(markdown);
}
