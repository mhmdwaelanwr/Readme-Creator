import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        onTap: () {
          HapticFeedback.lightImpact();
          provider.selectElement(widget.element.id);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: 12),
          transform: Matrix4.identity()..translate(_isHovered ? 4.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? colorScheme.primary.withAlpha(isDark ? 25 : 8)
                : (_isHovered ? (isDark ? Colors.white.withAlpha(8) : Colors.black.withAlpha(4)) : Colors.transparent),
            border: Border.all(
              color: widget.isSelected
                  ? colorScheme.primary
                  : (_isHovered ? colorScheme.primary.withAlpha(80) : Colors.transparent),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isHovered && !widget.isSelected ? [
              BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4))
            ] : null,
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElementRenderer(element: widget.element),
              ),
              if (_isHovered || widget.isSelected)
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                      border: Border.all(color: isDark ? Colors.white.withAlpha(15) : Colors.grey.withAlpha(20)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionButton(
                          icon: Icons.keyboard_arrow_up_rounded,
                          tooltip: 'Move Up',
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            provider.moveElementUp(widget.element.id);
                          },
                          colorScheme: colorScheme,
                        ),
                        _buildActionButton(
                          icon: Icons.keyboard_arrow_down_rounded,
                          tooltip: 'Move Down',
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            provider.moveElementDown(widget.element.id);
                          },
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(width: 4),
                        _buildActionButton(
                          icon: Icons.copy_all_rounded,
                          tooltip: 'Duplicate',
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            provider.duplicateElement(widget.element.id);
                          },
                          colorScheme: colorScheme,
                        ),
                        _buildActionButton(
                          icon: Icons.delete_sweep_rounded,
                          tooltip: 'Remove',
                          onPressed: () {
                            HapticFeedback.heavyImpact();
                            provider.removeElement(widget.element.id);
                          },
                          color: Colors.redAccent,
                          colorScheme: colorScheme,
                        ),
                      ],
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
      icon: Icon(icon, size: 18),
      onPressed: onPressed,
      tooltip: tooltip,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
      splashRadius: 24,
      color: color ?? colorScheme.onSurface.withAlpha(200),
    );
  }
}
