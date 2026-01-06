import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/project_provider.dart';
import '../../utils/dialog_helper.dart';
import '../../utils/downloader.dart';
import '../../utils/toast_helper.dart';
import '../../generator/file_generators.dart';

class ExtraFilesDialog extends StatelessWidget {
  const ExtraFilesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // We only need provider for data access like variables and license type
    final provider = Provider.of<ProjectProvider>(context, listen: false);

    return StyledDialog(
      title: const DialogHeader(
        title: 'Generate Extra Files',
        icon: Icons.library_add,
        color: Colors.deepOrange,
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.gavel),
                title: const Text('LICENSE'),
                subtitle: const Text('Generate a standard license file.'),
                onTap: () {
                  Navigator.pop(context);
                  final content = FileGenerators.generateLicense(
                      provider.licenseType, provider.variables['GITHUB_USERNAME'] ?? 'Author');
                  downloadTextFile(content, 'LICENSE');
                },
              ),
              ListTile(
                leading: const Icon(Icons.handshake),
                title: const Text('CONTRIBUTING.md'),
                subtitle: const Text('Guidelines for contributors.'),
                onTap: () {
                  Navigator.pop(context);
                  final content = FileGenerators.generateContributing(provider.variables);
                  downloadTextFile(content, 'CONTRIBUTING.md');
                },
              ),
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('SECURITY.md'),
                subtitle: const Text('Security policy.'),
                onTap: () {
                  Navigator.pop(context);
                  final content = FileGenerators.generateSecurity(provider.variables);
                  downloadTextFile(content, 'SECURITY.md');
                },
              ),
              ListTile(
                leading: const Icon(Icons.rule),
                title: const Text('CODE_OF_CONDUCT.md'),
                subtitle: const Text('Contributor Covenant Code of Conduct.'),
                onTap: () {
                  Navigator.pop(context);
                  final content = FileGenerators.generateCodeOfConduct(provider.variables);
                  downloadTextFile(content, 'CODE_OF_CONDUCT.md');
                },
              ),
              ListTile(
                leading: const Icon(Icons.bug_report),
                title: const Text('Issue Templates'),
                subtitle: const Text('Bug report and feature request templates.'),
                onTap: () {
                  Navigator.pop(context);
                  final bugReport = FileGenerators.generateBugReportTemplate();
                  final featureRequest = FileGenerators.generateFeatureRequestTemplate();
                  downloadTextFile(bugReport, 'bug_report.md');
                  downloadTextFile(featureRequest, 'feature_request.md');
                  ToastHelper.show(context, 'Templates downloaded');
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

