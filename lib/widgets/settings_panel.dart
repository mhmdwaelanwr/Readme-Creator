import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../models/readme_element.dart';
import '../providers/project_provider.dart';
import '../generator/markdown_generator.dart';
import 'element_settings_form.dart';

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 2,
      child: Container(
        color: colorScheme.surface,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Settings'),
                Tab(text: 'Preview'),
              ],
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select an element from the canvas to edit its properties, or drag a new component from the left panel.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onSurface.withAlpha(150)),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withAlpha(50),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.primary.withAlpha(50)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit ${element.description}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_upward),
                      onPressed: () => _moveElement(provider, element, -1),
                      tooltip: 'Move Up',
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward),
                      onPressed: () => _moveElement(provider, element, 1),
                      tooltip: 'Move Down',
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
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

  void _moveElement(ProjectProvider provider, ReadmeElement element, int direction) {
    final index = provider.elements.indexOf(element);
    if (index == -1) return;

    final newIndex = index + direction;
    if (newIndex >= 0 && newIndex < provider.elements.length) {
      if (direction == 1) {
         // Moving Down
         // To move item at i to i+1, we need to insert it at i+2 (because removing i shifts everything)
         // reorderElements(i, i+2) handles the shift logic (if old < new, new -= 1)
         provider.reorderElements(index, index + 2);
      } else {
         // Moving Up
         // To move item at i to i-1, we insert at i-1.
         // reorderElements(i, i-1) -> old > new -> no shift logic applied.
         provider.reorderElements(index, index - 1);
      }
    }
  }

  Widget _buildPreviewTab(BuildContext context) {
    final provider = Provider.of<ProjectProvider>(context);
    final generator = MarkdownGenerator();
    final markdown = generator.generate(provider.elements);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(16),
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC), // Slate 900 / Slate 50
          child: SingleChildScrollView(
            child: SelectableText(
              markdown,
              style: TextStyle(
                fontFamily: 'monospace',
                color: colorScheme.onSurface,
                fontSize: 13,
              ),
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: FloatingActionButton.small(
            tooltip: 'Copy to Clipboard',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: markdown));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
            },
            child: const Icon(Icons.copy),
          ),
        ),
      ],
    );
  }
}
