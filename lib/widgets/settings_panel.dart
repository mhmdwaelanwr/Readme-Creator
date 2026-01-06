import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/project_provider.dart';
import '../generator/markdown_generator.dart';
import 'element_settings_form.dart';
import '../core/constants/app_colors.dart';

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 2,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.7),
              border: Border(left: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: TabBar(
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Theme.of(context).primaryColor,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'Settings'),
                      Tab(text: 'Preview'),
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
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withAlpha(50),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.tune, size: 64, color: colorScheme.primary.withAlpha(150)),
              ),
              const SizedBox(height: 24),
              Text(
                'No Element Selected',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select an element from the canvas to edit its properties, or drag a new component from the left panel.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: colorScheme.onSurface.withAlpha(150)),
              ),
            ],
          ),
        ),
      );
    }

    // Use Key to force rebuild when selection changes
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: ListView(
        key: ValueKey(element.id),
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withAlpha(50),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.primary.withAlpha(50)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Edit ${element.description}',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.primary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_upward),
                      tooltip: 'Move Up',
                      onPressed: () => provider.moveElementUp(element.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward),
                      tooltip: 'Move Down',
                      onPressed: () => provider.moveElementDown(element.id),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: colorScheme.error,
                      tooltip: 'Delete Element',
                      onPressed: () => provider.removeElement(element.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElementSettingsForm(element: element),
        ],
      ),
    );
  }

  Widget _buildPreviewTab(BuildContext context) {
    final provider = Provider.of<ProjectProvider>(context);
    final element = provider.selectedElement;

    if (element == null) {
      return Center(child: Text('Select an element to preview code', style: GoogleFonts.inter(color: Colors.grey)));
    }

    final generator = MarkdownGenerator();
    // Generate markdown for just this element
    final markdown = generator.generate([element]);

    return Container(
      color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkBackground : AppColors.lightBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Markdown Source', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  tooltip: 'Copy to Clipboard',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: markdown));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!')));
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                markdown,
                style: GoogleFonts.firaCode(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
