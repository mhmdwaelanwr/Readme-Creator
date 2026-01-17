import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../utils/templates.dart';
import '../providers/project_provider.dart';
import '../generator/markdown_generator.dart';
import '../core/constants/app_colors.dart';
import '../utils/dialog_helper.dart';
import '../utils/toast_helper.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Combine local and cloud templates
    final allTemplates = provider.allTemplates;

    return Scaffold(
      backgroundColor: isDark ? AppColors.editorBackgroundDark : AppColors.editorBackgroundLight,
      appBar: AppBar(
        title: Text('Design Showcase', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSection(isDark),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 : (MediaQuery.of(context).size.width > 800 ? 2 : 1),
                childAspectRatio: 0.85,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
              ),
              itemCount: allTemplates.length,
              itemBuilder: (context, index) {
                final template = allTemplates[index];
                // Detect if it's a cloud template (not in local Templates.all)
                final isCloud = !Templates.all.any((t) => t.name == template.name);
                return _buildTemplateCard(context, template, isDark, isCloud);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore Templates',
            style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5),
          ),
          Text(
            'Jumpstart your documentation with professional layouts.',
            style: GoogleFonts.inter(color: Colors.grey, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, ProjectTemplate template, bool isDark, bool isCloud) {
    final markdown = MarkdownGenerator().generate(template.elements);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: isDark ? AppColors.socialPreviewDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: isCloud ? AppColors.primary.withAlpha(80) : Colors.grey.withAlpha(30), width: isCloud ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dynamic Preview Area
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black.withAlpha(40) : Colors.grey.withAlpha(10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AbsorbPointer(
                      child: Markdown(
                        data: markdown,
                        shrinkWrap: true,
                        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                          p: GoogleFonts.inter(fontSize: 8),
                          h1: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                          h2: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                if (isCloud)
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [BoxShadow(color: AppColors.primary.withAlpha(100), blurRadius: 8)],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud_done_rounded, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text('CLOUD', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Info Area
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.name,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  template.description,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _confirmLoad(context, template),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCloud ? AppColors.primary : null,
                      foregroundColor: isCloud ? Colors.white : null,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Use This Template', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLoad(BuildContext context, ProjectTemplate template) {
    final provider = Provider.of<ProjectProvider>(context, listen: false);
    showSafeDialog(
      context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Apply ${template.name}?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: const Text('This will replace your current workspace elements. Proceed?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              provider.loadTemplate(template);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close gallery
              ToastHelper.show(context, 'Template Applied!');
            },
            child: const Text('Load Template'),
          ),
        ],
      ),
    );
  }
}
