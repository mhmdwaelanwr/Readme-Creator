import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/project_provider.dart';
import '../../services/ai_service.dart';
import '../../services/codebase_scanner_service.dart';
import '../../services/github_scanner_service.dart';
import '../../utils/toast_helper.dart';
import '../../utils/dialog_helper.dart';
import '../../core/constants/app_colors.dart';

class GenerateCodebaseDialog extends StatefulWidget {
  const GenerateCodebaseDialog({super.key});

  @override
  State<GenerateCodebaseDialog> createState() => _GenerateCodebaseDialogState();
}

class _GenerateCodebaseDialogState extends State<GenerateCodebaseDialog> with SingleTickerProviderStateMixin {
  final _pathController = TextEditingController();
  final _repoUrlController = TextEditingController();
  late TabController _tabController;
  bool _isLoading = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _pathController.dispose();
    _repoUrlController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StyledDialog(
      title: DialogHeader(
        title: AppLocalizations.of(context)!.generateFromCodebase,
        icon: Icons.auto_awesome_rounded,
        color: Colors.purple,
      ),
      width: 600,
      height: 500, // Slightly increased height for comfort
      contentPadding: EdgeInsets.zero,
      content: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.purple, Colors.deepPurpleAccent],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                dividerColor: Colors.transparent,
                labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'Local Folder'),
                  Tab(text: 'GitHub Repo'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabWrapper(_buildLocalFolderTab(context)),
                _buildTabWrapper(_buildGitHubRepoTab(context)),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildTabWrapper(Widget child) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: child,
    );
  }

  Widget _buildLocalFolderTab(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const GlassCard(
          opacity: 0.1,
          color: Colors.blue,
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.blue, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Point to your project folder, and our AI will analyze the structure to generate a tailored README.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _pathController,
          label: 'Project Path',
          icon: Icons.folder_open_rounded,
          suffix: IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () async {
              String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
              if (selectedDirectory != null) {
                _pathController.text = selectedDirectory;
              }
            },
          ),
        ),
        const SizedBox(height: 32),
        _buildActionButton(
          label: 'Analyze & Generate',
          onPressed: _isLoading ? null : () => _generateFromLocal(context),
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildGitHubRepoTab(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const GlassCard(
          opacity: 0.1,
          color: Colors.blue,
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.blue, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Paste a public GitHub URL to automatically fetch and document your repository.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _repoUrlController,
          label: 'GitHub Repository URL',
          hint: 'https://github.com/user/repo',
          icon: Icons.link_rounded,
        ),
        const SizedBox(height: 32),
        _buildActionButton(
          label: 'Fetch & Generate',
          onPressed: _isLoading ? null : () => _generateFromGitHub(context),
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffix,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(20)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(20)),
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5),
      ),
    );
  }

  Widget _buildActionButton({required String label, required VoidCallback? onPressed, required bool isLoading}) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: isLoading 
          ? _buildLoadingState()
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_fix_high_rounded),
                const SizedBox(width: 12),
                Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
        const SizedBox(width: 16),
        Text(_statusMessage ?? 'Processing...', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Future<void> _generateFromLocal(BuildContext context) async {
    if (_pathController.text.isEmpty) return;
    final provider = Provider.of<ProjectProvider>(context, listen: false);
    setState(() { _isLoading = true; _statusMessage = 'Scanning files...'; });
    try {
      final structure = await CodebaseScannerService.scanDirectory(_pathController.text);
      if (!mounted) return;
      setState(() => _statusMessage = 'AI is writing...');
      final readmeContent = await AIService.generateReadmeFromStructure(structure, apiKey: provider.geminiApiKey);
      if (!mounted) return;
      Navigator.pop(context);
      provider.importMarkdown(readmeContent);
      ToastHelper.show(context, 'README generated successfully!');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ToastHelper.show(context, 'Error: $e', isError: true);
    }
  }

  Future<void> _generateFromGitHub(BuildContext context) async {
    if (_repoUrlController.text.isEmpty) return;
    final provider = Provider.of<ProjectProvider>(context, listen: false);
    setState(() { _isLoading = true; _statusMessage = 'Fetching repo...'; });
    try {
      final githubScanner = GitHubScannerService();
      final structure = await githubScanner.scanRepo(_repoUrlController.text);
      if (!mounted) return;
      setState(() => _statusMessage = 'AI is writing...');
      final readmeContent = await AIService.generateReadmeFromStructure(structure, apiKey: provider.geminiApiKey);
      if (!mounted) return;
      Navigator.pop(context);
      provider.importMarkdown(readmeContent);
      ToastHelper.show(context, 'README generated successfully!');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ToastHelper.show(context, 'Error: $e', isError: true);
    }
  }
}
