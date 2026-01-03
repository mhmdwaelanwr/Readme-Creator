import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/readme_element.dart';
import '../providers/library_provider.dart';
import '../providers/project_provider.dart';
import 'element_renderer.dart';

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

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => provider.selectElement(widget.element.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: widget.isSelected ? Colors.blue.withAlpha(10) : Colors.transparent,
            border: Border.all(
              color: widget.isSelected
                  ? Colors.blue
                  : (_isHovered ? Colors.blue.withAlpha(100) : Colors.transparent),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
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
                        color: isDark ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(25),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(color: Colors.grey.withAlpha(30)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_upward, size: 16),
                            onPressed: () => provider.moveElementUp(widget.element.id),
                            tooltip: 'Move Up',
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                            splashRadius: 16,
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_downward, size: 16),
                            onPressed: () => provider.moveElementDown(widget.element.id),
                            tooltip: 'Move Down',
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                            splashRadius: 16,
                          ),
                          Container(
                            height: 16,
                            width: 1,
                            color: Colors.grey.withAlpha(50),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 16),
                            onPressed: () => provider.duplicateElement(widget.element.id),
                            tooltip: 'Duplicate',
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                            splashRadius: 16,
                          ),
                          IconButton(
                            icon: const Icon(Icons.save_as, size: 16),
                            onPressed: () => _showSaveSnippetDialog(context, widget.element),
                            tooltip: 'Save as Snippet',
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                            splashRadius: 16,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                            onPressed: () => provider.removeElement(widget.element.id),
                            tooltip: 'Delete',
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                            splashRadius: 16,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.0),
                            child: Icon(Icons.drag_handle, size: 16, color: Colors.grey),
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

  void _showSaveSnippetDialog(BuildContext context, ReadmeElement element) {
    final nameController = TextEditingController(text: element.description);
    showDialog(
      context: context,
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
