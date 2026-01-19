import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/library_provider.dart';
import '../../providers/project_provider.dart';
import '../../utils/dialog_helper.dart';
import '../../utils/toast_helper.dart';
import '../../core/constants/app_colors.dart';

class SaveToLibraryDialog extends StatefulWidget {
  const SaveToLibraryDialog({super.key});

  @override
  State<SaveToLibraryDialog> createState() => _SaveToLibraryDialogState();
}

class _SaveToLibraryDialogState extends State<SaveToLibraryDialog> {
  late TextEditingController _nameController;
  final _descController = TextEditingController();
  final _tagsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ProjectProvider>(context, listen: false);
    _nameController = TextEditingController(text: provider.variables['PROJECT_NAME'] ?? 'My Project');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StyledDialog(
      title: DialogHeader(
        title: AppLocalizations.of(context)!.saveToLibrary,
        icon: Icons.save_rounded,
        color: Colors.blue,
      ),
      width: 550,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GlassCard(
              opacity: 0.1,
              color: Colors.blue,
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.blue, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Store your current progress in the local library. You can restore it anytime from the Projects screen.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('PROJECT DETAILS'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _nameController,
              label: AppLocalizations.of(context)!.projectName,
              icon: Icons.title_rounded,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descController,
              label: AppLocalizations.of(context)!.description,
              icon: Icons.description_rounded,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _tagsController,
              label: AppLocalizations.of(context)!.tags,
              icon: Icons.label_rounded,
              hint: 'flutter, readme, docs',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.grey)),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: () => _save(context),
          icon: const Icon(Icons.check_circle_rounded, size: 18),
          label: Text(AppLocalizations.of(context)!.save, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
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
      style: GoogleFonts.inter(fontSize: 14),
    );
  }

  void _save(BuildContext context) {
    if (_nameController.text.isEmpty) {
      ToastHelper.show(context, 'Project name is required', isError: true);
      return;
    }
    final provider = Provider.of<ProjectProvider>(context, listen: false);
    final libraryProvider = Provider.of<LibraryProvider>(context, listen: false);
    final tags = _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    libraryProvider.saveProject(
      name: _nameController.text,
      description: _descController.text,
      tags: tags,
      jsonContent: provider.exportToJson(),
    );

    Navigator.pop(context);
    ToastHelper.show(context, AppLocalizations.of(context)!.projectSaved);
  }
}
