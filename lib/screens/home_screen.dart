import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:markdown_creator/l10n/app_localizations.dart';
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
import '../services/ai_service.dart';

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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _authService = AuthService();
  bool _showPreview = false;
  bool _isFocusMode = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation = CurvedAnimation(parent: _entranceController, curve: Curves.easeIn);
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1200;
    final provider = Provider.of<ProjectProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        appBar: _buildModernAppBar(context, isDesktop, provider),
        drawer: isDesktop ? null : const Drawer(child: ComponentsPanel()),
        endDrawer: isDesktop ? null : const Drawer(child: SettingsPanel()),
        body: Stack(
          children: [
            _buildBackgroundEffects(context, isDark),
            Column(
              children: [
                const SizedBox(height: 70), 
                Expanded(
                  child: Row(
                    children: [
                      if (isDesktop && !_isFocusMode) 
                        const Expanded(flex: 2, child: ComponentsPanel()),
                      
                      if (isDesktop && !_isFocusMode) VerticalDivider(width: 1, color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
                      
                      Expanded(
                        flex: 6,
                        child: const EditorCanvas(),
                      ),
                      
                      if (_showPreview && isDesktop) ...[
                        VerticalDivider(width: 1, color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
                        Expanded(
                          flex: 4,
                          child: _buildLiveMarkdownPreview(context, provider, isDark),
                        ),
                      ],
                      
                      if (isDesktop && !_isFocusMode) VerticalDivider(width: 1, color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
                      
                      if (isDesktop && !_isFocusMode) 
                        const Expanded(flex: 3, child: SettingsPanel()),
                    ],
                  ),
                ),
                _buildModernStatusBar(context, provider, isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context, bool isDesktop, ProjectProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(color: (isDark ? Colors.black : Colors.white).withOpacity(0.7)),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.description_rounded, color: Colors.blueAccent, size: 24),
          const SizedBox(width: 10),
          Text('Markdown Creator', style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 17)),
        ],
      ),
      actions: [
        if (isDesktop) ..._buildFullDesktopActions(context, provider),
        if (!isDesktop) ...[
          IconButton(icon: const Icon(Icons.tune_rounded), onPressed: () => _scaffoldKey.currentState?.openEndDrawer()),
          _buildMoreOptionsButton(context),
        ]
      ],
    );
  }

  List<Widget> _buildFullDesktopActions(BuildContext context, ProjectProvider provider) {
    return [
      _appBarIconButton(Icons.undo_rounded, 'Undo', provider.undo),
      _appBarIconButton(Icons.redo_rounded, 'Redo', provider.redo),
      _divider(),
      _appBarIconButton(Icons.desktop_mac, 'Desktop', () => provider.setDeviceMode(DeviceMode.desktop), isActive: provider.deviceMode == DeviceMode.desktop),
      _appBarIconButton(Icons.tablet_mac, 'Tablet', () => provider.setDeviceMode(DeviceMode.tablet), isActive: provider.deviceMode == DeviceMode.tablet),
      _appBarIconButton(Icons.phone_iphone, 'Mobile', () => provider.setDeviceMode(DeviceMode.mobile), isActive: provider.deviceMode == DeviceMode.mobile),
      _divider(),
      _appBarIconButton(Icons.file_copy_outlined, 'Templates', () => _showTemplatesMenu(context, provider)),
      _appBarIconButton(Icons.library_books_outlined, 'Library', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectsLibraryScreen()))),
      _appBarIconButton(Icons.health_and_safety_outlined, 'Health', () {
        final issues = HealthCheckService.analyze(provider.elements);
        _showHealthCheckDialog(context, issues, provider);
      }),
      _divider(),
      _appBarIconButton(_showPreview ? Icons.visibility : Icons.visibility_off, 'Preview', () => setState(() => _showPreview = !_showPreview), isActive: _showPreview),
      _appBarIconButton(_isFocusMode ? Icons.fullscreen_exit : Icons.fullscreen, 'Focus', () => setState(() => _isFocusMode = !_isFocusMode), isActive: _isFocusMode),
      _divider(),
      _appBarButton(Icons.download_rounded, 'Export', () => _handleExport(provider), isPrimary: true),
      _buildMoreOptionsButton(context),
      const SizedBox(width: 8),
    ];
  }

  Widget _divider() => VerticalDivider(width: 20, indent: 15, endIndent: 15, color: Colors.grey.withOpacity(0.2));

  Widget _appBarIconButton(IconData icon, String tooltip, VoidCallback onTap, {bool isActive = false, Color? color}) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onTap,
      color: isActive ? Colors.blueAccent : color,
    );
  }

  Widget _appBarButton(IconData icon, String tooltip, VoidCallback onTap, {bool isPrimary = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isPrimary ? Colors.blueAccent : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: isPrimary ? Colors.white : null),
                if (isPrimary) ...[
                  const SizedBox(width: 8),
                  const Text('Export', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreOptionsButton(BuildContext context) {
    final provider = Provider.of<ProjectProvider>(context, listen: false);
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded),
      tooltip: 'More Options',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: const Offset(0, 48),
      itemBuilder: (context) => [
        _buildMenuHeader('Project & Files'),
        _buildMenuItem(context, 'save', Icons.save_alt, 'Save to Library', color: Colors.blue),
        _buildMenuItem(context, 'snapshots', Icons.history, 'Local Snapshots', color: Colors.blue),
        _buildMenuItem(context, 'import_md', Icons.file_upload, 'Import Markdown', color: Colors.blue),
        _buildMenuItem(context, 'export_json', Icons.javascript, 'Export Project (JSON)', color: Colors.blue),
        _buildMenuItem(context, 'import_json', Icons.data_object, 'Import Project (JSON)', color: Colors.blue),
        _buildMenuItem(context, 'clear', Icons.delete_forever, 'Clear Workspace', color: Colors.red, isDestructive: true),

        const PopupMenuDivider(),
        _buildMenuHeader('Tools & Generators'),
        _buildMenuItem(context, 'gallery', Icons.collections, 'Showcase Gallery', color: Colors.orange),
        _buildMenuItem(context, 'social', Icons.image, 'Social Preview Designer', color: Colors.orange),
        _buildMenuItem(context, 'actions', Icons.build, 'GitHub Actions Generator', color: Colors.orange),
        _buildMenuItem(context, 'funding', Icons.volunteer_activism, 'Funding Generator', color: Colors.pink),
        _buildMenuItem(context, 'extra', Icons.library_add, 'Generate Extra Files', color: Colors.deepOrange),

        const PopupMenuDivider(),
        _buildMenuHeader('AI Features'),
        _buildMenuItem(context, 'ai', Icons.psychology, 'AI Settings', color: Colors.purple),
        _buildMenuItem(context, 'codebase', Icons.auto_awesome, 'Generate From Codebase', color: Colors.purple),

        const PopupMenuDivider(),
        _buildMenuHeader('Publish'),
        _buildMenuItem(context, 'publish', Icons.cloud_upload, 'Publish to GitHub', color: Colors.teal),

        const PopupMenuDivider(),
        _buildMenuHeader('App Settings'),
        _buildMenuItem(context, 'lang', Icons.language, 'Change Language', color: Colors.grey),
        _buildMenuItem(context, 'shortcuts', Icons.keyboard, 'Keyboard Shortcuts', color: Colors.grey),
        _buildMenuItem(context, 'about_dev', Icons.person, 'About Developer', color: Colors.grey),
        _buildMenuItem(context, 'about', Icons.info_outline, 'About App', color: Colors.grey),
      ],
      onSelected: (value) async {
        if (value == 'save') _showSaveToLibraryDialog(context, provider);
        else if (value == 'snapshots') _showSnapshotsDialog(context, provider);
        else if (value == 'import_md') _showImportMarkdownDialog(context, provider);
        else if (value == 'gallery') Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen()));
        else if (value == 'social') Navigator.push(context, MaterialPageRoute(builder: (_) => const SocialPreviewScreen()));
        else if (value == 'actions') Navigator.push(context, MaterialPageRoute(builder: (_) => const GitHubActionsGenerator()));
        else if (value == 'funding') Navigator.push(context, MaterialPageRoute(builder: (_) => const FundingGeneratorScreen()));
        else if (value == 'publish') _showPublishToGitHubDialog(context, provider);
        else if (value == 'ai') _showAISettingsDialog(context, provider);
        else if (value == 'codebase') _showGenerateFromCodebaseDialog(context, provider);
        else if (value == 'extra') _showExtraFilesDialog(context, provider);
        else if (value == 'lang') _showLanguageDialog(context, provider);
        else if (value == 'shortcuts') _showKeyboardShortcutsDialog(context);
        else if (value == 'about_dev') _showDeveloperInfoDialog(context);
        else if (value == 'about') _showAboutAppDialog(context);
        else if (value == 'clear') {
          showSafeDialog(context, builder: (context) => ConfirmDialog(
            title: 'Clear Workspace?',
            content: 'This will remove all elements. This action cannot be undone.',
            confirmText: 'Clear',
            isDestructive: true,
            onConfirm: () => provider.clearElements(),
          ));
        } else if (value == 'export_json') {
          final json = provider.exportToJson();
          downloadJsonFile(json, 'readme_project.json');
        } else if (value == 'import_json') {
          _handleImportJson(provider);
        }
      },
    );
  }

  PopupMenuItem<String> _buildMenuItem(BuildContext context, String value, IconData icon, String text, {Color? color, bool isDestructive = false}) {
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
          Text(text, style: GoogleFonts.inter(color: isDestructive ? Colors.red : null, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildMenuHeader(String title) {
    return PopupMenuItem<String>(
      enabled: false,
      height: 32,
      child: Text(title.toUpperCase(), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
    );
  }

  Widget _buildBackgroundEffects(BuildContext context, bool isDark) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(top: -100, right: -50, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent.withOpacity(isDark ? 0.1 : 0.03)))),
          Positioned(bottom: -50, left: -50, child: Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.purpleAccent.withOpacity(0.08)))),
        ],
      ),
    );
  }

  Widget _buildLiveMarkdownPreview(BuildContext context, ProjectProvider provider, bool isDark) {
    final markdown = MarkdownGenerator().generate(provider.elements, variables: provider.variables);
    return Container(
      color: isDark ? const Color(0xFF0D1117) : Colors.white,
      padding: const EdgeInsets.all(24),
      child: Markdown(
        data: markdown,
        selectable: true,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          p: GoogleFonts.inter(height: 1.6, color: isDark ? const Color(0xFFC9D1D9) : const Color(0xFF24292F)),
          h1: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
          code: GoogleFonts.firaCode(backgroundColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
        ),
      ),
    );
  }

  Widget _buildModernStatusBar(BuildContext context, ProjectProvider provider, bool isDark) {
    final score = AIService.calculateHealthScore(provider.elements);
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: isDark ? Colors.black45 : Colors.white70, border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black12))),
      child: Row(
        children: [
          _statusItem(Icons.widgets_outlined, '${provider.elements.length} Elements'),
          const SizedBox(width: 24),
          _statusItem(Icons.analytics_outlined, 'Quality Score: ${score.toInt()}/100', color: score > 70 ? Colors.green : Colors.orange),
          const Spacer(),
          _statusItem(Icons.cloud_done_outlined, 'Auto-saved', color: Colors.blueAccent),
        ],
      ),
    );
  }

  Widget _statusItem(IconData icon, String label, {Color? color}) {
    return Row(children: [Icon(icon, size: 14, color: color ?? Colors.grey), const SizedBox(width: 6), Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color ?? Colors.grey))]);
  }

  void _showTemplatesMenu(BuildContext context, ProjectProvider provider) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(Rect.fromPoints(button.localToGlobal(Offset.zero, ancestor: overlay), button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay)), Offset.zero & overlay.size);
    showMenu<ProjectTemplate>(context: context, position: position, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), items: provider.allTemplates.map((t) => PopupMenuItem(value: t, child: ListTile(leading: const Icon(Icons.article_outlined, color: Colors.blueAccent), title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(t.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11))))).toList()).then((template) {
      if (template != null) showSafeDialog(context, builder: (context) => ConfirmDialog(title: 'Load Template?', content: 'This will replace your current workspace.', confirmText: 'Load', onConfirm: () => provider.loadTemplate(template)));
    });
  }

  Future<void> _handleImportJson(ProjectProvider provider) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
      if (result != null) {
        String? content;
        if (result.files.first.bytes != null) content = utf8.decode(result.files.first.bytes!);
        if (content != null) {
          provider.importFromJson(content);
          if (context.mounted) ToastHelper.show(context, 'Project imported successfully');
        }
      }
    } catch (e) {
      if (context.mounted) ToastHelper.show(context, 'Error: $e', isError: true);
    }
  }

  void _handleExport(ProjectProvider provider) => ProjectExporter.export(elements: provider.elements, variables: provider.variables, licenseType: provider.licenseType, includeContributing: provider.includeContributing);
  void _showLoginDialog(BuildContext context) => showSafeDialog(context, builder: (_) => const LoginDialog());
  void _showSaveToLibraryDialog(BuildContext context, ProjectProvider provider) => showSafeDialog(context, builder: (_) => const SaveToLibraryDialog());
  void _showSnapshotsDialog(BuildContext context, ProjectProvider provider) => showSafeDialog(context, builder: (_) => const SnapshotsDialog());
  void _showHealthCheckDialog(BuildContext context, List<HealthIssue> issues, ProjectProvider provider) => showSafeDialog(context, builder: (_) => HealthCheckDialog(issues: issues, provider: provider));
  void _showImportMarkdownDialog(BuildContext context, ProjectProvider provider) => showSafeDialog(context, builder: (_) => const ImportMarkdownDialog());
  void _showAISettingsDialog(BuildContext context, ProjectProvider provider) => showSafeDialog(context, builder: (_) => const AISettingsDialog());
  void _showLanguageDialog(BuildContext context, ProjectProvider provider) => showSafeDialog(context, builder: (_) => const LanguageDialog());
  void _showPublishToGitHubDialog(BuildContext context, ProjectProvider provider) => showSafeDialog(context, builder: (_) => const PublishToGitHubDialog());
  void _showGenerateFromCodebaseDialog(BuildContext context, ProjectProvider provider) => showSafeDialog(context, builder: (_) => const GenerateCodebaseDialog());
  void _showExtraFilesDialog(BuildContext context, ProjectProvider provider) => showSafeDialog(context, builder: (_) => const ExtraFilesDialog());
  void _showKeyboardShortcutsDialog(BuildContext context) => showSafeDialog(context, builder: (_) => const KeyboardShortcutsDialog());
  void _showDeveloperInfoDialog(BuildContext context) => showSafeDialog(context, builder: (_) => const DeveloperInfoDialog());
  void _showAboutAppDialog(BuildContext context) => showSafeDialog(context, builder: (_) => const AboutAppDialog());
}
