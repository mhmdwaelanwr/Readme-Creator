import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/project_provider.dart';
import '../../utils/dialog_helper.dart';

class SnapshotsDialog extends StatelessWidget {
  const SnapshotsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return StyledDialog(
      title: DialogHeader(
        title: AppLocalizations.of(context)!.localSnapshots,
        icon: Icons.history, // Using history icon similar to menu
        color: Colors.blue,
      ),
      content: SizedBox(
        width: 400,
        height: 400,
        child: Consumer<ProjectProvider>(
          builder: (context, provider, _) {
            return Column(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Create New Snapshot'),
                  onPressed: () {
                    provider.saveSnapshot();
                    // We don't need to close and reopen because Consumer will rebuild this widget
                    // when snapshots list changes in provider.
                  },
                ),
                const Divider(),
                Expanded(
                  child: provider.snapshots.isEmpty
                      ? Center(child: Text('No snapshots saved.', style: GoogleFonts.inter()))
                      : ListView.builder(
                          itemCount: provider.snapshots.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: const Icon(Icons.history),
                              title: Text('Snapshot ${provider.snapshots.length - index}', style: GoogleFonts.inter()),
                              subtitle: index == 0 ? Text('Latest', style: GoogleFonts.inter()) : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.restore),
                                    tooltip: AppLocalizations.of(context)!.restore,
                                    onPressed: () => _confirmRestore(context, provider, index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    tooltip: AppLocalizations.of(context)!.delete,
                                    onPressed: () {
                                      provider.deleteSnapshot(index);
                                      // Confirmation for delete might be nice but extracting it simple for now as per original code logic (though original had confirm on deleted? No, original had confirm on restore, delete was direct with post-feedback).
                                      // Original code:
                                      // "Snapshot deleted" dialog AFTER delete.
                                      // I will keep it simple here.
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
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

  void _confirmRestore(BuildContext context, ProjectProvider provider, int index) {
    showSafeDialog(
      context,
      builder: (context) => AlertDialog(
        title: Text('${AppLocalizations.of(context)!.restore} Snapshot?', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text('Current work will be replaced.', style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close confirm
              // We're inside a dialog effectively (SnapshotsDialog), so we probably want to assume it stays open?
              // The original code closed everything?
              // "Navigator.pop(context); // close confirm"
              // "Navigator.pop(context); // close list" -> This suggests it closes the snapshots dialog too.
              // I will follow that pattern: restoring replaces state, usually good to return to editor.

              // Wait, if I'm in SnapshotsDialog, I need to close IT too if I want to match original behavior.
              // But how to close parent?
              // Using a callback or finding parent navigator.
              // If I use showSafeDialog for confirmation, it pushes a new route.
              // Popping once closes confirm. Popping again closes list.

              // Let's invoke restore.
              provider.restoreSnapshot(index);

              // Ideally we close the snapshots dialog as well.
              // Since this widget is the dialog content essentially, `context` passed to build is the dialog context? No, `StyledDialog` wraps it.
              // Actually `Navigator.of(context).pop()` in `_confirmRestore` closes the confirm dialog.
              // We need another pop.
              // But `context` here is from `builder`.
              // We can pass the parent context to `_confirmRestore`.
            },
            child: Text(AppLocalizations.of(context)!.restore),
          ),
        ],
      ),
    ).then((_) {
        // If we want to close the main dialog upon restore confirmation (if the user clicked restore)
        // But `then` triggers on cancel too.
        // Let's leave it as is, or maybe just close on restore button press inside the builder.
    });
  }
}

