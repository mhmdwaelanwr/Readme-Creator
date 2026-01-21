import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/project_provider.dart';
import '../models/readme_element.dart';
import '../generator/markdown_generator.dart';
import 'element_settings_form.dart';
import '../core/constants/app_colors.dart';

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackground.withOpacity(0.8) : colorScheme.surface.withOpacity(0.8),
              border: Border(left: BorderSide(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05))),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent, 
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: AppColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min, // Added to prevent overflow
                          children: const [
                            Icon(Icons.tune_rounded, size: 16), // Reduced size slightly
                            SizedBox(width: 4), // Reduced spacing
                            Flexible(child: Text('Settings', overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min, // Added to prevent overflow
                          children: const [
                            Icon(Icons.code_rounded, size: 16), // Reduced size slightly
                            SizedBox(width: 4), // Reduced spacing
                            Flexible(child: Text('Preview', overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildSettingsTab(context),
                      _buildPreviewTab(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTab(BuildContext context) {
    final provider = Provider.of<ProjectProvider>(context);
    final element = provider.selectedElement;
    final colorScheme = Theme.of(context).colorScheme;

    if (element == null) {
      return Center(
        child: SingleChildScrollView( // Added ScrollView to prevent vertical overflow
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.touch_app_outlined, size: 64, color: AppColors.primary.withOpacity(0.8)),
                ),
                const SizedBox(height: 24),
                Text(
                  'No Element Selected',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Select an element from the canvas to edit its properties.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: colorScheme.onSurface.withOpacity(0.6), height: 1.5),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: ListView(
        key: ValueKey(element.id),
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12), // Reduced padding
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 14, // Reduced radius
                  child: Icon(_getElementIcon(element.type), size: 14, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    element.description,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildActionButtons(context, provider, element.id),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElementSettingsForm(element: element),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ProjectProvider provider, String elementId) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          constraints: const BoxConstraints(), // To fit in tight spaces
          padding: const EdgeInsets.all(4),
          icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 18),
          onPressed: () => provider.moveElementUp(elementId),
          visualDensity: VisualDensity.compact,
        ),
        IconButton(
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(4),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          onPressed: () => provider.moveElementDown(elementId),
          visualDensity: VisualDensity.compact,
        ),
        IconButton(
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(4),
          icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent, size: 18),
          onPressed: () => provider.removeElement(elementId),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  IconData _getElementIcon(ReadmeElementType type) {
    switch (type) {
      case ReadmeElementType.heading: return Icons.title_rounded;
      case ReadmeElementType.paragraph: return Icons.notes_rounded;
      case ReadmeElementType.image: return Icons.image_rounded;
      case ReadmeElementType.linkButton: return Icons.link_rounded;
      case ReadmeElementType.codeBlock: return Icons.code_rounded;
      case ReadmeElementType.list: return Icons.list_rounded;
      case ReadmeElementType.badge: return Icons.verified_rounded;
      case ReadmeElementType.table: return Icons.table_chart_rounded;
      case ReadmeElementType.icon: return Icons.category_rounded;
      default: return Icons.extension_rounded;
    }
  }

  Widget _buildPreviewTab(BuildContext context) {
    final provider = Provider.of<ProjectProvider>(context);
    final element = provider.selectedElement;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (element == null) {
      return Center(
        child: Text(
          'Select an element to preview code',
          style: GoogleFonts.inter(color: Colors.grey.shade500),
        ),
      );
    }

    final generator = MarkdownGenerator();
    final markdown = generator.generate([element]);

    return Container(
      color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F8FA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.03),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible( // Added Flexible to prevent text overflow
                  child: Text(
                    'MARKDOWN SOURCE',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      color: Colors.grey.shade600,
                      letterSpacing: 1.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: markdown));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to Clipboard')),
                    );
                  },
                  icon: const Icon(Icons.copy_all_rounded, size: 14),
                  label: const Text('Copy', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: SelectableText(
                markdown,
                style: GoogleFonts.firaCode(
                  fontSize: 14,
                  color: isDark ? const Color(0xFFC9D1D9) : const Color(0xFF24292F),
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
