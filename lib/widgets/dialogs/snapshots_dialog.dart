import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/project_provider.dart';
import '../../utils/dialog_helper.dart';
import '../../core/constants/app_colors.dart';
import 'confirm_dialog.dart';

class SnapshotsDialog extends StatelessWidget {
  const SnapshotsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return StyledDialog(
      title: DialogHeader(
        title: AppLocalizations.of(context)!.localSnapshots,
        icon: Icons.history_rounded,
        color: Colors.blue,
      ),
      width: 550,
      height: 500,
      content: Column(
        children: [
          _buildActionHeader(context),
          const SizedBox(height: 20),
          _buildSectionTitle('SAVED STATES'),
          const SizedBox(height: 12),
          Expanded(
            child: Consumer<ProjectProvider>(
              builder: (context, provider, _) {
                if (provider.snapshots.isEmpty) return _buildEmptyState();
                return ListView.builder(
                  itemCount: provider.snapshots.length,
                  itemBuilder: (context, index) {
                    return _buildSnapshotItem(context, provider, index);
                  },
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.close, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildActionHeader(BuildContext context) {
    return GlassCard(
      opacity: 0.1,
      color: Colors.blue,
      child: Row(
        children: [
          const Icon(Icons.manage_history_rounded, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Instant Backup', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Create a restore point of your current project.', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => Provider.of<ProjectProvider>(context, listen: false).saveSnapshot(),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildSnapshotItem(BuildContext context, ProjectProvider provider, int index) {
    final reverseIndex = provider.snapshots.length - index;
    return GlassCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.blue.withAlpha(20), borderRadius: BorderRadius.circular(8)),
          child: Text('#$reverseIndex', style: GoogleFonts.firaCode(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
        ),
        title: Text('Snapshot $reverseIndex', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        subtitle: index == 0 ? Text('Latest Version', style: GoogleFonts.inter(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.restore_rounded, color: Colors.blue),
              onPressed: () => _confirmRestore(context, provider, index),
              tooltip: 'Restore',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              onPressed: () => provider.deleteSnapshot(index),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_rounded, size: 48, color: Colors.grey.withAlpha(100)),
          const SizedBox(height: 16),
          Text('No snapshots yet', style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5),
      ),
    );
  }

  void _confirmRestore(BuildContext context, ProjectProvider provider, int index) {
    showSafeDialog(
      context,
      builder: (context) => ConfirmDialog(
        title: 'Restore Snapshot?',
        content: 'Your current work will be replaced with this saved state. This action cannot be undone.',
        confirmText: 'Restore Now',
        onConfirm: () => provider.restoreSnapshot(index),
        isDestructive: true,
      ),
    );
  }
}
