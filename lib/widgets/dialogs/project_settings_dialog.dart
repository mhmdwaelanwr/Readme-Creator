import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/project_provider.dart';
import '../../utils/debouncer.dart';
import '../../utils/dialog_helper.dart';
import '../../core/constants/app_colors.dart';
import 'confirm_dialog.dart';

class ProjectSettingsDialog extends StatefulWidget {
  const ProjectSettingsDialog({super.key});

  @override
  State<ProjectSettingsDialog> createState() => _ProjectSettingsDialogState();
}

class _ProjectSettingsDialogState extends State<ProjectSettingsDialog> {
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StyledDialog(
      title: DialogHeader(
        title: AppLocalizations.of(context)!.projectSettings,
        icon: Icons.tune_rounded,
        color: AppColors.primary,
      ),
      contentPadding: EdgeInsets.zero,
      width: 650,
      height: 650,
      content: DefaultTabController(
        length: 5,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  isScrollable: true,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  dividerColor: Colors.transparent,
                  labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: [
                    Tab(text: AppLocalizations.of(context)!.variables),
                    Tab(text: AppLocalizations.of(context)!.license),
                    const Tab(text: 'Community'),
                    Tab(text: AppLocalizations.of(context)!.colors),
                    Tab(text: AppLocalizations.of(context)!.formatting),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildVariablesTab(provider),
                  _buildLicenseTab(provider),
                  _buildCommunityTab(provider),
                  _buildColorsTab(provider),
                  _buildFormattingTab(provider),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.close, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildVariablesTab(ProjectProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('PROJECT VARIABLES'),
          const SizedBox(height: 16),
          ...provider.variables.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildTextField(
                label: entry.key,
                initialValue: entry.value,
                icon: Icons.label_important_outline_rounded,
                onChanged: (value) {
                  _debouncer.run(() {
                    provider.updateVariable(entry.key, value);
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLicenseTab(ProjectProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('SOFTWARE LICENSE'),
          const SizedBox(height: 16),
          GlassCard(
            opacity: 0.1,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: provider.licenseType,
                  decoration: InputDecoration(
                    labelText: 'Select License',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: [
                    'None', 'MIT', 'Apache 2.0', 'GPLv3', 'BSD 3-Clause'
                  ].map((val) => DropdownMenuItem(value: val, child: Text(val, style: GoogleFonts.inter()))).toList(),
                  onChanged: (value) {
                    if (value != null) provider.setLicenseType(value);
                  },
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'A LICENSE file will be generated and included in the export.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityTab(ProjectProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildSectionTitle('COMMUNITY STANDARDS'),
        const SizedBox(height: 16),
        _buildSwitchTile('CONTRIBUTING.md', 'Adds a standard contributing guide.', provider.includeContributing, (v) => provider.setIncludeContributing(v), Icons.handshake_rounded),
        _buildSwitchTile('SECURITY.md', 'Adds a security policy.', provider.includeSecurity, (v) => provider.setIncludeSecurity(v), Icons.security_rounded),
        _buildSwitchTile('SUPPORT.md', 'Adds support information.', provider.includeSupport, (v) => provider.setIncludeSupport(v), Icons.help_outline_rounded),
        _buildSwitchTile('CODE_OF_CONDUCT.md', 'Adds a code of conduct.', provider.includeCodeOfConduct, (v) => provider.setIncludeCodeOfConduct(v), Icons.gavel_rounded),
        _buildSwitchTile('Issue Templates', 'Adds GitHub issue and PR templates.', provider.includeIssueTemplates, (v) => provider.setIncludeIssueTemplates(v), Icons.bug_report_rounded),
      ],
    );
  }

  Widget _buildColorsTab(ProjectProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildSectionTitle('BRANDING COLORS'),
        const SizedBox(height: 16),
        _buildColorTile(AppLocalizations.of(context)!.primaryColor, provider.primaryColor, (c) => provider.setPrimaryColor(c)),
        _buildColorTile(AppLocalizations.of(context)!.secondaryColor, provider.secondaryColor, (c) => provider.setSecondaryColor(c)),
      ],
    );
  }

  Widget _buildFormattingTab(ProjectProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildSectionTitle('EXPORT FORMATTING'),
        const SizedBox(height: 16),
        _buildSwitchTile(AppLocalizations.of(context)!.exportHtml, 'Include a formatted HTML file.', provider.exportHtml, (v) => provider.setExportHtml(v), Icons.html_rounded),
        const SizedBox(height: 16),
        _buildSectionTitle('MARKDOWN STYLE'),
        const SizedBox(height: 16),
        _buildDropdownSetting(
          label: AppLocalizations.of(context)!.listBulletStyle,
          value: provider.listBullet,
          items: {'*': '* (Asterisk)', '-': '- (Dash)', '+': '+ (Plus)'},
          onChanged: (v) => provider.setListBullet(v!),
          icon: Icons.list_rounded,
        ),
        const SizedBox(height: 16),
        _buildDropdownSetting(
          label: AppLocalizations.of(context)!.sectionSpacing,
          value: provider.sectionSpacing,
          items: {0: 'Compact', 1: 'Standard', 2: 'Spacious'},
          onChanged: (v) => provider.setSectionSpacing(v!),
          icon: Icons.vertical_distribute_rounded,
        ),
      ],
    );
  }

  Widget _buildTextField({required String label, required String initialValue, required IconData icon, required ValueChanged<String> onChanged}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
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
      style: GoogleFonts.inter(),
      onChanged: onChanged,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged, IconData icon) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: SwitchListTile(
        secondary: Icon(icon, color: AppColors.primary),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildColorTile(String title, Color color, ValueChanged<Color> onColorChanged) {
    return GlassCard(
      padding: EdgeInsets.zero,
      onTap: () => _showColorPicker(context, color, onColorChanged),
      child: ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white.withAlpha(50))),
        ),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text('#${color.toARGB32().toRadixString(16).toUpperCase().substring(2)}', style: GoogleFonts.firaCode(fontSize: 12)),
        trailing: const Icon(Icons.colorize_rounded, size: 18),
      ),
    );
  }

  void _showColorPicker(BuildContext context, Color initialColor, ValueChanged<Color> onColorChanged) {
    showSafeDialog(
      context,
      builder: (context) => ConfirmDialog(
        title: 'Pick Color',
        onConfirm: () {},
        confirmText: 'Done',
        content: '',
        icon: Icons.colorize_rounded,
      ),
    );
  }

  Widget _buildDropdownSetting<T>({required String label, required T value, required Map<T, String> items, required ValueChanged<T?> onChanged, required IconData icon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
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
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          items: items.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: GoogleFonts.inter()))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
