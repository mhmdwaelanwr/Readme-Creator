import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/project_provider.dart';
import '../../utils/dialog_helper.dart';
import '../../utils/toast_helper.dart';

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
        icon: Icons.psychology,
        color: Colors.purple,
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Gemini AI', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.enterGeminiKey,
                style: GoogleFonts.inter(fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _apiKeyController,
                obscureText: _isObscured,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.geminiApiKey,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _isObscured = !_isObscured),
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
                  style: GoogleFonts.inter(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
            final key = _apiKeyController.text.trim();
            final provider = Provider.of<ProjectProvider>(context, listen: false);
            provider.setGeminiApiKey(key);
            Navigator.pop(context);
            ToastHelper.show(context, AppLocalizations.of(context)!.settingsSaved);
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }
}

