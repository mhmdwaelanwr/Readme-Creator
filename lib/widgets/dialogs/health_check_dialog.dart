import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/project_provider.dart';
import '../../services/health_check_service.dart';
import '../../utils/dialog_helper.dart';

class HealthCheckDialog extends StatelessWidget {
  final List<HealthIssue> issues;
  final ProjectProvider provider;

  const HealthCheckDialog({
    super.key,
    required this.issues,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return StyledDialog(
      title: const DialogHeader(
        title: 'Health Check',
        icon: Icons.health_and_safety,
        color: Colors.redAccent,
      ),
      content: SizedBox(
        width: 400,
        height: 300,
        child: issues.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, size: 48, color: Colors.green),
                    const SizedBox(height: 16),
                    Text(AppLocalizations.of(context)!.healthy, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: issues.length,
                itemBuilder: (context, index) {
                  final issue = issues[index];
                  return ListTile(
                    leading: Icon(
                      issue.severity == IssueSeverity.error ? Icons.error : (issue.severity == IssueSeverity.warning ? Icons.warning : Icons.info),
                      color: issue.severity == IssueSeverity.error ? Colors.red : (issue.severity == IssueSeverity.warning ? Colors.orange : Colors.blue),
                    ),
                    title: Text(issue.message, style: GoogleFonts.inter(fontSize: 14)),
                    trailing: issue.elementId != null
                        ? IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: () {
                              provider.selectElement(issue.elementId!);
                              Navigator.pop(context);
                            },
                          )
                        : null,
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
}

