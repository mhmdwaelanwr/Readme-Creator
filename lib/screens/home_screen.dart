import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:readme_creator/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:markdown/markdown.dart' as md;

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/readme_element.dart';
import '../widgets/components_panel.dart';
import '../widgets/editor_canvas.dart';
import '../widgets/settings_panel.dart';
import '../providers/project_provider.dart';
import '../services/preferences_service.dart';
import '../utils/templates.dart';
import '../utils/project_exporter.dart';
import '../utils/downloader.dart';
import '../utils/onboarding_helper.dart';
import 'projects_library_screen.dart';
import 'social_preview_screen.dart';
import 'github_actions_generator.dart';
import '../services/health_check_service.dart';
import '../services/auth_service.dart';

import '../utils/toast_helper.dart';

import '../widgets/developer_info_dialog.dart';
import '../utils/dialog_helper.dart';

import 'onboarding_screen.dart';
import 'gallery_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/element_renderer.dart';
import 'funding_generator_screen.dart';
import '../generator/markdown_generator.dart';
import '../widgets/dialogs/project_settings_dialog.dart';
import '../widgets/dialogs/import_markdown_dialog.dart';
import '../widgets/dialogs/generate_codebase_dialog.dart';
import '../widgets/dialogs/publish_to_github_dialog.dart';
import '../widgets/dialogs/save_to_library_dialog.dart';
import '../widgets/dialogs/snapshots_dialog.dart';
import '../widgets/dialogs/health_check_dialog.dart';
import '../widgets/dialogs/keyboard_shortcuts_dialog.dart';
import '../widgets/dialogs/ai_settings_dialog.dart';
import '../widgets/dialogs/extra_files_dialog.dart';
import '../widgets/dialogs/language_dialog.dart';
import '../widgets/dialogs/confirm_dialog.dart';
import '../widgets/dialogs/about_app_dialog.dart';
import '../widgets/dialogs/login_dialog.dart';
import 'admin_dashboard_screen.dart';

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
  final AuthService _authService = AuthService();
  bool _showPreview = false;
  bool _isFocusMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = PreferencesService();
      final hasSeenWizard = await prefs.loadBool(PreferencesService.keyHasSeenSetupWizard) ?? false;

      if (!hasSeenWizard && mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const OnboardingScreen(),
        );
        await prefs.saveBool(PreferencesService.keyHasSeenSetupWizard, true);
      }

      if (mounted) {
        _focusNode.requestFocus();
        OnboardingHelper.showOnboarding(
          context: context,
          componentsKey: _componentsKey,
          canvasKey: _canvasKey,
          settingsKey: _settingsKey,
          exportKey: _exportKey,
        );
      }
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
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true): () => provider.undo(),
        const SingleActivator(LogicalKeyboardKey.keyY, control: true): () => provider.redo(),
        const SingleActivator(LogicalKeyboardKey.f11): () => setState(() => _isFocusMode = !_isFocusMode),
        const SingleActivator(LogicalKeyboardKey.keyH, control: true, shift: true): () => setState(() => _showPreview = !_showPreview),
        const SingleActivator(LogicalKeyboardKey.keyG, control: true): () => provider.toggleGrid(),
        const SingleActivator(LogicalKeyboardKey.keyT, control: true): () => provider.toggleTheme(),
        const SingleActivator(LogicalKeyboardKey.comma, control: true): () => _showProjectSettingsDialog(context, provider),
        const SingleActivator(LogicalKeyboardKey.f1): () => OnboardingHelper.restartOnboarding(
            context: context,
            componentsKey: _componentsKey,
            canvasKey: _canvasKey,
            settingsKey: _settingsKey,
            exportKey: _exportKey,
          ),
        const SingleActivator(LogicalKeyboardKey.digit1, control: true, alt: true): () => provider.addElement(ReadmeElementType.heading),
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
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Row(
              children: [
                Icon(Icons.description, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                const Flexible(
                  child: Text(
                    'Markdown Creator',
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
          body: Stack(
            children: [
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary.withAlpha(20),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -100,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary.withAlpha(13),
                  ),
                  child: BackdropFilter(
                     filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                     child: Container(color: Colors.transparent),
                  ),
                ),
              ),
              isDesktop ? _buildDesktopBody(context) : _buildMobileBody(context),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDesktopActions(BuildContext context) {
    return [
      StreamBuilder(
        stream: _authService.user,
        builder: (context, snapshot) {
          final user = snapshot.data;
          final isAdmin = user?.email == AuthService.adminEmail;

          return Row(
            children: [
              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.dashboard_customize_rounded, color: Colors.purpleAccent),
                  tooltip: 'Admin Dashboard',
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen())),
                ),
              if (user == null)
                TextButton.icon(
                  onPressed: () => _showLoginDialog(context),
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Login'),
                )
              else
                PopupMenuButton<int>(
                  offset: const Offset(0, 40),
                  onSelected: (val) {
                    if (val == 1) _authService.signOut();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: CircleAvatar(radius: 14, backgroundImage: NetworkImage(user.photoURL ?? '')),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(enabled: false, child: Text(user.displayName ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold))),
                    const PopupMenuDivider(),
                    const PopupMenuItem(value: 1, child: Text('Logout')),
                  ],
                ),
            ],
          );
        },
      ),
      Consumer<ProjectProvider>(
        builder: (context, provider, child) {
          return Row(
            children: [
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
                    builder: (context) => ConfirmDialog(
                      title: 'Load ${template.name}?',
                      content: 'This will replace your current workspace.',
                      confirmText: 'Load',
                      onConfirm: () => provider.loadTemplate(template),
                    ),
                  );
                },
                itemBuilder: (context) => provider.allTemplates.map((t) {
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: const Offset(0, 48),
      itemBuilder: (context) => [
        _buildMenuHeader('Project & Files'),
        _buildMenuItem(context, 'save_library', Icons.save_alt, AppLocalizations.of(context)!.saveToLibrary, color: Colors.blue),
        _buildMenuItem(context, 'snapshots', Icons.history, AppLocalizations.of(context)!.localSnapshots, color: Colors.blue),
        _buildMenuItem(context, 'import_markdown', Icons.file_upload, AppLocalizations.of(context)!.importMarkdown, color: Colors.blue),
        _buildMenuItem(context, 'export_json', Icons.javascript, AppLocalizations.of(context)!.exportProjectJson, color: Colors.blue),
        _buildMenuItem(context, 'import_json', Icons.data_object, AppLocalizations.of(context)!.importProjectJson, color: Colors.blue),
        _buildMenuItem(context, 'clear_workspace', Icons.delete_forever, AppLocalizations.of(context)!.clearWorkspace, color: Colors.red, isDestructive: true),

        const PopupMenuDivider(),
        _buildMenuHeader('Tools & Generators'),
        _buildMenuItem(context, 'gallery', Icons.collections, 'Showcase Gallery', color: Colors.orange),
        _buildMenuItem(context, 'social_preview', Icons.image, AppLocalizations.of(context)!.socialPreviewDesigner, color: Colors.orange),
        _buildMenuItem(context, 'github_actions', Icons.build, AppLocalizations.of(context)!.githubActionsGenerator, color: Colors.orange),
        _buildMenuItem(context, 'funding', Icons.volunteer_activism, 'Funding Generator', color: Colors.pink),
        _buildMenuItem(context, 'extra_files', Icons.library_add, 'Generate Extra Files', color: Colors.deepOrange),

        const PopupMenuDivider(),
        _buildMenuHeader('AI Features'),
        _buildMenuItem(context, 'ai_settings', Icons.psychology, AppLocalizations.of(context)!.aiSettings, color: Colors.purple),
        _buildMenuItem(context, 'generate_codebase', Icons.auto_awesome, AppLocalizations.of(context)!.generateFromCodebase, color: Colors.purple),

        const PopupMenuDivider(),
        _buildMenuHeader('Publish'),
        _buildMenuItem(context, 'publish_github', Icons.cloud_upload, 'Publish to GitHub', color: Colors.teal),

        const PopupMenuDivider(),
        _buildMenuHeader('App'),
        _buildMenuItem(context, 'change_language', Icons.language, AppLocalizations.of(context)!.changeLanguage, color: Colors.grey),
        _buildMenuItem(context, 'shortcuts', Icons.keyboard, AppLocalizations.of(context)!.keyboardShortcuts, color: Colors.grey),
        _buildMenuItem(context, 'about_dev', Icons.person, AppLocalizations.of(context)!.aboutDeveloper, color: Colors.grey),
        _buildMenuItem(context, 'about', Icons.info_outline, AppLocalizations.of(context)!.aboutApp, color: Colors.grey),
      ],
      onSelected: (value) async {
        final provider = Provider.of<ProjectProvider>(context, listen: false);
        if (value == 'save_library') {
          _showSaveToLibraryDialog(context, provider);
        } else if (value == 'gallery') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GalleryScreen()),
          );
        } else if (value == 'snapshots') {
          _showSnapshotsDialog(context, provider);
        } else if (value == 'clear_workspace') {
          showSafeDialog(
            context,
            builder: (context) => ConfirmDialog(
              title: 'Clear Workspace?',
              content: 'This will remove all elements. This action cannot be undone (unless you have a snapshot).',
              confirmText: 'Clear',
              isDestructive: true,
              onConfirm: () => provider.clearElements(),
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
        } else if (value == 'funding') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const FundingGeneratorScreen()));
        } else if (value == 'publish_github') {
          _showPublishToGitHubDialog(context, provider);
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
        } else if (value == 'extra_files') {
          _showExtraFilesDialog(context, provider);
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
          _showAboutAppDialog(context);
        }
      },
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    BuildContext context,
    String value,
    IconData icon,
    String text,
    {Color? color, bool isDestructive = false}
  ) {
    final themeColor = color ?? Theme.of(context).iconTheme.color;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (themeColor ?? Colors.grey).withAlpha(isDark ? 50 : 30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: themeColor, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.inter(
              color: isDestructive ? Colors.red : null,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildMenuHeader(String title) {
    return PopupMenuItem<String>(
      enabled: false,
      height: 32,
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
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
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0D1117) : Colors.white,
                    child: Consumer<ProjectProvider>(
                      builder: (context, provider, _) {
                        final generator = MarkdownGenerator();
                        final markdown = generator.generate(
                          provider.elements,
                          variables: provider.variables,
                          listBullet: provider.listBullet,
                          sectionSpacing: provider.sectionSpacing,
                          targetLanguage: provider.targetLanguage,
                        );

                        final isDark = Theme.of(context).brightness == Brightness.dark;

                        return Markdown(
                          data: markdown,
                          selectable: true,
                          padding: const EdgeInsets.all(32),
                          builders: {
                             'img': BadgeImageBuilder(builder: (url, {width, height}) {
                                if (url.contains('img.shields.io') || url.contains('contrib.rocks')) {
                                  return SvgPicture.network(
                                    url,
                                    width: width,
                                    height: height,
                                    placeholderBuilder: (_) => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                                  );
                                }
                                return Image.network(url, width: width, height: height, errorBuilder: (ctx, err, stack) => const SizedBox());
                             }),
                          },
                          extensionSet: md.ExtensionSet.gitHubWeb,
                          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                            p: GoogleFonts.inter(fontSize: 16, height: 1.5, color: isDark ? const Color(0xFFC9D1D9) : const Color(0xFF24292F)),
                            h1: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w600, height: 1.25, color: isDark ? const Color(0xFFC9D1D9) : const Color(0xFF24292F)),
                            h1Padding: const EdgeInsets.only(bottom: 8),
                            h2: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, height: 1.25, color: isDark ? const Color(0xFFC9D1D9) : const Color(0xFF24292F)),
                            h2Padding: const EdgeInsets.only(bottom: 8, top: 24),
                            h3: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, height: 1.25, color: isDark ? const Color(0xFFC9D1D9) : const Color(0xFF24292F)),
                            h3Padding: const EdgeInsets.only(bottom: 8, top: 24),
                            h4: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, height: 1.25, color: isDark ? const Color(0xFFC9D1D9) : const Color(0xFF24292F)),
                            h5: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, height: 1.25, color: isDark ? const Color(0xFFC9D1D9) : const Color(0xFF24292F)),
                            h6: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, height: 1.25, color: isDark ? const Color(0xFF777B83) : const Color(0xFF57606A)),
                            blockquote: GoogleFonts.inter(fontSize: 16, color: isDark ? const Color(0xFF8B949E) : const Color(0xFF57606A)),
                            blockquoteDecoration: BoxDecoration(
                              border: Border(left: BorderSide(color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE), width: 4)),
                              color: Colors.transparent,
                            ),
                            code: GoogleFonts.firaCode(fontSize: 14, backgroundColor: isDark ? const Color.fromRGBO(110, 118, 129, 0.4) : const Color.fromRGBO(175, 184, 193, 0.2)),
                            codeblockDecoration: BoxDecoration(
                              color: isDark ? const Color(0xFF161B22) : const Color(0xFFF6F8FA),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            horizontalRuleDecoration: BoxDecoration(
                              border: Border(top: BorderSide(color: isDark ? const Color(0xFF30363D) : const Color(0xFFD8DEE4), width: 1)),
                            ),
                          ),
                          onTapLink: (text, href, title) {
                            if (href != null) {
                              launchUrl(Uri.parse(href));
                            }
                          },
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
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
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

  void _showProjectSettingsDialog(BuildContext context, ProjectProvider provider) {
    showSafeDialog(
      context,
      builder: (context) => const ProjectSettingsDialog(),
    );
  }

  void _showSnapshotsDialog(BuildContext context, ProjectProvider provider) {
    showSafeDialog(
      context,
      builder: (context) => const SnapshotsDialog(),
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
      onLayout: (PdfPageFormat format) async => await Printing.convertHtml(
        format: format,
        html: fullHtml,
      ),
    );
  }

  void _showSaveToLibraryDialog(BuildContext context, ProjectProvider provider) {
    showSafeDialog(
      context,
      builder: (context) => const SaveToLibraryDialog(),
    );
  }

  void _showHealthCheckDialog(BuildContext context, List<HealthIssue> issues, ProjectProvider provider) {
    showSafeDialog(
      context,
      builder: (context) => HealthCheckDialog(issues: issues, provider: provider),
    );
  }

  void _showImportMarkdownDialog(BuildContext context, ProjectProvider provider) {
    showSafeDialog(
      context,
      builder: (context) => const ImportMarkdownDialog(),
    );
  }

  void _showKeyboardShortcutsDialog(BuildContext context) {
    showSafeDialog(
      context,
      builder: (context) => const KeyboardShortcutsDialog(),
    );
  }

  void _showDeveloperInfoDialog(BuildContext context) {
    showSafeDialog(
      context,
      builder: (context) => const DeveloperInfoDialog(),
    );
  }

  void _showAboutAppDialog(BuildContext context) {
    showSafeDialog(
      context,
      builder: (context) => const AboutAppDialog(),
    );
  }

  void _showLoginDialog(BuildContext context) {
    showSafeDialog(
      context,
      builder: (context) => const LoginDialog(),
    );
  }

  void _showAISettingsDialog(BuildContext context, ProjectProvider provider) {
    showSafeDialog(
      context,
      builder: (context) => const AISettingsDialog(),
    );
  }

  void _showPublishToGitHubDialog(BuildContext context, ProjectProvider provider) {
    showSafeDialog(
      context,
      builder: (context) => const PublishToGitHubDialog(),
    );
  }

  void _showGenerateFromCodebaseDialog(BuildContext context, ProjectProvider provider) {
    showSafeDialog(
      context,
      builder: (context) => const GenerateCodebaseDialog(),
    );
  }

  void _showExtraFilesDialog(BuildContext context, ProjectProvider provider) {
    showSafeDialog(
      context,
      builder: (context) => const ExtraFilesDialog(),
    );
  }

  void _showLanguageDialog(BuildContext context, ProjectProvider provider) {
    showSafeDialog(
      context,
      builder: (context) => const LanguageDialog(),
    );
  }
}
