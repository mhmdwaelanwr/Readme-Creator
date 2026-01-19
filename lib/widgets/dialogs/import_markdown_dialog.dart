import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/project_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/dialog_helper.dart';
import '../../utils/toast_helper.dart';
import '../../core/constants/app_colors.dart';
import 'login_dialog.dart';

class ImportMarkdownDialog extends StatefulWidget {
  const ImportMarkdownDialog({super.key});

  @override
  State<ImportMarkdownDialog> createState() => _ImportMarkdownDialogState();
}

class _ImportMarkdownDialogState extends State<ImportMarkdownDialog> with SingleTickerProviderStateMixin {
  final _textController = TextEditingController();
  final _urlController = TextEditingController();
  final AuthService _authService = AuthService();
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _textController.dispose();
    _urlController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StyledDialog(
      width: 700,
      height: 650,
      title: const DialogHeader(
        title: 'Project Intelligence Import',
        icon: Icons.auto_awesome_rounded,
        color: Colors.indigo,
      ),
      contentPadding: EdgeInsets.zero,
      content: Column(
        children: [
          _buildAuthStatusBanner(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
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
                  gradient: const LinearGradient(colors: [Colors.indigo, Colors.indigoAccent]),
                  borderRadius: BorderRadius.circular(12),
                ),
                dividerColor: Colors.transparent,
                labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'Manual / File'),
                  Tab(text: 'GitHub Integration'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTextTab(),
                _buildGithubTab(),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.grey)),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: () => _importOrClose(context),
          icon: const Icon(Icons.bolt_rounded, size: 18),
          label: const Text('Finalize Import', style: TextStyle(fontWeight: FontWeight.bold)),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.indigo,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthStatusBanner() {
    final bool isGithubConnected = _authService.githubToken != null;
    
    return GlassCard(
      opacity: 0.1,
      color: isGithubConnected ? Colors.green : Colors.amber,
      borderRadius: 0,
      child: Row(
        children: [
          Icon(
            isGithubConnected ? Icons.check_circle_rounded : Icons.info_outline_rounded,
            size: 16,
            color: isGithubConnected ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isGithubConnected 
                ? 'Authenticated with GitHub. Full project access enabled.'
                : 'Limited access. Connect GitHub for seamless project engineering.',
              style: GoogleFonts.inter(
                fontSize: 12, 
                fontWeight: FontWeight.w600,
                color: isGithubConnected ? Colors.green : Colors.orange,
              ),
            ),
          ),
          if (!isGithubConnected)
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                showSafeDialog(context, builder: (context) => const LoginDialog());
              },
              child: const Text('Connect Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildGithubTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('FETCH FROM REPOSITORY'),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _urlController,
            label: 'Repository / File URL',
            hint: 'https://github.com/user/repo',
            icon: Icons.public_rounded,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: _isLoading ? null : _fetchFromSource,
              icon: _isLoading 
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) 
                : const Icon(Icons.cloud_download_rounded),
              label: Text(_isLoading ? 'Analyzing Source...' : 'Execute Intelligent Import'),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const Spacer(),
          const GlassCard(
            opacity: 0.05,
            child: Text(
              'Pro Tip: If you are logged in, we use your token to bypass GitHub API limits and access private files.',
              style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withAlpha(20)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withAlpha(20)),
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(10),
      ),
    );
  }

  Future<void> _fetchFromSource() async {
    if (_urlController.text.isEmpty) return;
    setState(() => _isLoading = true);
    
    try {
      String fetchUrl = _urlController.text;
      if (fetchUrl.contains('github.com') && fetchUrl.contains('/blob/')) {
        fetchUrl = fetchUrl.replaceFirst('/blob/', '/raw/');
      }

      final headers = <String, String>{};
      if (_authService.githubToken != null) {
        headers['Authorization'] = 'token ${_authService.githubToken}';
      }

      final response = await http.get(Uri.parse(fetchUrl), headers: headers);
      
      if (response.statusCode == 200) {
        setState(() { 
          _textController.text = response.body; 
          _tabController.animateTo(0); 
        });
        if (mounted) ToastHelper.show(context, 'Content fetched using secure authentication');
      } else {
        if (mounted) ToastHelper.show(context, 'Access Denied: ${response.statusCode}. Try logging in.', isError: true);
      }
    } catch (e) {
      if (mounted) ToastHelper.show(context, 'Network Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: '# Project Context\n\nStarting writing or paste here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withAlpha(20)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withAlpha(20)),
                ),
                filled: true,
                fillColor: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(10),
              ),
              style: GoogleFonts.firaCode(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5),
    );
  }

  void _importOrClose(BuildContext context) {
    if (_textController.text.isNotEmpty) {
      final markdownText = _textController.text;
      final provider = Provider.of<ProjectProvider>(context, listen: false);
      Navigator.pop(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.importMarkdown(markdownText);
      });
      ToastHelper.show(context, 'Intelligence imported successfully!');
    }
  }
}
