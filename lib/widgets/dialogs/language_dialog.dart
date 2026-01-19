import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/project_provider.dart';
import '../../utils/dialog_helper.dart';
import '../../core/constants/app_colors.dart';

class LanguageDialog extends StatelessWidget {
  const LanguageDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return StyledDialog(
      title: DialogHeader(
        title: AppLocalizations.of(context)!.changeLanguage,
        icon: Icons.translate_rounded,
        color: Colors.orange,
      ),
      width: 500,
      height: 600,
      content: Column(
        children: [
          const GlassCard(
            opacity: 0.1,
            color: Colors.orange,
            child: Text(
              'Choose your preferred language for the application interface.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Consumer<ProjectProvider>(
              builder: (context, provider, _) {
                return ListView(
                  children: [
                    _buildLanguageItem(context, provider, 'English', 'en', '🇺🇸'),
                    _buildLanguageItem(context, provider, 'العربية', 'ar', '🇪🇬'),
                    _buildLanguageItem(context, provider, 'Español', 'es', '🇪🇸'),
                    _buildLanguageItem(context, provider, 'Français', 'fr', '🇫🇷'),
                    _buildLanguageItem(context, provider, 'Deutsch', 'de', '🇩🇪'),
                    _buildLanguageItem(context, provider, 'हिन्दी', 'hi', '🇮🇳'),
                    _buildLanguageItem(context, provider, '日本語', 'ja', '🇯🇵'),
                    _buildLanguageItem(context, provider, 'Português', 'pt', '🇧🇷'),
                    _buildLanguageItem(context, provider, 'Русский', 'ru', '🇷🇺'),
                    _buildLanguageItem(context, provider, '中文', 'zh', '🇨🇳'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(),
                    ),
                    _buildSystemDefaultItem(context, provider),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            AppLocalizations.of(context)!.close,
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageItem(BuildContext context, ProjectProvider provider, String name, String code, String flag) {
    final isSelected = provider.locale?.languageCode == code;
    return GlassCard(
      opacity: isSelected ? 0.15 : 0.05,
      color: isSelected ? AppColors.primary : null,
      onTap: () {
        provider.setLocale(Locale(code));
        Navigator.pop(context);
      },
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: Text(flag, style: const TextStyle(fontSize: 24)),
        title: Text(
          name,
          style: GoogleFonts.inter(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.primary : null,
          ),
        ),
        trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
      ),
    );
  }

  Widget _buildSystemDefaultItem(BuildContext context, ProjectProvider provider) {
    final isSelected = provider.locale == null;
    return GlassCard(
      opacity: isSelected ? 0.15 : 0.05,
      color: isSelected ? AppColors.primary : null,
      onTap: () {
        provider.setLocale(null);
        Navigator.pop(context);
      },
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: const Icon(Icons.settings_suggest_rounded),
        title: Text(
          'System Default',
          style: GoogleFonts.inter(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.primary : null,
          ),
        ),
        trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
      ),
    );
  }
}
