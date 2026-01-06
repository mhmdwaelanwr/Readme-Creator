import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/dialog_helper.dart';

class KeyboardShortcutsDialog extends StatelessWidget {
  const KeyboardShortcutsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return StyledDialog(
      title: DialogHeader(
        title: AppLocalizations.of(context)!.keyboardShortcuts,
        icon: Icons.keyboard,
        color: Colors.grey,
      ),
      content: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${AppLocalizations.of(context)!.commonShortcuts}:', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildShortcutRow(context, AppLocalizations.of(context)!.newProject, 'Ctrl + N', '⌘ + N'),
            _buildShortcutRow(context, AppLocalizations.of(context)!.openProject, 'Ctrl + O', '⌘ + O'),
            _buildShortcutRow(context, AppLocalizations.of(context)!.saveProject, 'Ctrl + S', '⌘ + S'),
            _buildShortcutRow(context, AppLocalizations.of(context)!.exportProject, 'Ctrl + E', '⌘ + E'),
            _buildShortcutRow(context, AppLocalizations.of(context)!.print, 'Ctrl + P', '⌘ + P'),
            _buildShortcutRow(context, AppLocalizations.of(context)!.undo, 'Ctrl + Z', '⌘ + Z'),
            _buildShortcutRow(context, AppLocalizations.of(context)!.redo, 'Ctrl + Y', '⌘ + Y'),
            _buildShortcutRow(context, AppLocalizations.of(context)!.focusMode, 'F11', 'F11'),
            _buildShortcutRow(context, AppLocalizations.of(context)!.showPreview, 'Ctrl + Shift + H', '⌘ + Shift + H'),
            _buildShortcutRow(context, AppLocalizations.of(context)!.toggleGrid, 'Ctrl + G', '⌘ + G'),
            _buildShortcutRow(context, AppLocalizations.of(context)!.toggleTheme, 'Ctrl + T', '⌘ + T'),
            _buildShortcutRow(context, AppLocalizations.of(context)!.openSettings, 'Ctrl + ,', '⌘ + ,'),
            _buildShortcutRow(context, AppLocalizations.of(context)!.help, 'F1', 'F1'),
            const SizedBox(height: 16),
            Text('${AppLocalizations.of(context)!.elementShortcuts}:', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildShortcutRow(context, AppLocalizations.of(context)!.addHeading, 'Ctrl + Alt + 1', '⌘ + Option + 1'),
            _buildShortcutRow(context, AppLocalizations.of(context)!.addSubheading, 'Ctrl + Alt + 2', '⌘ + Option + 2'),
            _buildShortcutRow(context, AppLocalizations.of(context)!.addParagraph, 'Ctrl + Alt + 3', '⌘ + Option + 3'),
            _buildShortcutRow(context, AppLocalizations.of(context)!.addImage, 'Ctrl + Alt + I', '⌘ + Option + I'),
            _buildShortcutRow(context, AppLocalizations.of(context)!.addTable, 'Ctrl + Alt + T', '⌘ + Option + T'),
            _buildShortcutRow(context, AppLocalizations.of(context)!.addList, 'Ctrl + Alt + L', '⌘ + Option + L'),
            _buildShortcutRow(context, AppLocalizations.of(context)!.addQuote, 'Ctrl + Alt + Q', '⌘ + Option + Q'),
            _buildShortcutRow(context, AppLocalizations.of(context)!.addLink, 'Ctrl + Alt + K', '⌘ + Option + K'),
          ],
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

  Widget _buildShortcutRow(BuildContext context, String label, String windowsKey, String macKey) {
    final isMac = Theme.of(context).platform == TargetPlatform.macOS;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              isMac ? macKey : windowsKey,
              style: GoogleFonts.firaCode(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

