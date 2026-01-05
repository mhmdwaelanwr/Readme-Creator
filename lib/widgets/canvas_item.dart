import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/readme_element.dart';
import '../providers/library_provider.dart';
import '../providers/project_provider.dart';
import 'element_renderer.dart';
import '../core/constants/app_colors.dart';
import '../utils/dialog_helper.dart';

class CanvasItem extends StatefulWidget {
  final ReadmeElement element;
  final bool isSelected;

  const CanvasItem({
    super.key,
    required this.element,
    required this.isSelected,
  });

  @override
  State<CanvasItem> createState() => _CanvasItemState();
}

class _CanvasItemState extends State<CanvasItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => provider.selectElement(widget.element.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? colorScheme.primary.withAlpha(isDark ? 30 : 10)
                : (_isHovered ? (isDark ? Colors.white.withAlpha(5) : Colors.black.withAlpha(5)) : Colors.transparent),
            border: Border.all(
              color: widget.isSelected
                  ? colorScheme.primary
                  : (_isHovered ? colorScheme.primary.withAlpha(100) : Colors.transparent),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: ElementRenderer(element: widget.element),
              ),
              if (_isHovered || widget.isSelected)
                Positioned(
                  right: 8,
                  top: 8,
                  child: AnimatedOpacity(
                    opacity: _isHovered || widget.isSelected ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.canvasBackgroundDark : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(color: isDark ? Colors.white.withAlpha(20) : Colors.grey.withAlpha(30)),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildActionButton(
                            icon: Icons.arrow_upward,
                            tooltip: 'Move Up',
                            onPressed: () => provider.moveElementUp(widget.element.id),
                            colorScheme: colorScheme,
                          ),
                          _buildActionButton(
                            icon: Icons.arrow_downward,
                            tooltip: 'Move Down',
                            onPressed: () => provider.moveElementDown(widget.element.id),
                            colorScheme: colorScheme,
                          ),
                          Container(
                            height: 16,
                            width: 1,
                            color: isDark ? Colors.white.withAlpha(20) : Colors.grey.withAlpha(30),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          _buildActionButton(
                            icon: Icons.copy,
                            tooltip: 'Duplicate',
                            onPressed: () => provider.duplicateElement(widget.element.id),
                            colorScheme: colorScheme,
                          ),
                          _buildActionButton(
                            icon: Icons.save_as,
                            tooltip: 'Save as Snippet',
                            onPressed: () => _showSaveSnippetDialog(context, widget.element),
                            colorScheme: colorScheme,
                          ),
                          _buildActionButton(
                            icon: Icons.delete_outline,
                            tooltip: 'Delete',
                            onPressed: () => provider.removeElement(widget.element.id),
                            color: AppColors.error,
                            colorScheme: colorScheme,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required ColorScheme colorScheme,
    Color? color,
  }) {
    return IconButton(
      icon: Icon(icon, size: 16),
      onPressed: onPressed,
      tooltip: tooltip,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(),
      splashRadius: 20,
      color: color ?? colorScheme.onSurface.withAlpha(180),
      hoverColor: (color ?? colorScheme.primary).withAlpha(20),
    );
  }

  void _showSaveSnippetDialog(BuildContext context, ReadmeElement element) {
    final nameController = TextEditingController(text: element.description);
    showSafeDialog(
      context,
      builder: (context) => AlertDialog(
        title: Text('Save as Snippet', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Snippet Name',
            border: OutlineInputBorder(),
          ),
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Provider.of<LibraryProvider>(context, listen: false).saveSnippet(
                  name: nameController.text,
                  elementJson: jsonEncode(element.toJson()),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Snippet saved!')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
