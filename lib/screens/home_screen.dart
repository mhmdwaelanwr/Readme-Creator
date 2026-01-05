import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:readme_creator/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../models/readme_element.dart';
import '../widgets/components_panel.dart';
import '../widgets/editor_canvas.dart';
import '../widgets/settings_panel.dart';
import '../providers/project_provider.dart';
import '../providers/library_provider.dart';
import '../utils/templates.dart';
import '../utils/project_exporter.dart';
import '../utils/downloader.dart';
import '../utils/onboarding_helper.dart';
import 'projects_library_screen.dart';
import '../generator/markdown_generator.dart';
import 'social_preview_screen.dart';
import 'github_actions_generator.dart';
import '../services/health_check_service.dart';
import '../services/codebase_scanner_service.dart';
import '../services/github_scanner_service.dart';
import '../services/ai_service.dart';
import '../utils/toast_helper.dart';
import '../utils/debouncer.dart';
import '../widgets/developer_info_dialog.dart';
import '../utils/dialog_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _componentsKey = GlobalKey();
  final GlobalKey _canvasKey = GlobalKey();
  final GlobalKey _settingsKey = GlobalKey();
  final GlobalKey _exportKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode _focusNode = FocusNode();
  bool _showPreview = false;
  bool _isFocusMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      OnboardingHelper.showOnboarding(
        context: context,
        componentsKey: _componentsKey,
        canvasKey: _canvasKey,
        settingsKey: _settingsKey,
        exportKey: _exportKey,
      );
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final provider = Provider.of<ProjectProvider>(context, listen: false);

    return CallbackShortcuts(
      bindings: {
        // File Operations
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): () => _showSaveToLibraryDialog(context, provider),
        const SingleActivator(LogicalKeyboardKey.keyE, control: true): () {
           ProjectExporter.export(
            elements: provider.elements,
            variables: provider.variables,
            licenseType: provider.licenseType,
            includeContributing: provider.includeContributing,
            listBullet: provider.listBullet,
            sectionSpacing: provider.sectionSpacing,
            exportHtml: provider.exportHtml,
          );
        },
        const SingleActivator(LogicalKeyboardKey.keyP, control: true): () => _printReadme(context, provider),

        // Edit Operations
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true): () => provider.undo(),
        const SingleActivator(LogicalKeyboardKey.keyY, control: true): () => provider.redo(),

        // View Operations
        const SingleActivator(LogicalKeyboardKey.f11): () => setState(() => _isFocusMode = !_isFocusMode),
        const SingleActivator(LogicalKeyboardKey.keyH, control: true, shift: true): () => setState(() => _showPreview = !_showPreview),
        const SingleActivator(LogicalKeyboardKey.keyG, control: true): () => provider.toggleGrid(),
        const SingleActivator(LogicalKeyboardKey.keyT, control: true): () => provider.toggleTheme(),
        const SingleActivator(LogicalKeyboardKey.comma, control: true): () => _showProjectSettingsDialog(context, provider),

        // Help
        const SingleActivator(LogicalKeyboardKey.f1): () => OnboardingHelper.restartOnboarding(
            context: context,
            componentsKey: _componentsKey,
            canvasKey: _canvasKey,
            settingsKey: _settingsKey,
            exportKey: _exportKey,
          ),

        // Element Shortcuts (Add)
        const SingleActivator(LogicalKeyboardKey.digit1, control: true, alt: true): () => provider.addElement(ReadmeElementType.heading),
        const SingleActivator(LogicalKeyboardKey.digit2, control: true, alt: true): () {
           provider.addElement(ReadmeElementType.heading);
           // We can't easily set level here without refactoring addElement to take props or accessing the last element.
           // For now, just adding heading is fine, user can change level.
        },
        const SingleActivator(LogicalKeyboardKey.digit3, control: true, alt: true): () => provider.addElement(ReadmeElementType.paragraph),
        const SingleActivator(LogicalKeyboardKey.keyI, control: true, alt: true): () => provider.addElement(ReadmeElementType.image),
        const SingleActivator(LogicalKeyboardKey.keyT, control: true, alt: true): () => provider.addElement(ReadmeElementType.table),
        const SingleActivator(LogicalKeyboardKey.keyL, control: true, alt: true): () => provider.addElement(ReadmeElementType.list),
        const SingleActivator(LogicalKeyboardKey.keyQ, control: true, alt: true): () => provider.addElement(ReadmeElementType.blockquote),
        const SingleActivator(LogicalKeyboardKey.keyK, control: true, alt: true): () => provider.addElement(ReadmeElementType.linkButton),
      },
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (node, event) {
          // Ensure keys bubble up if not handled, but CallbackShortcuts should handle them first.
          // This is just to ensure the Focus node is active.
          return KeyEventResult.ignored;
        },
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Row(
              children: [
                Icon(Icons.description, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    AppLocalizations.of(context)!.appTitle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            actions: isDesktop ? _buildDesktopActions(context) : _buildMobileActions(context),
          ),
          drawer: isDesktop ? null : const Drawer(child: ComponentsPanel()),
          endDrawer: isDesktop ? null : const Drawer(child: SettingsPanel()),
          body: isDesktop ? _buildDesktopBody(context) : _buildMobileBody(context),
        ),
      ),
    );
  }

  List<Widget> _buildDesktopActions(BuildContext context) {
    return [
      Consumer<ProjectProvider>(
        builder: (context, provider, child) {
          return Row(
            children: [
              // Device Mode Toggles
              IconButton(
                icon: const Icon(Icons.desktop_mac),
                color: provider.deviceMode == DeviceMode.desktop ? Colors.blue : null,
                tooltip: 'Desktop View',
                onPressed: () => provider.setDeviceMode(DeviceMode.desktop),
              ),
              IconButton(
                icon: const Icon(Icons.tablet_mac),
                color: provider.deviceMode == DeviceMode.tablet ? Colors.blue : null,
                tooltip: 'Tablet View',
                onPressed: () => provider.setDeviceMode(DeviceMode.tablet),
              ),
              IconButton(
                icon: const Icon(Icons.phone_iphone),
                color: provider.deviceMode == DeviceMode.mobile ? Colors.blue : null,
                tooltip: 'Mobile View',
                onPressed: () => provider.setDeviceMode(DeviceMode.mobile),
              ),
              const VerticalDivider(),
              PopupMenuButton<ProjectTemplate>(
                tooltip: 'Templates',
                icon: const Icon(Icons.file_copy),
                onSelected: (template) {
                  showSafeDialog(
                    context,
                    builder: (context) => AlertDialog(
                      title: Text('Load ${template.name}?', style: GoogleFonts.inter()),
                      content: const Text('This will replace your current workspace.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            provider.loadTemplate(template);
                            Navigator.pop(context);
                          },
                          child: const Text('Load'),
                        ),
                      ],
                    ),
                  );
                },
                itemBuilder: (context) => Templates.all.map((t) {
                  return PopupMenuItem(
                    value: t,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(t.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  );
                }).toList(),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Project Settings',
                onPressed: () => _showProjectSettingsDialog(context, provider),
              ),
              IconButton(
                icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode),
                tooltip: 'Toggle Theme',
                onPressed: () => provider.toggleTheme(),
              ),
              IconButton(
                icon: Icon(provider.showGrid ? Icons.grid_on : Icons.grid_off),
                color: provider.showGrid ? Colors.blue : null,
                tooltip: 'Toggle Grid',
                onPressed: () => provider.toggleGrid(),
              ),
              IconButton(
                icon: Icon(_showPreview ? Icons.visibility : Icons.visibility_off),
                tooltip: _showPreview ? 'Hide Live Preview' : 'Show Live Preview',
                onPressed: () {
                  setState(() {
                    _showPreview = !_showPreview;
                  });
                },
              ),
              IconButton(
                icon: Icon(_isFocusMode ? Icons.fullscreen_exit : Icons.fullscreen),
                tooltip: _isFocusMode ? 'Exit Focus Mode' : 'Focus Mode',
                onPressed: () {
                  setState(() {
                    _isFocusMode = !_isFocusMode;
                  });
                },
              ),
              const VerticalDivider(),
              IconButton(
                icon: const Icon(Icons.library_books),
                tooltip: 'My Projects Library',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProjectsLibraryScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.health_and_safety),
                tooltip: 'Health Check',
                onPressed: () {
                  final issues = HealthCheckService.analyze(provider.elements);
                  _showHealthCheckDialog(context, issues, provider);
                },
              ),
              IconButton(
                icon: const Icon(Icons.print),
                tooltip: 'Print / Export PDF',
                onPressed: () => _printReadme(context, provider),
              ),
            ],
          );
        },
      ),
      IconButton(
        key: _exportKey,
        icon: const Icon(Icons.download),
        tooltip: 'Export Project',
        onPressed: () {
          final provider = Provider.of<ProjectProvider>(context, listen: false);
          ProjectExporter.export(
            elements: provider.elements,
            variables: provider.variables,
            licenseType: provider.licenseType,
            includeContributing: provider.includeContributing,
            listBullet: provider.listBullet,
            sectionSpacing: provider.sectionSpacing,
            exportHtml: provider.exportHtml,
          );
        },
      ),
      _buildMoreOptionsButton(context),
    ];
  }

  List<Widget> _buildMobileActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.settings),
        tooltip: 'Settings',
        onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
      ),
      _buildMoreOptionsButton(context),
    ];
  }

  Widget _buildMoreOptionsButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'More Options',
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'save_library',
          child: Row(children: [const Icon(Icons.save_alt, color: Colors.grey), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.saveToLibrary)]),
        ),
        PopupMenuItem(
          value: 'snapshots',
          child: Row(children: [const Icon(Icons.history, color: Colors.grey), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.localSnapshots)]),
        ),
        PopupMenuItem(
          value: 'clear_workspace',
          child: Row(children: [const Icon(Icons.delete_forever, color: Colors.red), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.clearWorkspace, style: const TextStyle(color: Colors.red))]),
        ),
        PopupMenuItem(
          value: 'import_markdown',
          child: Row(children: [const Icon(Icons.file_upload, color: Colors.grey), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.importMarkdown)]),
        ),
        PopupMenuItem(
          value: 'social_preview',
          child: Row(children: [const Icon(Icons.image, color: Colors.grey), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.socialPreviewDesigner)]),
        ),
        PopupMenuItem(
          value: 'github_actions',
          child: Row(children: [const Icon(Icons.build, color: Colors.grey), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.githubActionsGenerator)]),
        ),
        PopupMenuItem(
          value: 'export_json',
          child: Row(children: [const Icon(Icons.javascript, color: Colors.grey), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.exportProjectJson)]),
        ),
        PopupMenuItem(
          value: 'import_json',
          child: Row(children: [const Icon(Icons.data_object, color: Colors.grey), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.importProjectJson)]),
        ),
        PopupMenuItem(
          value: 'ai_settings',
          child: Row(children: [const Icon(Icons.psychology, color: Colors.grey), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.aiSettings)]),
        ),
        PopupMenuItem(
          value: 'generate_codebase',
          child: Row(children: [const Icon(Icons.auto_awesome, color: Colors.purple), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.generateFromCodebase)]),
        ),
        PopupMenuItem(
          value: 'change_language',
          child: Row(children: [const Icon(Icons.language, color: Colors.grey), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.changeLanguage)]),
        ),
        PopupMenuItem(
          value: 'help',
          child: Row(children: [const Icon(Icons.help_outline, color: Colors.grey), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.showTour)]),
        ),
        PopupMenuItem(
          value: 'shortcuts',
          child: Row(children: [const Icon(Icons.keyboard, color: Colors.grey), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.keyboardShortcuts)]),
        ),
        PopupMenuItem(
          value: 'about_dev',
          child: Row(children: [const Icon(Icons.person, color: Colors.grey), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.aboutDeveloper)]),
        ),
        PopupMenuItem(
          value: 'about',
          child: Row(children: [const Icon(Icons.info_outline, color: Colors.grey), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.aboutApp)]),
        ),
      ],
      onSelected: (value) async {
        final provider = Provider.of<ProjectProvider>(context, listen: false);
        if (value == 'save_library') {
          _showSaveToLibraryDialog(context, provider);
        } else if (value == 'snapshots') {
          _showSnapshotsDialog(context, provider);
        } else if (value == 'clear_workspace') {
          showSafeDialog(
            context,
            builder: (context) => AlertDialog(
              title: const Text('Clear Workspace?'),
              content: const Text('This will remove all elements. This action cannot be undone (unless you have a snapshot).'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    provider.clearElements();
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Clear'),
                ),
              ],
            ),
          );
        } else if (value == 'import_markdown') {
          _showImportMarkdownDialog(context, provider);
        } else if (value == 'social_preview') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SocialPreviewScreen()),
          );
        } else if (value == 'github_actions') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GitHubActionsGenerator()),
          );
        } else if (value == 'export_json') {
          final json = provider.exportToJson();
          downloadJsonFile(json, 'readme_project.json');
        } else if (value == 'import_json') {
          try {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['json'],
            );

            if (result != null) {
              String? content;
              if (result.files.first.bytes != null) {
                content = utf8.decode(result.files.first.bytes!);
              }
              if (content != null) {
                provider.importFromJson(content);
                if (context.mounted) {
                  ToastHelper.show(context, AppLocalizations.of(context)!.projectImported);
                }
              }
            }
          } catch (e) {
            if (context.mounted) {
              ToastHelper.show(context, '${AppLocalizations.of(context)!.error}: $e', isError: true);
            }
          }
        } else if (value == 'ai_settings') {
          _showAISettingsDialog(context, provider);
        } else if (value == 'generate_codebase') {
          _showGenerateFromCodebaseDialog(context, provider);
        } else if (value == 'change_language') {
          _showLanguageDialog(context, provider);
        } else if (value == 'help') {
          OnboardingHelper.restartOnboarding(
            context: context,
            componentsKey: _componentsKey,
            canvasKey: _canvasKey,
            settingsKey: _settingsKey,
            exportKey: _exportKey,
          );
        } else if (value == 'shortcuts') {
          _showKeyboardShortcutsDialog(context);
        } else if (value == 'about_dev') {
          _showDeveloperInfoDialog(context);
        } else if (value == 'about') {
          _showAboutDialog(context);
        }
      },
    );
  }

  Widget _buildDesktopBody(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              if (!_isFocusMode)
                Expanded(
                  flex: 2,
                  child: Container(
                    key: _componentsKey,
                    child: const ComponentsPanel(),
                  ),
                ),
              if (!_isFocusMode) const VerticalDivider(width: 1),
              Expanded(
                flex: 5,
                child: Container(
                  key: _canvasKey,
                  child: const EditorCanvas(),
                ),
              ),
              if (_showPreview) ...[
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 4,
                  child: Container(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[50],
                    child: Consumer<ProjectProvider>(
                      builder: (context, provider, _) {
                        final generator = MarkdownGenerator();
                        final markdown = generator.generate(provider.elements);
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: SelectableText(
                            markdown,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
              if (!_isFocusMode) const VerticalDivider(width: 1),
              if (!_isFocusMode)
                Expanded(
                  flex: 3,
                  child: Container(
                    key: _settingsKey,
                    child: const SettingsPanel(),
                  ),
                ),
            ],
          ),
        ),
        _buildStatusBar(context),
      ],
    );
  }

  Widget _buildMobileBody(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            key: _canvasKey,
            child: const EditorCanvas(),
          ),
        ),
        _buildStatusBar(context),
      ],
    );
  }

  Widget _buildStatusBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9), // Slate 900 / Slate 100
        border: Border(top: BorderSide(color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(10))),
      ),
      child: Consumer<ProjectProvider>(
        builder: (context, provider, _) {
          final elementCount = provider.elements.length;
          final wordCount = provider.elements.fold<int>(0, (sum, e) {
            if (e is HeadingElement) {
              return sum + e.text.split(' ').length;
            }
            if (e is ParagraphElement) {
              return sum + e.text.split(' ').length;
            }
            return sum;
          });

          final issues = HealthCheckService.analyze(provider.elements);
          final errorCount = issues.where((i) => i.severity == IssueSeverity.error).length;
          final warningCount = issues.where((i) => i.severity == IssueSeverity.warning).length;

          return Row(
            children: [
              Icon(Icons.widgets_outlined, size: 14, color: isDark ? Colors.white70 : Colors.black54),
              const SizedBox(width: 6),
              Text('$elementCount ${AppLocalizations.of(context)!.elements}', style: GoogleFonts.inter(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87)),
              const SizedBox(width: 24),
              Icon(Icons.text_fields, size: 14, color: isDark ? Colors.white70 : Colors.black54),
              const SizedBox(width: 6),
              Text('$wordCount ${AppLocalizations.of(context)!.words}', style: GoogleFonts.inter(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87)),
              const SizedBox(width: 24),
              if (errorCount > 0 || warningCount > 0)
                InkWell(
                  onTap: () => _showHealthCheckDialog(context, issues, provider),
                  child: Row(
                    children: [
                      if (errorCount > 0) ...[
                        const Icon(Icons.error, size: 14, color: Colors.redAccent),
                        const SizedBox(width: 6),
                        Text('$errorCount ${AppLocalizations.of(context)!.errors}', style: GoogleFonts.inter(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                      ],
                      if (warningCount > 0) ...[
                        const Icon(Icons.warning, size: 14, color: Colors.orangeAccent),
                        const SizedBox(width: 6),
                        Text('$warningCount ${AppLocalizations.of(context)!.warnings}', style: GoogleFonts.inter(fontSize: 12, color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                      ],
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    const Icon(Icons.check_circle, size: 14, color: Colors.green),
                    const SizedBox(width: 6),
                    Text(AppLocalizations.of(context)!.healthy, style: GoogleFonts.inter(fontSize: 12, color: Colors.green[700], fontWeight: FontWeight.bold)),
                  ],
                ),
              const Spacer(),
              if (_isFocusMode)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(AppLocalizations.of(context)!.focusMode, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                ),
              const SizedBox(width: 16),
              Icon(Icons.cloud_done, size: 14, color: isDark ? Colors.white54 : Colors.black45),
              const SizedBox(width: 6),
              Text(AppLocalizations.of(context)!.autoSaved, style: GoogleFonts.inter(fontSize: 12, color: isDark ? Colors.white54 : Colors.black45)),
            ],
          );
        },
      ),
    );
  }

  void _showProjectSettingsDialog(BuildContext context, ProjectProvider provider) async {
    final debouncer = Debouncer(milliseconds: 500);

    await showSafeDialog<void>(
      context,
      builder: (context) {
        // Use a block-style builder to avoid arrow/brace balance issues
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.projectSettings, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 500,
            child: DefaultTabController(
              length: 5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TabBar(
                    labelColor: Colors.blue,
                    isScrollable: true,
                    tabs: [
                      Tab(text: AppLocalizations.of(context)!.variables),
                      Tab(text: AppLocalizations.of(context)!.license),
                      const Tab(text: 'Community'),
                      Tab(text: AppLocalizations.of(context)!.colors),
                      Tab(text: AppLocalizations.of(context)!.formatting),
                    ],
                  ),
                  SizedBox(
                    height: 300,
                    child: TabBarView(
                      children: [
                        // Variables Tab
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: provider.variables.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: TextFormField(
                                  initialValue: entry.value,
                                  decoration: InputDecoration(
                                    labelText: entry.key,
                                    border: const OutlineInputBorder(),
                                  ),
                                  style: GoogleFonts.inter(),
                                  onChanged: (value) {
                                    debouncer.run(() {
                                      provider.updateVariable(entry.key, value);
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        // License Tab
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Select License for your project:', style: GoogleFonts.inter()),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                initialValue: provider.licenseType,
                                decoration: const InputDecoration(border: OutlineInputBorder()),
                                items: [
                                  DropdownMenuItem(value: 'None', child: Text('None', style: GoogleFonts.inter())),
                                  DropdownMenuItem(value: 'MIT', child: Text('MIT License', style: GoogleFonts.inter())),
                                  DropdownMenuItem(value: 'Apache 2.0', child: Text('Apache License 2.0', style: GoogleFonts.inter())),
                                  DropdownMenuItem(value: 'GPLv3', child: Text('GNU GPLv3', style: GoogleFonts.inter())),
                                  DropdownMenuItem(value: 'BSD 3-Clause', child: Text('BSD 3-Clause License', style: GoogleFonts.inter())),
                                ],
                                onChanged: (value) {
                                  if (value != null) provider.setLicenseType(value);
                                },
                              ),
                              const SizedBox(height: 16),
                              Text('A LICENSE file will be generated and included in the export.', style: GoogleFonts.inter(color: Colors.grey)),
                            ],
                          ),
                        ),

                        // Community Tab
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                SwitchListTile(
                                  title: Text('Include CONTRIBUTING.md', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                                  subtitle: Text('Adds a standard contributing guide.', style: GoogleFonts.inter(fontSize: 12)),
                                  value: provider.includeContributing,
                                  onChanged: (value) => provider.setIncludeContributing(value),
                                ),
                                const Divider(),
                                SwitchListTile(
                                  title: Text('Include SECURITY.md', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                                  subtitle: Text('Adds a security policy.', style: GoogleFonts.inter(fontSize: 12)),
                                  value: provider.includeSecurity,
                                  onChanged: (value) => provider.setIncludeSecurity(value),
                                ),
                                const Divider(),
                                SwitchListTile(
                                  title: Text('Include SUPPORT.md', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                                  subtitle: Text('Adds support information.', style: GoogleFonts.inter(fontSize: 12)),
                                  value: provider.includeSupport,
                                  onChanged: (value) => provider.setIncludeSupport(value),
                                ),
                                const Divider(),
                                SwitchListTile(
                                  title: Text('Include CODE_OF_CONDUCT.md', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                                  subtitle: Text('Adds a contributor covenant code of conduct.', style: GoogleFonts.inter(fontSize: 12)),
                                  value: provider.includeCodeOfConduct,
                                  onChanged: (value) => provider.setIncludeCodeOfConduct(value),
                                ),
                                const Divider(),
                                SwitchListTile(
                                  title: Text('Include Issue Templates', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                                  subtitle: Text('Adds GitHub issue and PR templates.', style: GoogleFonts.inter(fontSize: 12)),
                                  value: provider.includeIssueTemplates,
                                  onChanged: (value) => provider.setIncludeIssueTemplates(value),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Colors Tab
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(AppLocalizations.of(context)!.primaryColor, style: GoogleFonts.inter()),
                                subtitle: Text('#${provider.primaryColor.toARGB32().toRadixString(16).toUpperCase().substring(2)}', style: GoogleFonts.inter()),
                                trailing: CircleAvatar(backgroundColor: provider.primaryColor),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Pick Primary Color', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                                      content: SingleChildScrollView(
                                        child: ColorPicker(
                                          pickerColor: provider.primaryColor,
                                          onColorChanged: (color) => provider.setPrimaryColor(color),
                                          labelTypes: const [],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text('Done'),
                                          onPressed: () => Navigator.of(context).pop(),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                title: Text(AppLocalizations.of(context)!.secondaryColor, style: GoogleFonts.inter()),
                                subtitle: Text('#${provider.secondaryColor.toARGB32().toRadixString(16).toUpperCase().substring(2)}', style: GoogleFonts.inter()),
                                trailing: CircleAvatar(backgroundColor: provider.secondaryColor),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Pick Secondary Color', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                                      content: SingleChildScrollView(
                                        child: ColorPicker(
                                          pickerColor: provider.secondaryColor,
                                          onColorChanged: (color) => provider.setSecondaryColor(color),
                                          labelTypes: const [],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text('Done'),
                                          onPressed: () => Navigator.of(context).pop(),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        // Formatting Tab
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              SwitchListTile(
                                title: Text(AppLocalizations.of(context)!.exportHtml, style: GoogleFonts.inter()),
                                subtitle: Text('Include a formatted HTML file in the export.', style: GoogleFonts.inter()),
                                value: provider.exportHtml,
                                onChanged: (value) => provider.setExportHtml(value),
                              ),
                              const Divider(),
                              InputDecorator(
                                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.listBulletStyle, border: const OutlineInputBorder()),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: provider.listBullet,
                                    isDense: true,
                                    items: [
                                      DropdownMenuItem(value: '*', child: Text('* (Asterisk)', style: GoogleFonts.inter())),
                                      DropdownMenuItem(value: '-', child: Text('- (Dash)', style: GoogleFonts.inter())),
                                      DropdownMenuItem(value: '+', child: Text('+ (Plus)', style: GoogleFonts.inter())),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) provider.setListBullet(value);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              InputDecorator(
                                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.sectionSpacing, border: const OutlineInputBorder()),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: provider.sectionSpacing,
                                    isDense: true,
                                    items: [
                                      DropdownMenuItem(value: 0, child: Text('0 (Compact)', style: GoogleFonts.inter())),
                                      DropdownMenuItem(value: 1, child: Text('1 (Standard)', style: GoogleFonts.inter())),
                                      DropdownMenuItem(value: 2, child: Text('2 (Spacious)', style: GoogleFonts.inter())),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) provider.setSectionSpacing(value);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.close),
            ),
          ],
        );
      },
    );

    debouncer.dispose();
  }

  void _showSnapshotsDialog(BuildContext context, ProjectProvider provider) {
    showSafeDialog(
      context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.localSnapshots, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 400,
          height: 400,
          child: Column(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Create New Snapshot'), // Missing l10n key, keeping English for now or adding later if critical
                onPressed: () {
                  provider.saveSnapshot();
                  Navigator.pop(context);
                  _showSnapshotsDialog(context, provider); // Reopen to show new snapshot
                },
              ),
              const Divider(),
              Expanded(
                child: provider.snapshots.isEmpty
                    ? Center(child: Text('No snapshots saved.', style: GoogleFonts.inter())) // Missing l10n key
                    : ListView.builder(
                        itemCount: provider.snapshots.length,
                        itemBuilder: (context, index) {
                          // We don't have timestamps in the snapshot string currently,
                          // but we could parse it to show some info, or just show "Snapshot #".
                          // Since it's a stack, index 0 is latest.
                          return ListTile(
                            leading: const Icon(Icons.history),
                            title: Text('Snapshot ${provider.snapshots.length - index}', style: GoogleFonts.inter()),
                            subtitle: index == 0 ? Text('Latest', style: GoogleFonts.inter()) : null, // Missing l10n key
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.restore),
                                  tooltip: AppLocalizations.of(context)!.restore,
                                  onPressed: () {
                                    showSafeDialog(
                                      context,
                                      builder: (context) => AlertDialog(
                                        title: Text('${AppLocalizations.of(context)!.restore} Snapshot?', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                                        content: Text('Current work will be replaced.', style: GoogleFonts.inter()),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text(AppLocalizations.of(context)!.cancel),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context); // close confirm
                                              Navigator.pop(context); // close list
                                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                                provider.restoreSnapshot(index);
                                              });
                                            },
                                            child: Text(AppLocalizations.of(context)!.restore),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  tooltip: AppLocalizations.of(context)!.delete,
                                  onPressed: () {
                                    Navigator.pop(context);
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      provider.deleteSnapshot(index);
                                      showSafeDialog(context, builder: (c) => const AlertDialog(
                                        title: Text('Snapshot deleted.'),
                                        content: Text('Snapshot deleted.'),
                                        actions: [TextButton(onPressed: null, child: Text('Close'))], // Simplified for brevity as this was inside a callback
                                      ));
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _printReadme(BuildContext context, ProjectProvider provider) async {
    final markdownGenerator = MarkdownGenerator();
    final readmeContent = markdownGenerator.generate(
      provider.elements,
      variables: provider.variables,
      listBullet: provider.listBullet,
      sectionSpacing: provider.sectionSpacing,
    );

    final htmlContent = md.markdownToHtml(
      readmeContent,
      extensionSet: md.ExtensionSet.gitHubWeb,
    );

    final fullHtml = '''
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
body { font-family: sans-serif; line-height: 1.5; padding: 20px; }
h1, h2, h3 { margin-top: 24px; margin-bottom: 16px; font-weight: 600; }
h1 { font-size: 2em; border-bottom: 1px solid #eaecef; padding-bottom: .3em; }
h2 { font-size: 1.5em; border-bottom: 1px solid #eaecef; padding-bottom: .3em; }
code { background-color: #f6f8fa; padding: .2em .4em; border-radius: 6px; font-family: monospace; }
pre { background-color: #f6f8fa; padding: 16px; border-radius: 6px; overflow: auto; }
pre code { background-color: transparent; padding: 0; }
blockquote { border-left: .25em solid #d0d7de; color: #656d76; padding: 0 1em; margin: 0; }
table { border-spacing: 0; border-collapse: collapse; width: 100%; }
table th, table td { padding: 6px 13px; border: 1px solid #d0d7de; }
table tr:nth-child(2n) { background-color: #f6f8fa; }
img { max-width: 100%; }
</style>
</head>
<body>
$htmlContent
</body>
</html>
''';

    await Printing.layoutPdf(
      // ignore: deprecated_member_use
      onLayout: (PdfPageFormat format) async => await Printing.convertHtml(
        format: format,
        html: fullHtml,
      ),
    );
  }

  void _showSaveToLibraryDialog(BuildContext context, ProjectProvider provider) {
    final libraryProvider = Provider.of<LibraryProvider>(context, listen: false);
    final nameController = TextEditingController(text: provider.variables['PROJECT_NAME'] ?? 'My Project');
    final descController = TextEditingController();
    final tagsController = TextEditingController();

    showSafeDialog(
      context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.saveToLibrary, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.projectName),
                style: GoogleFonts.inter(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.description),
                style: GoogleFonts.inter(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tagsController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.tags),
                style: GoogleFonts.inter(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final tags = tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
              libraryProvider.saveProject(
                name: nameController.text,
                description: descController.text,
                tags: tags,
                jsonContent: provider.exportToJson(),
              );
              Navigator.pop(context);
              ToastHelper.show(context, AppLocalizations.of(context)!.projectSaved);
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  void _showHealthCheckDialog(BuildContext context, List<HealthIssue> issues, ProjectProvider provider) {
    showSafeDialog(
      context,
      builder: (context) => AlertDialog(
        title: Text('Health Check', style: GoogleFonts.inter(fontWeight: FontWeight.bold)), // Missing l10n key
        content: SizedBox(
          width: 400,
          height: 300,
          child: ListView.builder(
            itemCount: issues.length,
            itemBuilder: (context, index) {
              final issue = issues[index];
              return ListTile(
                leading: Icon(
                  issue.severity == IssueSeverity.error ? Icons.error : (issue.severity == IssueSeverity.warning ? Icons.warning : Icons.info),
                  color: issue.severity == IssueSeverity.error ? Colors.red : (issue.severity == IssueSeverity.warning ? Colors.orange : Colors.blue),
                ),
                title: Text(issue.message, style: GoogleFonts.inter(fontSize: 14)),
                trailing: issue.elementId != null
                    ? IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          provider.selectElement(issue.elementId!);
                          Navigator.pop(context);
                        },
                      )
                    : null,
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.close)),
        ],
      ),
    );
  }

  void _showImportMarkdownDialog(BuildContext context, ProjectProvider provider) {
    final textController = TextEditingController();
    final urlController = TextEditingController();

    showSafeDialog(
      context,
      builder: (context) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.importMarkdown, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 600,
                height: 450,
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        labelColor: Colors.blue,
                        tabs: [
                          Tab(text: 'Text / File'), // Missing l10n key
                          Tab(text: 'URL (GitHub/Pastebin)'), // Missing l10n key
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Tab 1: Text / File
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text('Paste your Markdown content below or pick a file.', style: GoogleFonts.inter()), // Missing l10n key
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: TextField(
                                      controller: textController,
                                      maxLines: null,
                                      expands: true,
                                      textAlignVertical: TextAlignVertical.top,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: '# My Project\n\nDescription...',
                                      ),
                                      style: GoogleFonts.firaCode(fontSize: 13),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.upload_file),
                                    label: const Text('Pick Markdown File'), // Missing l10n key
                                    onPressed: () async {
                                      final result = await FilePicker.platform.pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: ['md', 'txt'],
                                        withData: true,
                                      );
                                      if (result != null && result.files.isNotEmpty) {
                                        final bytes = result.files.first.bytes;
                                        if (bytes != null) {
                                          textController.text = utf8.decode(bytes);
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            // Tab 2: URL
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Enter a raw URL from GitHub or Pastebin.', style: GoogleFonts.inter()), // Missing l10n key
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: urlController,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      hintText: 'https://raw.githubusercontent.com/...',
                                      labelText: AppLocalizations.of(context)!.repoUrl, // Reusing repoUrl or similar if available, otherwise keep English
                                      prefixIcon: const Icon(Icons.link),
                                    ),
                                    style: GoogleFonts.inter(),
                                  ),
                                  const SizedBox(height: 16),
                                  if (isLoading)
                                    const CircularProgressIndicator()
                                  else
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.cloud_download),
                                      label: const Text('Fetch Content'), // Missing l10n key
                                      onPressed: () async {
                                        if (urlController.text.isEmpty) return;
                                        setState(() => isLoading = true);
                                        try {
                                          final url = urlController.text;
                                          // Basic check for github blob -> raw
                                          String fetchUrl = url;
                                          if (url.contains('github.com') && url.contains('/blob/')) {
                                            fetchUrl = url.replaceFirst('/blob/', '/raw/');
                                          }

                                          final response = await http.get(Uri.parse(fetchUrl));
                                          if (response.statusCode == 200) {
                                            textController.text = response.body;
                                            if (context.mounted) {
                                              ToastHelper.show(context, AppLocalizations.of(context)!.contentFetched);
                                            }
                                          } else {
                                            if (context.mounted) {
                                              ToastHelper.show(context, '${AppLocalizations.of(context)!.fetchFailed}: ${response.statusCode}', isError: true);
                                            }
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ToastHelper.show(context, '${AppLocalizations.of(context)!.error}: $e', isError: true);
                                          }
                                        } finally {
                                          if (context.mounted) {
                                            setState(() => isLoading = false);
                                          }
                                        }
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (textController.text.isNotEmpty) {
                      final markdownText = textController.text;
                      Navigator.pop(context);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        provider.importMarkdown(markdownText);
                        ToastHelper.show(context, AppLocalizations.of(context)!.projectImported);
                      });
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.import),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showKeyboardShortcutsDialog(BuildContext context) {
    showSafeDialog(
      context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.keyboardShortcuts, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${AppLocalizations.of(context)!.commonShortcuts}:', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildShortcutRow(context, AppLocalizations.of(context)!.newProject, 'Ctrl + N', '⌘ + N'),
              _buildShortcutRow(context, AppLocalizations.of(context)!.openProject, 'Ctrl + O', '⌘ + O'),
              _buildShortcutRow(context, AppLocalizations.of(context)!.saveProject, 'Ctrl + S', '⌘ + S'),
              _buildShortcutRow(context, AppLocalizations.of(context)!.exportProject, 'Ctrl + E', '⌘ + E'),
              _buildShortcutRow(context, AppLocalizations.of(context)!.print, 'Ctrl + P', '⌘ + P'),
              _buildShortcutRow(context, AppLocalizations.of(context)!.undo, 'Ctrl + Z', '⌘ + Z'),
              _buildShortcutRow(context, AppLocalizations.of(context)!.redo, 'Ctrl + Y', '⌘ + Y'),
              _buildShortcutRow(context, AppLocalizations.of(context)!.focusMode, 'F11', 'F11'),
              _buildShortcutRow(context, AppLocalizations.of(context)!.showPreview, 'Ctrl + Shift + H', '⌘ + Shift + H'),
              _buildShortcutRow(context, AppLocalizations.of(context)!.toggleGrid, 'Ctrl + G', '⌘ + G'),
              _buildShortcutRow(context, AppLocalizations.of(context)!.toggleTheme, 'Ctrl + T', '⌘ + T'),
              _buildShortcutRow(context, AppLocalizations.of(context)!.openSettings, 'Ctrl + ,', '⌘ + ,'),
              _buildShortcutRow(context, AppLocalizations.of(context)!.help, 'F1', 'F1'),
              const SizedBox(height: 16),
              Text('${AppLocalizations.of(context)!.elementShortcuts}:', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildShortcutRow(context, AppLocalizations.of(context)!.addHeading, 'Ctrl + Alt + 1', '⌘ + Option + 1'),
              _buildShortcutRow(context, AppLocalizations.of(context)!.addSubheading, 'Ctrl + Alt + 2', '⌘ + Option + 2'),
              _buildShortcutRow(context, AppLocalizations.of(context)!.addParagraph, 'Ctrl + Alt + 3', '⌘ + Option + 3'),
              _buildShortcutRow(context, AppLocalizations.of(context)!.addImage, 'Ctrl + Alt + I', '⌘ + Option + I'),
              _buildShortcutRow(context, AppLocalizations.of(context)!.addTable, 'Ctrl + Alt + T', '⌘ + Option + T'),
              _buildShortcutRow(context, AppLocalizations.of(context)!.addList, 'Ctrl + Alt + L', '⌘ + Option + L'),
              _buildShortcutRow(context, AppLocalizations.of(context)!.addQuote, 'Ctrl + Alt + Q', '⌘ + Option + Q'),
              _buildShortcutRow(context, AppLocalizations.of(context)!.addLink, 'Ctrl + Alt + K', '⌘ + Option + K'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutRow(BuildContext context, String label, String windowsKey, String macKey) {
    final isMac = Theme.of(context).platform == TargetPlatform.macOS;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              isMac ? macKey : windowsKey,
              style: GoogleFonts.firaCode(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeveloperInfoDialog(BuildContext context) {
    showSafeDialog(
      context,
      builder: (context) => const DeveloperInfoDialog(),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Readme Creator',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.description, size: 48),
      children: [
        Text(AppLocalizations.of(context)!.aboutDescription),
        const SizedBox(height: 16),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.developer_mode),
          title: const Text('Development By Mohamed Anwar'),
          onTap: () {
            Navigator.pop(context);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showDeveloperInfoDialog(context);
            });
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => launchUrl(Uri.parse('https://github.com/mhmdwaelanwr/Readme-Creator.git')),
          icon: const Icon(Icons.code),
          label: const Text('View on GitHub'),
          style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
        ),
      ],
    );
  }

  void _showAISettingsDialog(BuildContext context, ProjectProvider provider) {
    final apiKeyController = TextEditingController(text: provider.geminiApiKey);
    final githubTokenController = TextEditingController(text: provider.githubToken);
    bool isObscured = true;
    bool isGithubObscured = true;

    showSafeDialog(
      context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.aiSettings, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gemini AI', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(AppLocalizations.of(context)!.enterGeminiKey, style: GoogleFonts.inter(fontSize: 12)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: apiKeyController,
                        obscureText: isObscured,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.geminiApiKey,
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(isObscured ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => isObscured = !isObscured),
                          ),
                        ),
                        style: GoogleFonts.inter(),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () {
                          launchUrl(Uri.parse('https://aistudio.google.com/app/apikey'));
                        },
                        child: Text(
                          AppLocalizations.of(context)!.getApiKey,
                          style: GoogleFonts.inter(color: Colors.blue, decoration: TextDecoration.underline, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('GitHub Integration', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(AppLocalizations.of(context)!.enterGithubToken, style: GoogleFonts.inter(fontSize: 12)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: githubTokenController,
                        obscureText: isGithubObscured,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.githubToken,
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(isGithubObscured ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => isGithubObscured = !isGithubObscured),
                          ),
                        ),
                        style: GoogleFonts.inter(),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () {
                          launchUrl(Uri.parse('https://github.com/settings/tokens'));
                        },
                        child: Text(
                          AppLocalizations.of(context)!.generateToken,
                          style: GoogleFonts.inter(color: Colors.blue, decoration: TextDecoration.underline, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final key = apiKeyController.text.trim();
                    final token = githubTokenController.text.trim();
                    Navigator.pop(context);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      provider.setGeminiApiKey(key);
                      provider.setGitHubToken(token);
                      ToastHelper.show(context, AppLocalizations.of(context)!.settingsSaved);
                    });
                  },
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showGenerateFromCodebaseDialog(BuildContext context, ProjectProvider provider) {
    final repoUrlController = TextEditingController();

    showSafeDialog<void>(
      context,
      builder: (context) {
        bool isLoading = false;
        String statusMessage = '';

        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> handleLocalFolder() async {
              final result = await FilePicker.platform.getDirectoryPath();
              if (result == null) return;

              setState(() {
                isLoading = true;
                statusMessage = AppLocalizations.of(context)!.scanLocalFolder;
              });

              try {
                final codeContext = await CodebaseScannerService.scanDirectory(result);
                if (codeContext.isEmpty) throw Exception('No suitable source code found.');

                setState(() => statusMessage = AppLocalizations.of(context)!.analyzingAI);
                final apiKey = provider.geminiApiKey;
                final markdown = await AIService.generateReadmeFromCodebase(codeContext, apiKey: apiKey);

                if (markdown.startsWith('# Error')) throw Exception(markdown);

                if (context.mounted) {
                  Navigator.pop(context);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    provider.importMarkdown(markdown);
                    ToastHelper.show(context, AppLocalizations.of(context)!.readmeGenerated);
                  });
                }
              } catch (e) {
                if (context.mounted) {
                  setState(() {
                    isLoading = false;
                    statusMessage = '${AppLocalizations.of(context)!.error}: $e';
                  });
                  ToastHelper.show(context, '${AppLocalizations.of(context)!.error}: $e', isError: true);
                }
              }
            }

            Future<void> handleGithubRepo() async {
              final url = repoUrlController.text.trim();
              if (url.isEmpty) return;

              setState(() {
                isLoading = true;
                statusMessage = AppLocalizations.of(context)!.fetchingRepo;
              });

              try {
                final scanner = GitHubScannerService();
                final token = provider.githubToken;
                final codeContext = await scanner.scanRepo(url, token: token);

                if (codeContext.isEmpty) throw Exception('No suitable source code found or repo is empty.');

                setState(() => statusMessage = AppLocalizations.of(context)!.analyzingAI);
                final apiKey = provider.geminiApiKey;
                final markdown = await AIService.generateReadmeFromCodebase(codeContext, apiKey: apiKey);

                if (markdown.startsWith('# Error')) throw Exception(markdown);

                if (context.mounted) {
                  Navigator.pop(context);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    provider.importMarkdown(markdown);
                    ToastHelper.show(context, AppLocalizations.of(context)!.readmeGenerated);
                  });
                }
              } catch (e) {
                if (context.mounted) {
                  setState(() {
                    isLoading = false;
                    statusMessage = '${AppLocalizations.of(context)!.error}: $e';
                  });
                  ToastHelper.show(context, '${AppLocalizations.of(context)!.error}: $e', isError: true);
                }
              }
            }

            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.generateFromCodebase, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 520,
                height: 360,
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const SizedBox(height: 6),
                      TabBar(
                        labelColor: Colors.blue,
                        tabs: [
                          Tab(text: AppLocalizations.of(context)!.localFolder),
                          Tab(text: AppLocalizations.of(context)!.githubRepo),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: isLoading
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CircularProgressIndicator(),
                                    const SizedBox(height: 12),
                                    Text(statusMessage, style: GoogleFonts.inter(fontStyle: FontStyle.italic), textAlign: TextAlign.center),
                                  ],
                                ),
                              )
                            : TabBarView(
                                children: [
                                  // Local folder tab
                                  Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(AppLocalizations.of(context)!.scanLocalFolder, textAlign: TextAlign.center, style: GoogleFonts.inter()),
                                        const SizedBox(height: 12),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.folder_open),
                                          label: Text(AppLocalizations.of(context)!.pickProjectFolder),
                                          onPressed: handleLocalFolder,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // GitHub repo tab
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(AppLocalizations.of(context)!.scanGithubRepo, style: GoogleFonts.inter(), textAlign: TextAlign.center),
                                        const SizedBox(height: 12),
                                        TextField(
                                          controller: repoUrlController,
                                          decoration: InputDecoration(
                                            labelText: AppLocalizations.of(context)!.repoUrl,
                                            hintText: 'https://github.com/username/repo',
                                            border: const OutlineInputBorder(),
                                            prefixIcon: const Icon(Icons.link),
                                          ),
                                          style: GoogleFonts.inter(),
                                        ),
                                        const SizedBox(height: 12),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.cloud_download),
                                          label: Text(AppLocalizations.of(context)!.scanAndGenerate),
                                          onPressed: handleGithubRepo,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                if (!isLoading)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context)!.close),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, ProjectProvider provider) {
    final languages = [
      {'code': 'en', 'name': 'English', 'native': 'English'},
      {'code': 'ar', 'name': 'Arabic', 'native': 'العربية'},
      {'code': 'de', 'name': 'German', 'native': 'Deutsch'},
      {'code': 'es', 'name': 'Spanish', 'native': 'Español'},
      {'code': 'fr', 'name': 'French', 'native': 'Français'},
      {'code': 'hi', 'name': 'Hindi', 'native': 'हिन्दी'},
      {'code': 'ja', 'name': 'Japanese', 'native': '日本語'},
      {'code': 'pt', 'name': 'Portuguese', 'native': 'Português'},
      {'code': 'ru', 'name': 'Russian', 'native': 'Русский'},
      {'code': 'zh', 'name': 'Chinese', 'native': '中文'},
    ];

    showSafeDialog<void>(
      context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.changeLanguage, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 360,
            height: 420,
            child: ListView(
              children: [
                ListTile(
                  title: Text(AppLocalizations.of(context)!.systemDefault),
                  onTap: () {
                    Navigator.pop(context);
                    WidgetsBinding.instance.addPostFrameCallback((_) => provider.setLocale(null));
                  },
                ),
                const Divider(),
                ...languages.map((lang) => ListTile(
                  title: Text(lang['name']!),
                  subtitle: Text(lang['native']!),
                  onTap: () {
                    Navigator.pop(context);
                    WidgetsBinding.instance.addPostFrameCallback((_) => provider.setLocale(Locale(lang['code']!)));
                  },
                )),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.close)),
          ],
        );
      },
    );
  }
}
