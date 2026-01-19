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
import '../core/constants/app_colors.dart';

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
  late AnimationController _mainController;
  late Animation<double> _fadeAnimation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _authService = AuthService();
  bool _showPreview = false;
  bool _isFocusMode = false;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(parent: _mainController, curve: Curves.easeOutQuart);
    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
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
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: _buildFutureAppBar(context, isDesktop, provider),
        drawer: isDesktop ? null : const Drawer(child: ComponentsPanel()),
        endDrawer: isDesktop ? null : const Drawer(child: SettingsPanel()),
        body: Stack(
          children: [
            _buildCinematicBackground(context, isDark),
            Column(
              children: [
                const SizedBox(height: 110), 
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        if (isDesktop && !_isFocusMode) 
                          _buildGlassPanel(const ComponentsPanel(), flex: 2),
                        
                        if (isDesktop && !_isFocusMode) const SizedBox(width: 20),
                        
                        Expanded(
                          flex: 6,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: const EditorCanvas(),
                          ),
                        ),
                        
                        if (_showPreview && isDesktop) ...[
                          const SizedBox(width: 20),
                          _buildGlassPanel(_buildLiveMarkdownPreview(context, provider, isDark), flex: 4),
                        ],
                        
                        if (isDesktop && !_isFocusMode) const SizedBox(width: 20),
                        
                        if (isDesktop && !_isFocusMode) 
                          _buildGlassPanel(const SettingsPanel(), flex: 3),
                      ],
                    ),
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

  PreferredSizeWidget _buildFutureAppBar(BuildContext context, bool isDesktop, ProjectProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: (isDark ? Colors.black : Colors.white).withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.12)),
              ),
              child: Row(
                children: [
                  _studioIcon(),
                  const SizedBox(width: 12),
                  Text('MD Studio', style: GoogleFonts.poppins(fontWeight: FontWeight.w900, fontSize: 16, color: isDark ? Colors.white : AppColors.primary)),
                  const Spacer(),
                  if (isDesktop) ..._buildFullAppBarActions(context, provider),
                  if (!isDesktop) IconButton(icon: const Icon(Icons.tune_rounded), onPressed: () => _scaffoldKey.currentState?.openEndDrawer()),
                  _buildMoreOptionsButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFullAppBarActions(BuildContext context, ProjectProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      _actionBtn(Icons.undo_rounded, provider.undo, tooltip: 'Undo'),
      _actionBtn(Icons.redo_rounded, provider.redo, tooltip: 'Redo'),
      _divider(),
      _deviceBtn(Icons.desktop_mac, DeviceMode.desktop, provider),
      _deviceBtn(Icons.tablet_mac, DeviceMode.tablet, provider),
      _deviceBtn(Icons.phone_iphone, DeviceMode.mobile, provider),
      _divider(),
      _actionBtn(Icons.file_copy_outlined, () => _showTemplatesMenu(context, provider), tooltip: 'Templates'),
      _actionBtn(Icons.library_books_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectsLibraryScreen())), tooltip: 'Library'),
      _actionBtn(Icons.health_and_safety_outlined, () {
        final issues = HealthCheckService.analyze(provider.elements);
        _showHealthCheckDialog(context, issues, provider);
      }, tooltip: 'Health Check'),
      _divider(),
      _actionBtn(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, provider.toggleTheme, color: isDark ? Colors.amber : Colors.blueGrey, tooltip: 'Toggle Theme'),
      _actionBtn(Icons.settings_outlined, () => _showProjectSettingsDialog(context, provider), tooltip: 'Settings'),
      _divider(),
      _actionBtn(_showPreview ? Icons.visibility : Icons.visibility_off, () => setState(() => _showPreview = !_showPreview), active: _showPreview, tooltip: 'Preview'),
      _actionBtn(_isFocusMode ? Icons.fullscreen_exit : Icons.fullscreen, () => setState(() => _isFocusMode = !_isFocusMode), active: _isFocusMode, tooltip: 'Focus Mode'),
      const SizedBox(width: 12),
      ElevatedButton.icon(
        onPressed: () => _handleExport(provider),
        icon: const Icon(Icons.rocket_launch_rounded, size: 16),
        label: const Text('Export', style: TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
      ),
    ];
  }

  Widget _buildMoreOptionsButton(BuildContext context) {
    final provider = Provider.of<ProjectProvider>(context, listen: false);
    return PopupMenuButton<String>(
      icon: const Icon(Icons.grid_view_rounded, size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      offset: const Offset(0, 50),
      itemBuilder: (context) => [
        _menuHeader('Project & Files'),
        _menuItem('save', Icons.save_alt_rounded, 'Save Project', Colors.blue),
        _menuItem('snapshots', Icons.history_rounded, 'Local Snapshots', Colors.blue),
        _menuItem('import_md', Icons.file_upload_outlined, 'Import Markdown', Colors.blue),
        _menuItem('export_json', Icons.javascript_rounded, 'Export JSON', Colors.blue),
        _menuItem('import_json', Icons.data_object_rounded, 'Import JSON', Colors.blue),
        _menuItem('clear', Icons.delete_sweep_rounded, 'Clear Workspace', Colors.red, isDestructive: true),
        const PopupMenuDivider(),
        _menuHeader('Tools & Generators'),
        _menuItem('gallery', Icons.auto_awesome_mosaic_rounded, 'Showcase Gallery', Colors.orange),
        _menuItem('social', Icons.auto_graph_rounded, 'Social Designer', Colors.orange),
        _menuItem('actions', Icons.terminal_rounded, 'GitHub Actions', Colors.orange),
        _menuItem('funding', Icons.volunteer_activism_rounded, 'Funding Generator', Colors.pink),
        _menuItem('extra', Icons.library_add_rounded, 'Generate Extra Files', Colors.deepOrange),
        const PopupMenuDivider(),
        _menuHeader('Intelligence'),
        _menuItem('ai', Icons.psychology_rounded, 'AI Settings', Colors.purple),
        _menuItem('codebase', Icons.auto_awesome_rounded, 'Code Scan', Colors.purple),
        _menuItem('publish', Icons.cloud_upload_rounded, 'Publish to GitHub', Colors.teal),
        const PopupMenuDivider(),
        _menuHeader('Application'),
        _menuItem('lang', Icons.translate_rounded, 'Change Language', Colors.grey),
        _menuItem('shortcuts', Icons.keyboard_rounded, 'Shortcuts', Colors.grey),
        _menuItem('about_dev', Icons.person_rounded, 'About Developer', Colors.grey),
        _menuItem('about', Icons.info_outline_rounded, 'About App', Colors.grey),
      ],
      onSelected: (val) {
        if (val == 'save') _showSaveToLibraryDialog(context, provider);
        else if (val == 'snapshots') _showSnapshotsDialog(context, provider);
        else if (val == 'import_md') _showImportMarkdownDialog(context, provider);
        else if (val == 'export_json') downloadJsonFile(provider.exportToJson(), 'readme_project.json');
        else if (val == 'import_json') _handleImportJson(provider);
        else if (val == 'clear') showSafeDialog(context, builder: (context) => ConfirmDialog(title: 'Clear Workspace?', content: 'This will remove all elements.', confirmText: 'Clear', isDestructive: true, onConfirm: () => provider.clearElements()));
        else if (val == 'gallery') Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen()));
        else if (val == 'social') Navigator.push(context, MaterialPageRoute(builder: (_) => const SocialPreviewScreen()));
        else if (val == 'actions') Navigator.push(context, MaterialPageRoute(builder: (_) => const GitHubActionsGenerator()));
        else if (val == 'funding') Navigator.push(context, MaterialPageRoute(builder: (_) => const FundingGeneratorScreen()));
        else if (val == 'extra') _showExtraFilesDialog(context, provider);
        else if (val == 'ai') _showAISettingsDialog(context, provider);
        else if (val == 'codebase') _showGenerateFromCodebaseDialog(context, provider);
        else if (val == 'publish') _showPublishToGitHubDialog(context, provider);
        else if (val == 'lang') _showLanguageDialog(context, provider);
        else if (val == 'shortcuts') _showKeyboardShortcutsDialog(context);
        else if (val == 'about_dev') _showDeveloperInfoDialog(context);
        else if (val == 'about') _showAboutAppDialog(context);
      },
    );
  }

  Widget _buildGlassPanel(Widget child, {required int flex}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      flex: flex,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: (isDark ? Colors.black26 : Colors.white.withOpacity(0.7)),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.08)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, VoidCallback onTap, {bool active = false, String? tooltip, Color? color}) => Tooltip(message: tooltip ?? '', child: IconButton(icon: Icon(icon, size: 19, color: active ? AppColors.primary : color), onPressed: onTap, splashRadius: 22));
  Widget _deviceBtn(IconData icon, DeviceMode mode, ProjectProvider provider) => IconButton(icon: Icon(icon, size: 19, color: provider.deviceMode == mode ? AppColors.primary : Colors.grey), onPressed: () => provider.setDeviceMode(mode));
  Widget _divider() => const VerticalDivider(width: 24, indent: 20, endIndent: 20);
  Widget _studioIcon() => Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18));
  PopupMenuItem<String> _menuHeader(String title) => PopupMenuItem(enabled: false, height: 30, child: Text(title.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2)));
  PopupMenuItem<String> _menuItem(String val, IconData icon, String text, Color color, {bool isDestructive = false}) => PopupMenuItem(value: val, child: Row(children: [Icon(icon, color: isDestructive ? Colors.red : color, size: 18), const SizedBox(width: 12), Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDestructive ? Colors.red : null))]));

  Widget _buildCinematicBackground(BuildContext context, bool isDark) {
    return Stack(children: [Positioned(top: -50, right: -50, child: _blob(400, AppColors.primary.withOpacity(isDark ? 0.2 : 0.1))), Positioned(bottom: -100, left: -100, child: _blob(500, Colors.purpleAccent.withOpacity(isDark ? 0.15 : 0.05)))]);
  }
  Widget _blob(double size, Color color) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color, boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)]));

  Widget _buildLiveMarkdownPreview(BuildContext context, ProjectProvider provider, bool isDark) {
    final markdown = MarkdownGenerator().generate(provider.elements, variables: provider.variables);
    return Padding(padding: const EdgeInsets.all(24), child: Markdown(data: markdown, styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))));
  }

  Widget _buildModernStatusBar(BuildContext context, ProjectProvider provider, bool isDark) {
    final score = HealthCheckService.calculateDocumentationScore(provider.elements);
    return Container(height: 36, padding: const EdgeInsets.symmetric(horizontal: 24), decoration: BoxDecoration(color: isDark ? Colors.black38 : Colors.white70, border: Border(top: BorderSide(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)))), child: Row(children: [_statusItem(Icons.widgets_outlined, '${provider.elements.length} Elements'), const SizedBox(width: 24), _statusItem(Icons.analytics_outlined, 'Doc Quality: ${score.toInt()}%', color: score > 70 ? Colors.greenAccent : Colors.orangeAccent), const Spacer(), if (provider.isSaving) const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)) else _statusItem(Icons.cloud_done_rounded, 'Studio Synced', color: AppColors.primary)]));
  }
  Widget _statusItem(IconData icon, String label, {Color? color}) => Row(children: [Icon(icon, size: 14, color: color ?? Colors.grey), const SizedBox(width: 6), Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color ?? Colors.grey))]);

  void _showTemplatesMenu(BuildContext context, ProjectProvider provider) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(Rect.fromPoints(button.localToGlobal(Offset.zero, ancestor: overlay), button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay)), Offset.zero & overlay.size);
    showMenu<ProjectTemplate>(context: context, position: position, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), items: provider.allTemplates.map((t) => PopupMenuItem(value: t, child: ListTile(leading: const Icon(Icons.article_outlined, color: AppColors.primary), title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(t.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11))))).toList()).then((template) {
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
  void _showProjectSettingsDialog(BuildContext context, ProjectProvider provider) => showSafeDialog(context, builder: (_) => const ProjectSettingsDialog());
  void _showSaveToLibraryDialog(BuildContext context, ProjectProvider provider) => showSafeDialog(context, builder: (_) => const SaveToLibraryDialog());
  void _showSnapshotsDialog(BuildContext context, ProjectProvider provider) => showSafeDialog(context, builder: (_) => const SnapshotsDialog());
  void _showHealthCheckDialog(BuildContext context, List<HealthIssue> issues, ProjectProvider provider) => showSafeDialog(context, builder: (_) => HealthCheckDialog(issues: issues, provider: provider));
  void _showImportMarkdownDialog(BuildContext context, ProjectProvider provider) => showSafeDialog(context, builder: (_) => const ImportMarkdownDialog());
  void _showAISettingsDialog(BuildContext context, ProjectProvider provider) => showSafeDialog(context, builder: (_) => const AISettingsDialog());
  void _showGenerateFromCodebaseDialog(BuildContext context, ProjectProvider provider) => showSafeDialog(context, builder: (_) => const GenerateCodebaseDialog());
  void _showPublishToGitHubDialog(BuildContext context, ProjectProvider provider) => showSafeDialog(context, builder: (_) => const PublishToGitHubDialog());
  void _showExtraFilesDialog(BuildContext context, ProjectProvider provider) => showSafeDialog(context, builder: (_) => const ExtraFilesDialog());
  void _showLanguageDialog(BuildContext context, ProjectProvider provider) => showSafeDialog(context, builder: (_) => const LanguageDialog());
  void _showKeyboardShortcutsDialog(BuildContext context) => showSafeDialog(context, builder: (_) => const KeyboardShortcutsDialog());
  void _showDeveloperInfoDialog(BuildContext context) => showSafeDialog(context, builder: (_) => const DeveloperInfoDialog());
  void _showAboutAppDialog(BuildContext context) => showSafeDialog(context, builder: (_) => const AboutAppDialog());
}
