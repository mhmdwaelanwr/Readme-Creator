import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/dialog_helper.dart';
import '../../core/constants/app_colors.dart';

class KeyboardShortcutsDialog extends StatelessWidget {
  const KeyboardShortcutsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return StyledDialog(
      title: DialogHeader(
        title: AppLocalizations.of(context)!.keyboardShortcuts,
        icon: Icons.keyboard_command_key_rounded,
        color: Colors.blueGrey,
      ),
      width: 600,
      height: 650,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('SYSTEM & NAVIGATION'),
            const SizedBox(height: 12),
            _buildShortcutGroup(context, [
              {'label': AppLocalizations.of(context)!.saveProject, 'win': 'Ctrl + S', 'mac': '⌘ + S'},
              {'label': AppLocalizations.of(context)!.exportProject, 'win': 'Ctrl + E', 'mac': '⌘ + E'},
              {'label': AppLocalizations.of(context)!.undo, 'win': 'Ctrl + Z', 'mac': '⌘ + Z'},
              {'label': AppLocalizations.of(context)!.redo, 'win': 'Ctrl + Y', 'mac': '⌘ + Y'},
              {'label': AppLocalizations.of(context)!.focusMode, 'win': 'F11', 'mac': 'F11'},
              {'label': AppLocalizations.of(context)!.showPreview, 'win': 'Ctrl + Shift + H', 'mac': '⌘ + ⇧ + H'},
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('CONTENT CREATION'),
            const SizedBox(height: 12),
            _buildShortcutGroup(context, [
              {'label': AppLocalizations.of(context)!.addHeading, 'win': 'Ctrl + Alt + 1', 'mac': '⌃ + ⌥ + 1'},
              {'label': AppLocalizations.of(context)!.addParagraph, 'win': 'Ctrl + Alt + 3', 'mac': '⌃ + ⌥ + 3'},
              {'label': AppLocalizations.of(context)!.addImage, 'win': 'Ctrl + Alt + I', 'mac': '⌃ + ⌥ + I'},
              {'label': AppLocalizations.of(context)!.addTable, 'win': 'Ctrl + Alt + T', 'mac': '⌃ + ⌥ + T'},
              {'label': AppLocalizations.of(context)!.addLink, 'win': 'Ctrl + Alt + K', 'mac': '⌃ + ⌥ + K'},
            ]),
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5),
    );
  }

  Widget _buildShortcutGroup(BuildContext context, List<Map<String, String>> shortcuts) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: shortcuts.map((s) => _buildShortcutRow(context, s['label']!, s['win']!, s['mac']!)).toList(),
      ),
    );
  }

  Widget _buildShortcutRow(BuildContext context, String label, String windowsKey, String macKey) {
    final isMac = Theme.of(context).platform == TargetPlatform.macOS;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withAlpha(10))),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500))),
          _buildKeyBadge(context, isMac ? macKey : windowsKey),
        ],
      ),
    );
  }

  Widget _buildKeyBadge(BuildContext context, String keys) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.white.withAlpha(150),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withAlpha(30)),
      ),
      child: Text(
        keys,
        style: GoogleFonts.firaCode(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
