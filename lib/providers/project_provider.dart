import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/readme_element.dart';
import '../models/snippet.dart';
import '../utils/templates.dart';
import '../utils/markdown_importer.dart';

enum DeviceMode { desktop, tablet, mobile }

class ProjectProvider with ChangeNotifier {
  final List<ReadmeElement> _elements = [];
  String? _selectedElementId;
  ThemeMode _themeMode = ThemeMode.system;
  final Map<String, String> _variables = {
    'PROJECT_NAME': 'My Project',
    'GITHUB_USERNAME': 'username',
    'CURRENT_YEAR': DateTime.now().year.toString(),
  };
  String _licenseType = 'None';
  bool _includeContributing = false;
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

  final List<String> _undoStack = [];
  final List<String> _redoStack = [];

  List<ReadmeElement> get elements => _elements;
  String? get selectedElementId => _selectedElementId;
  ThemeMode get themeMode => _themeMode;
  Map<String, String> get variables => _variables;
  String get licenseType => _licenseType;
  bool get includeContributing => _includeContributing;
  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;
  bool get showGrid => _showGrid;
  List<String> get snapshots => _snapshots;
  String get listBullet => _listBullet;
  int get sectionSpacing => _sectionSpacing;
  DeviceMode get deviceMode => _deviceMode;
  bool get exportHtml => _exportHtml;
  String? get geminiApiKey => _geminiApiKey;
  String? get githubToken => _githubToken;
  Locale? get locale => _locale;

  // Helper to call notifyListeners safely after the current frame.
  void _safeNotify() {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          notifyListeners();
        } catch (_) {}
      });
    } catch (_) {
      // Fallback to direct notify if WidgetsBinding is not available for some reason
      try {
        notifyListeners();
      } catch (_) {}
    }
  }

  ProjectProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Theme
    if (prefs.containsKey('isDarkMode')) {
      final isDark = prefs.getBool('isDarkMode') ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }

    // Load Elements
    final elementsJson = prefs.getString('elements');
    if (elementsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(elementsJson);
        _elements.clear();
        _elements.addAll(decoded.map((e) => ReadmeElement.fromJson(e)).toList());
      } catch (e) {
        debugPrint('Error loading elements: $e');
      }
    }

    // Load Variables
    final variablesJson = prefs.getString('variables');
    if (variablesJson != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(variablesJson);
        _variables.addAll(decoded.cast<String, String>());
      } catch (e) {
        debugPrint('Error loading variables: $e');
      }
    }

    _licenseType = prefs.getString('licenseType') ?? 'None';
    _includeContributing = prefs.getBool('includeContributing') ?? false;
    _primaryColor = Color(prefs.getInt('primaryColor') ?? Colors.blue.toARGB32());
    _secondaryColor = Color(prefs.getInt('secondaryColor') ?? Colors.green.toARGB32());
    _showGrid = prefs.getBool('showGrid') ?? false;
    _snapshots = prefs.getStringList('snapshots') ?? [];
    _listBullet = prefs.getString('listBullet') ?? '*';
    _sectionSpacing = prefs.getInt('sectionSpacing') ?? 1;
    _exportHtml = prefs.getBool('exportHtml') ?? false;
    _geminiApiKey = prefs.getString('gemini_api_key');
    _githubToken = prefs.getString('github_token');
    final localeCode = prefs.getString('locale');
    if (localeCode != null) {
      _locale = Locale(localeCode);
    }
    _safeNotify();
  }

  void setLocale(Locale? locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale != null) {
      await prefs.setString('locale', locale.languageCode);
    } else {
      await prefs.remove('locale');
    }
    _safeNotify();
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();

    // Save Theme
    // We only save if it's explicitly set to dark or light, or we can save an int/string to represent system.
    // But existing logic uses boolean 'isDarkMode'.
    // If we want to support system, we should probably migrate to storing the enum index or string.
    // For backward compatibility, let's stick to boolean but maybe add a 'themeMode' key.
    // If user toggles, we switch between light and dark.
    // If we want "dynamic with device" as default, we should allow resetting to system?
    // The user asked for "Dark Mode default dynamic with device".
    // This implies: Default = System.
    // Toggle usually cycles Light -> Dark -> System -> Light? Or just Light <-> Dark.
    // Let's keep simple toggle Light <-> Dark for now, but default is System.
    // If user toggles, we save the preference.

    if (_themeMode == ThemeMode.system) {
       await prefs.remove('isDarkMode'); // Remove preference to fallback to system
    } else {
       await prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
    }

    // Save Elements
    final elementsJson = jsonEncode(_elements.map((e) => e.toJson()).toList());
    await prefs.setString('elements', elementsJson);

    // Save Variables
    final variablesJson = jsonEncode(_variables);
    await prefs.setString('variables', variablesJson);

    await prefs.setString('licenseType', _licenseType);
    await prefs.setBool('includeContributing', _includeContributing);
    await prefs.setInt('primaryColor', _primaryColor.toARGB32());
    await prefs.setInt('secondaryColor', _secondaryColor.toARGB32());
    await prefs.setBool('showGrid', _showGrid);
    await prefs.setStringList('snapshots', _snapshots);
    await prefs.setString('listBullet', _listBullet);
    await prefs.setInt('sectionSpacing', _sectionSpacing);
    await prefs.setBool('exportHtml', _exportHtml);
    if (_geminiApiKey != null) {
      await prefs.setString('gemini_api_key', _geminiApiKey!);
    } else {
      await prefs.remove('gemini_api_key');
    }
    if (_githubToken != null) {
      await prefs.setString('github_token', _githubToken!);
    } else {
      await prefs.remove('github_token');
    }
  }

  String exportToJson() {
    final Map<String, dynamic> data = {
      'elements': _elements.map((e) => e.toJson()).toList(),
      'variables': _variables,
      'licenseType': _licenseType,
      'includeContributing': _includeContributing,
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

      if (data['licenseType'] != null) {
        _licenseType = data['licenseType'];
      }

      if (data['includeContributing'] != null) {
        _includeContributing = data['includeContributing'];
      }

      if (data['primaryColor'] != null) {
        _primaryColor = Color(data['primaryColor']);
      }

      if (data['secondaryColor'] != null) {
        _secondaryColor = Color(data['secondaryColor']);
      }

      if (data['showGrid'] != null) {
        _showGrid = data['showGrid'];
      }

      if (data['listBullet'] != null) {
        _listBullet = data['listBullet'];
      }

      if (data['sectionSpacing'] != null) {
        _sectionSpacing = data['sectionSpacing'];
      }

      if (data['exportHtml'] != null) {
        _exportHtml = data['exportHtml'];
      }

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
      // Run parsing in a separate isolate to avoid blocking UI
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
    if (_undoStack.length > 20) {
      _undoStack.removeAt(0);
    }
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    final currentState = exportToJson();
    _redoStack.add(currentState);
    final previousState = _undoStack.removeLast();
    importFromJson(previousState);
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    final currentState = exportToJson();
    _undoStack.add(currentState);
    final nextState = _redoStack.removeLast();
    importFromJson(nextState);
  }

  ReadmeElement _createElementByType(ReadmeElementType type) {
    switch (type) {
      case ReadmeElementType.heading:
        return HeadingElement();
      case ReadmeElementType.paragraph:
        return ParagraphElement();
      case ReadmeElementType.image:
        return ImageElement();
      case ReadmeElementType.linkButton:
        return LinkButtonElement();
      case ReadmeElementType.codeBlock:
        return CodeBlockElement();
      case ReadmeElementType.list:
        return ListElement();
      case ReadmeElementType.badge:
        return BadgeElement();
      case ReadmeElementType.table:
        return TableElement();
      case ReadmeElementType.icon:
        return IconElement();
      case ReadmeElementType.embed:
        return EmbedElement();
      case ReadmeElementType.githubStats:
        return GitHubStatsElement();
      case ReadmeElementType.contributors:
        return ContributorsElement();
      case ReadmeElementType.mermaid:
        return MermaidElement();
      case ReadmeElementType.toc:
        return TOCElement();
      case ReadmeElementType.socials:
        return SocialsElement();
      case ReadmeElementType.blockquote:
        return BlockquoteElement();
      case ReadmeElementType.divider:
        return DividerElement();
      case ReadmeElementType.collapsible:
        return CollapsibleElement();
    }
  }

  void addElement(ReadmeElementType type) {
    insertElement(_elements.length, type);
  }

  void insertElement(int index, ReadmeElementType type) {
    _recordHistory();
    final newElement = _createElementByType(type);
    if (index < 0) index = 0;
    if (index > _elements.length) index = _elements.length;
    _elements.insert(index, newElement);
    _selectedElementId = newElement.id;
    _saveState();
    _safeNotify();
  }

  void insertSnippet(int index, Snippet snippet) {
    _recordHistory();
    try {
      final Map<String, dynamic> json = jsonDecode(snippet.elementJson);
      json.remove('id');
      final newElement = ReadmeElement.fromJson(json);

      if (index < 0) index = 0;
      if (index > _elements.length) index = _elements.length;
      _elements.insert(index, newElement);
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
    if (_selectedElementId == id) {
      _selectedElementId = null;
    }
    _saveState();
    _safeNotify();
  }

  void selectElement(String id) {
    _selectedElementId = id;
    _safeNotify();
  }

  void reorderElements(int oldIndex, int newIndex) {
    _recordHistory();
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final ReadmeElement item = _elements.removeAt(oldIndex);
    _elements.insert(newIndex, item);
    _saveState();
    _safeNotify();
  }

  void moveElementUp(String id) {
    final index = _elements.indexWhere((e) => e.id == id);
    if (index > 0) {
      reorderElements(index, index); // reorderElements expects newIndex to be where it lands.
      // Wait, reorderElements logic:
      // if old < new, new -= 1.
      // To move up: old=index, new=index-1.
      // if index > index-1 (true), new -= 1? No.
      // Let's just use swap logic for simple up/down.
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
      final element = _elements[index];
      ReadmeElement newElement;

      // Create a copy based on type
      if (element is HeadingElement) {
        newElement = HeadingElement(text: element.text, level: element.level);
      } else if (element is ParagraphElement) {
        newElement = ParagraphElement(text: element.text);
      } else if (element is ImageElement) {
        newElement = ImageElement(
            url: element.url,
            altText: element.altText,
            width: element.width);
      } else if (element is LinkButtonElement) {
        newElement = LinkButtonElement(text: element.text, url: element.url);
      } else if (element is CodeBlockElement) {
        newElement = CodeBlockElement(code: element.code, language: element.language);
      } else if (element is ListElement) {
        newElement = ListElement(items: List.from(element.items));
      } else if (element is BadgeElement) {
        newElement = BadgeElement(
            imageUrl: element.imageUrl,
            targetUrl: element.targetUrl,
            label: element.label);
      } else if (element is TableElement) {
        newElement = TableElement(
          headers: List.from(element.headers),
          rows: element.rows.map((r) => List<String>.from(r)).toList(),
          alignments: List.from(element.alignments),
        );
      } else if (element is IconElement) {
        newElement = IconElement(name: element.name, url: element.url, size: element.size);
      } else if (element is EmbedElement) {
        newElement = EmbedElement(url: element.url, typeName: element.typeName);
      } else if (element is GitHubStatsElement) {
        newElement = GitHubStatsElement(
          repoName: element.repoName,
          showStars: element.showStars,
          showForks: element.showForks,
          showIssues: element.showIssues,
          showLicense: element.showLicense,
        );
      } else if (element is ContributorsElement) {
        newElement = ContributorsElement(
          repoName: element.repoName,
          style: element.style,
        );
      } else if (element is MermaidElement) {
        newElement = MermaidElement(code: element.code);
      } else if (element is TOCElement) {
        newElement = TOCElement(title: element.title);
      } else if (element is SocialsElement) {
        newElement = SocialsElement(
          profiles: element.profiles.map((p) => SocialProfile(platform: p.platform, username: p.username)).toList(),
          style: element.style,
        );
      } else if (element is BlockquoteElement) {
        newElement = BlockquoteElement(text: element.text);
      } else if (element is DividerElement) {
        newElement = DividerElement();
      } else if (element is CollapsibleElement) {
        newElement = CollapsibleElement(summary: element.summary, content: element.content);
      } else {
        return;
      }

      _elements.insert(index + 1, newElement);
      _selectedElementId = newElement.id;
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

  void setIncludeContributing(bool include) {
    _recordHistory();
    _includeContributing = include;
    _saveState();
    _safeNotify();
  }

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

  void toggleGrid() {
    _showGrid = !_showGrid;
    _safeNotify();
  }

  void saveSnapshot() {
    final snapshot = exportToJson();
    _snapshots.insert(0, snapshot);
    if (_snapshots.length > 10) {
      _snapshots.removeLast();
    }
    _saveState();
    _safeNotify();
  }

  void restoreSnapshot(int index) {
    if (index >= 0 && index < _snapshots.length) {
      importFromJson(_snapshots[index]);
    }
  }

  void deleteSnapshot(int index) {
    if (index >= 0 && index < _snapshots.length) {
      _snapshots.removeAt(index);
      _saveState();
      _safeNotify();
    }
  }

  void setListBullet(String bullet) {
    _listBullet = bullet;
    _saveState();
    _safeNotify();
  }

  void setSectionSpacing(int spacing) {
    _sectionSpacing = spacing;
    _saveState();
    _safeNotify();
  }

  void setDeviceMode(DeviceMode mode) {
    _deviceMode = mode;
    _safeNotify();
  }

  void loadTemplate(ProjectTemplate template) {
    _recordHistory();
    _elements.clear();
    // Deep copy elements to avoid reference issues if we modify them
    // Since we don't have a deep copy method, we can serialize/deserialize or just create new instances manually.
    // For simplicity, let's use JSON roundtrip which is robust.
    final jsonList = template.elements.map((e) => e.toJson()).toList();
    _elements.addAll(jsonList.map((e) => ReadmeElement.fromJson(e)).toList());

    _selectedElementId = null;
    _saveState();
    _safeNotify();
  }

  void setExportHtml(bool value) {
    _exportHtml = value;
    _saveState();
    _safeNotify();
  }

  void setGeminiApiKey(String key) async {
    _geminiApiKey = key;
    _saveState();
    _safeNotify();
  }

  void setGitHubToken(String token) {
    _githubToken = token;
    _saveState();
    _safeNotify();
  }

  void addSnippet(Snippet snippet) {
    _recordHistory();
    try {
      final Map<String, dynamic> json = jsonDecode(snippet.elementJson);
      json.remove('id');
      final newElement = ReadmeElement.fromJson(json);

      _elements.add(newElement);
      _selectedElementId = newElement.id;
      _saveState();
      _safeNotify();
    } catch (e) {
      debugPrint('Error adding snippet: $e');
    }
  }
}

// Top-level function for compute
List<ReadmeElement> _parseMarkdownIsolate(String markdown) {
  final importer = MarkdownImporter();
  return importer.parse(markdown);
}
