import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/readme_element.dart';
import '../models/snippet.dart';
import '../providers/project_provider.dart';
import '../utils/templates.dart';
import 'canvas_item.dart';

class EditorCanvas extends StatelessWidget {
  const EditorCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    double maxWidth = 850;
    if (provider.deviceMode == DeviceMode.tablet) {
      maxWidth = 600;
    } else if (provider.deviceMode == DeviceMode.mobile) {
      maxWidth = 400;
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true): () => provider.undo(),
        const SingleActivator(LogicalKeyboardKey.keyY, control: true): () => provider.redo(),
        const SingleActivator(LogicalKeyboardKey.delete): () {
          if (provider.selectedElementId != null) {
            provider.removeElement(provider.selectedElementId!);
          }
        },
      },
      child: Focus(
        autofocus: true,
        child: DragTarget<Object>(
          onWillAcceptWithDetails: (details) => details.data is ReadmeElementType || details.data is Snippet,
          onAcceptWithDetails: (details) {
            if (details.data is ReadmeElementType) {
              provider.addElement(details.data as ReadmeElementType);
            } else if (details.data is Snippet) {
              provider.addSnippet(details.data as Snippet);
            }
          },
          builder: (context, candidateData, rejectedData) {
            final colorScheme = Theme.of(context).colorScheme;
            return Container(
              color: candidateData.isNotEmpty
                  ? colorScheme.primary.withAlpha(30)
                  : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)), // Slate 900 / Slate 100
              child: Stack(
                children: [
                  if (provider.showGrid)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: GridPainter(isDark: isDark),
                      ),
                    ),

                  Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: GestureDetector(
                        onTap: () => provider.selectElement(''), // Deselect
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white, // Slate 800 / White
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(isDark ? 100 : 20),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(
                              color: isDark ? Colors.white.withAlpha(10) : Colors.grey.withAlpha(20),
                            ),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Stack(
                            children: [
                              if (provider.showGrid)
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: GridPainter(isDark: isDark),
                                  ),
                                ),
                              provider.elements.isEmpty
                                  ? _buildEmptyState(context)
                                  : ReorderableListView.builder(
                                      padding: const EdgeInsets.all(32),
                                      itemCount: provider.elements.length,
                                      onReorder: provider.reorderElements,
                                      proxyDecorator: (child, index, animation) => _proxyDecorator(child, index, animation, isDark),
                                      itemBuilder: (context, index) {
                                        final element = provider.elements[index];
                                        final isSelected = element.id == provider.selectedElementId;

                                        return KeyedSubtree(
                                          key: ValueKey(element.id),
                                          child: DropZone(
                                            onDrop: (data) {
                                              if (data is ReadmeElementType) {
                                                provider.insertElement(index, data);
                                              } else if (data is Snippet) {
                                                provider.insertSnippet(index, data);
                                              }
                                            },
                                            child: CanvasItem(
                                              element: element,
                                              isSelected: isSelected,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Toolbar
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black87 : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 8, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.undo, size: 20),
                              tooltip: 'Undo (Ctrl+Z)',
                              onPressed: provider.undo, // We need to expose canUndo to disable
                            ),
                            IconButton(
                              icon: const Icon(Icons.redo, size: 20),
                              tooltip: 'Redo (Ctrl+Y)',
                              onPressed: provider.redo,
                            ),
                            const SizedBox(width: 8, height: 20, child: VerticalDivider()),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                              tooltip: 'Delete Selected (Del)',
                              onPressed: provider.selectedElementId != null
                                  ? () => provider.removeElement(provider.selectedElementId!)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = Provider.of<ProjectProvider>(context, listen: false);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withAlpha(50),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.drag_indicator, size: 48, color: colorScheme.primary.withAlpha(150)),
          ),
          const SizedBox(height: 24),
          Text(
            'Drag components here',
            style: GoogleFonts.inter(
              fontSize: 18,
              color: colorScheme.onSurface.withAlpha(200),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start building your README',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: colorScheme.onSurface.withAlpha(150),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.file_copy_outlined),
            label: const Text('Load a Template'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Choose a Template', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  content: SizedBox(
                    width: 400,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: Templates.all.length,
                      itemBuilder: (context, index) {
                        final template = Templates.all[index];
                        return ListTile(
                          title: Text(template.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                          subtitle: Text(template.description, style: GoogleFonts.inter(fontSize: 12)),
                          onTap: () {
                            provider.loadTemplate(template);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation, bool isDark) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 6, animValue)!;
        return Material(
          elevation: elevation,
          color: isDark ? Colors.grey[800] : Colors.white,
          shadowColor: Colors.black.withAlpha(50),
          borderRadius: BorderRadius.circular(8),
          child: child,
        );
      },
      child: child,
    );
  }
}

class GridPainter extends CustomPainter {
  final bool isDark;

  GridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withAlpha(30)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const double gridSize = 20.0;

    for (double x = 0; x < size.width; x += gridSize) {
      for (double y = 0; y < size.height; y += gridSize) {
        canvas.drawPoints(PointMode.points, [Offset(x, y)], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DropZone extends StatefulWidget {
  final Widget child;
  final Function(Object data) onDrop;

  const DropZone({super.key, required this.child, required this.onDrop});

  @override
  State<DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<DropZone> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<Object>(
      onWillAcceptWithDetails: (details) {
        final accepts = details.data is ReadmeElementType || details.data is Snippet;
        if (accepts) {
          setState(() => _isHovered = true);
        }
        return accepts;
      },
      onLeave: (_) => setState(() => _isHovered = false),
      onAcceptWithDetails: (details) {
        setState(() => _isHovered = false);
        widget.onDrop(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isHovered)
              Container(
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withAlpha(100),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            widget.child,
          ],
        );
      },
    );
  }
}
