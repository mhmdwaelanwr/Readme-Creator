import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/project_provider.dart';
import '../../utils/dialog_helper.dart';
import '../../utils/toast_helper.dart';
import '../../core/constants/app_colors.dart';

class AISettingsDialog extends StatefulWidget {
  const AISettingsDialog({super.key});

  @override
  State<AISettingsDialog> createState() => _AISettingsDialogState();
}

class _AISettingsDialogState extends State<AISettingsDialog> {
  late TextEditingController _apiKeyController;
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ProjectProvider>(context, listen: false);
    _apiKeyController = TextEditingController(text: provider.geminiApiKey);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StyledDialog(
      title: DialogHeader(
        title: AppLocalizations.of(context)!.aiSettings,
        icon: Icons.psychology_rounded,
        color: Colors.purple,
      ),
      width: 500,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('API CONFIGURATION'),
            const SizedBox(height: 12),
            _buildApiKeyField(context),
            const SizedBox(height: 16),
            const GlassCard(
              opacity: 0.1,
              child: Text(
                'Your API key is stored locally on your device and is only used to communicate with Google Gemini AI services.',
                style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.4),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.grey)),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_rounded, size: 18),
          label: Text(AppLocalizations.of(context)!.save, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.purple,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return GlassCard(
      opacity: 0.1,
      color: Colors.purple,
      child: Row(
        children: [
          const Icon(Icons.auto_fix_high_rounded, size: 40, color: Colors.purpleAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Google Gemini AI', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  'Powering your README generation with next-gen intelligence.',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                ),
              ],
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

  Widget _buildApiKeyField(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _apiKeyController,
          obscureText: _isObscured,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.geminiApiKey,
            prefixIcon: const Icon(Icons.key_rounded, size: 20),
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
            suffixIcon: IconButton(
              icon: Icon(_isObscured ? Icons.visibility_rounded : Icons.visibility_off_rounded, size: 20),
              onPressed: () => setState(() => _isObscured = !_isObscured),
            ),
          ),
          style: GoogleFonts.firaCode(fontSize: 13),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _launchUrl('https://aistudio.google.com/app/apikey'),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.open_in_new_rounded, size: 14, color: Colors.blue),
                const SizedBox(width: 6),
                Text(
                  AppLocalizations.of(context)!.getApiKey,
                  style: GoogleFonts.inter(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _save() {
    final key = _apiKeyController.text.trim();
    final provider = Provider.of<ProjectProvider>(context, listen: false);
    provider.setGeminiApiKey(key);
    Navigator.pop(context);
    ToastHelper.show(context, AppLocalizations.of(context)!.settingsSaved);
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
