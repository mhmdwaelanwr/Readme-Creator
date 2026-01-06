import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/project_provider.dart';
import '../../utils/dialog_helper.dart';

class LanguageDialog extends StatelessWidget {
  const LanguageDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return StyledDialog(
      title: DialogHeader(
        title: AppLocalizations.of(context)!.changeLanguage,
        icon: Icons.language,
        color: Colors.grey,
      ),
      content: SizedBox(
        width: 300,
        child: SingleChildScrollView(
          child: Consumer<ProjectProvider>(
            builder: (context, provider, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLanguageTile(context, provider, 'English', 'en'),
                  _buildLanguageTile(context, provider, 'العربية (Arabic)', 'ar'),
                  _buildLanguageTile(context, provider, 'Español (Spanish)', 'es'),
                  _buildLanguageTile(context, provider, 'Français (French)', 'fr'),
                  _buildLanguageTile(context, provider, 'Deutsch (German)', 'de'),
                  _buildLanguageTile(context, provider, 'हिन्दी (Hindi)', 'hi'),
                  _buildLanguageTile(context, provider, '日本語 (Japanese)', 'ja'),
                  _buildLanguageTile(context, provider, 'Português (Portuguese)', 'pt'),
                  _buildLanguageTile(context, provider, 'Русский (Russian)', 'ru'),
                  _buildLanguageTile(context, provider, '中文 (Chinese)', 'zh'),
                  const Divider(),
                  ListTile(
                    title: const Text('System Default'),
                    trailing: provider.locale == null ? const Icon(Icons.check, color: Colors.blue) : null,
                    onTap: () {
                      provider.setLocale(null);
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
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
  }

  Widget _buildLanguageTile(BuildContext context, ProjectProvider provider, String name, String code) {
    return ListTile(
      title: Text(name),
      trailing: provider.locale?.languageCode == code ? const Icon(Icons.check, color: Colors.blue) : null,
      onTap: () {
        provider.setLocale(Locale(code));
        Navigator.pop(context);
      },
    );
  }
}

