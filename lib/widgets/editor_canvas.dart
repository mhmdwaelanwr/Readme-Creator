import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/readme_element.dart';
import '../models/snippet.dart';
import '../providers/project_provider.dart';
import 'canvas_item.dart';
import '../core/constants/app_colors.dart';
import '../utils/dialog_helper.dart';

class EditorCanvas extends StatelessWidget {
  const EditorCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    double maxWidth = 850;
    double? deviceHeight;
    double borderRadius = 12;
    EdgeInsets canvasPadding = const EdgeInsets.all(32);

    if (provider.deviceMode == DeviceMode.tablet) {
      maxWidth = 600;
      deviceHeight = 800;
      borderRadius = 24;
    } else if (provider.deviceMode == DeviceMode.mobile) {
      maxWidth = 375;
      deviceHeight = 667;
      borderRadius = 32;
      canvasPadding = const EdgeInsets.all(16);
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
            return Container(
              color: isDark ? AppColors.editorBackgroundDark : AppColors.editorBackgroundLight,
              child: Stack(
                children: [
                  // Main Scrollable Area
                  Positioned.fill(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 100),
                          Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              constraints: BoxConstraints(
                                maxWidth: maxWidth,
                                minHeight: deviceHeight ?? 0,
                              ),
                              margin: const EdgeInsets.symmetric(horizontal: 24),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.canvasBackgroundDark : AppColors.canvasBackgroundLight,
                                borderRadius: BorderRadius.circular(borderRadius),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(isDark ? 100 : 25),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                                border: Border.all(
                                  color: isDark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(12),
                                  width: provider.deviceMode == DeviceMode.desktop ? 1 : 12,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                children: [
                                  // NEW: Grid is now INSIDE the design canvas
                                  if (provider.showGrid)
                                    Positioned.fill(
                                      child: RepaintBoundary(
                                        child: CustomPaint(
                                          painter: DottedGridPainter(isDark: isDark),
                                        ),
                                      ),
                                    ),
                                  
                                  GestureDetector(
                                    onTap: () => provider.selectElement(''),
                                    behavior: HitTestBehavior.opaque,
                                    child: RepaintBoundary(
                                      child: provider.elements.isEmpty
                                          ? _buildEmptyState(context)
                                          : _buildElementList(provider, canvasPadding, isDark),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),

                  // Floating UI Elements
                  _buildFloatingToolbar(context, provider, isDark),
                  if (candidateData.isNotEmpty) _buildDropIndicator(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildElementList(ProjectProvider provider, EdgeInsets padding, bool isDark) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      itemCount: provider.elements.length,
      onReorder: provider.reorderElements,
      proxyDecorator: (child, index, animation) => _proxyDecorator(child, index, animation, isDark),
      itemBuilder: (context, index) {
        final element = provider.elements[index];
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
              isSelected: element.id == provider.selectedElementId,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingToolbar(BuildContext context, ProjectProvider provider, bool isDark) {
    return Positioned(
      top: 20,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF1E293B) : Colors.white).withAlpha(240),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: (isDark ? Colors.white : Colors.black).withAlpha(25)),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _toolbarButton(Icons.undo_rounded, 'Undo', provider.undo),
              _toolbarButton(Icons.redo_rounded, 'Redo', provider.redo),
              const VerticalDivider(width: 20, indent: 12, endIndent: 12),
              _toolbarButton(
                Icons.delete_sweep_rounded,
                'Delete',
                provider.selectedElementId != null ? () => provider.removeElement(provider.selectedElementId!) : null,
                color: Colors.redAccent,
              ),
              const VerticalDivider(width: 20, indent: 12, endIndent: 12),
              _toolbarButton(
                Icons.grid_goldenratio_rounded,
                'Grid',
                provider.toggleGrid,
                isActive: provider.showGrid,
              ),
              _toolbarButton(
                Icons.delete_forever_rounded,
                'Clear',
                () => _confirmClear(context, provider),
                color: Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toolbarButton(IconData icon, String tooltip, VoidCallback? onTap, {Color? color, bool isActive = false}) {
    return IconButton(
      icon: Icon(icon, size: 20),
      onPressed: onTap,
      tooltip: tooltip,
      color: isActive ? Colors.blue : (onTap == null ? Colors.grey.withAlpha(128) : color),
      visualDensity: VisualDensity.compact,
    );
  }

  void _confirmClear(BuildContext context, ProjectProvider provider) {
    showSafeDialog(
      context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All?'),
        content: const Text('Do you want to remove all elements from this project?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              provider.clearElements();
              Navigator.pop(context);
            },
            child: const Text('Clear Everything'),
          ),
        ],
      ),
    );
  }

  Widget _buildDropIndicator(BuildContext context) {
    return IgnorePointer(
      child: Container(
        color: Colors.blue.withAlpha(25),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add_circle_outline, color: Colors.white, size: 48),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 40),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome_mosaic_rounded, size: 80, color: Colors.blue),
          const SizedBox(height: 32),
          Text(
            'New README Project',
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Drag and drop components to build your file', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation, bool isDark) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Material(
          elevation: 8,
          color: isDark ? const Color(0xFF334155) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: child,
        );
      },
      child: child,
    );
  }
}

class DottedGridPainter extends CustomPainter {
  final bool isDark;
  DottedGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.white.withAlpha(45) : Colors.black.withAlpha(25)
      ..style = PaintingStyle.fill;

    const double gap = 25.0; // Slightly tighter gap for a cleaner look
    
    for (double x = gap; x < size.width; x += gap) {
      for (double y = gap; y < size.height; y += gap) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DottedGridPainter oldDelegate) => oldDelegate.isDark != isDark;
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
          children: [
            if (_isHovered)
              Container(
                height: 4,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [BoxShadow(color: Colors.blue.withAlpha(128), blurRadius: 8)],
                ),
              ),
            widget.child,
          ],
        );
      },
    );
  }
}
