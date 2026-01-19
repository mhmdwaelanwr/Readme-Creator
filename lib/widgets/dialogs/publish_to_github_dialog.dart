import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../providers/project_provider.dart';
import '../../services/github_publisher_service.dart';
import '../../generator/markdown_generator.dart';
import '../../utils/dialog_helper.dart';
import '../../utils/toast_helper.dart';
import '../../core/constants/app_colors.dart';
import 'confirm_dialog.dart';

class PublishToGitHubDialog extends StatefulWidget {
  const PublishToGitHubDialog({super.key});

  @override
  State<PublishToGitHubDialog> createState() => _PublishToGitHubDialogState();
}

class _PublishToGitHubDialogState extends State<PublishToGitHubDialog> {
  final _ownerController = TextEditingController();
  final _repoController = TextEditingController();
  final _branchController = TextEditingController(text: 'docs/update-readme');
  final _messageController = TextEditingController(text: 'docs: update README.md via Readme Creator');
  late TextEditingController _tokenController;
  bool _isLoading = false;
  bool _isTokenObscured = true;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ProjectProvider>(context, listen: false);
    _tokenController = TextEditingController(text: provider.githubToken);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _repoController.dispose();
    _branchController.dispose();
    _messageController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StyledDialog(
      title: const DialogHeader(
        title: 'Publish to GitHub',
        icon: Icons.cloud_upload_rounded,
        color: Colors.teal,
      ),
      width: 600,
      height: 650,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GlassCard(
              opacity: 0.1,
              color: Colors.teal,
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.teal, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This will create a new branch and open a Pull Request with your generated README.md directly on GitHub.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('AUTHENTICATION'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _tokenController,
              label: 'Personal Access Token',
              icon: Icons.key_rounded,
              obscureText: _isTokenObscured,
              suffix: IconButton(
                icon: Icon(_isTokenObscured ? Icons.visibility_rounded : Icons.visibility_off_rounded, size: 20),
                onPressed: () => setState(() => _isTokenObscured = !_isTokenObscured),
              ),
              helper: 'Need a token? Generate one in GitHub settings with "repo" scope.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('REPOSITORY DETAILS'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _ownerController,
                    label: 'Owner',
                    icon: Icons.person_rounded,
                    hint: 'user or org',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _repoController,
                    label: 'Repository',
                    icon: Icons.folder_rounded,
                    hint: 'repo-name',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _branchController,
              label: 'New Branch Name',
              icon: Icons.account_tree_rounded,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _messageController,
              label: 'Commit Message',
              icon: Icons.message_rounded,
            ),
            if (_isLoading) ...[
              const SizedBox(height: 24),
              _buildLoadingIndicator(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
        _buildPublishButton(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? helper,
    bool obscureText = false,
    Widget? suffix,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            suffixIcon: suffix,
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
          style: GoogleFonts.inter(fontSize: 14),
        ),
        if (helper != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(helper, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
          ),
      ],
    );
  }

  Widget _buildPublishButton() {
    return FilledButton.icon(
      icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.rocket_launch_rounded, size: 18),
      label: Text(_isLoading ? 'Publishing...' : 'Create Pull Request'),
      onPressed: _isLoading ? null : () => _publish(context),
      style: FilledButton.styleFrom(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        children: [
          const CircularProgressIndicator(strokeWidth: 3, color: Colors.teal),
          const SizedBox(height: 12),
          Text('Uploading to GitHub...', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.teal)),
        ],
      ),
    );
  }

  Future<void> _publish(BuildContext context) async {
    if (_tokenController.text.isEmpty) {
      ToastHelper.show(context, 'GitHub Token is required', isError: true);
      return;
    }
    if (_ownerController.text.isEmpty || _repoController.text.isEmpty) {
      ToastHelper.show(context, 'Owner and Repo are required', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final provider = Provider.of<ProjectProvider>(context, listen: false);
    provider.setGitHubToken(_tokenController.text.trim());

    try {
      final generator = MarkdownGenerator();
      final content = generator.generate(
        provider.elements,
        variables: provider.variables,
        listBullet: provider.listBullet,
        sectionSpacing: provider.sectionSpacing,
        targetLanguage: provider.targetLanguage,
      );

      final publisher = GitHubPublisherService(provider.githubToken);
      await publisher.publishReadme(
        owner: _ownerController.text.trim(),
        repo: _repoController.text.trim(),
        content: content,
        branchName: _branchController.text.trim(),
        commitMessage: _messageController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context);
      _showSuccessDialog(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ToastHelper.show(context, 'Error: $e', isError: true);
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showSafeDialog(
      context,
      builder: (context) => ConfirmDialog(
        title: 'Success!',
        content: 'Your Pull Request has been created successfully.',
        confirmText: 'Awesome',
        onConfirm: () {},
      ),
    );
  }
}
