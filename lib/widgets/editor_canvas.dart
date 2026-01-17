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
          if (provider.selectedElementId != null) provider.removeElement(provider.selectedElementId!);
        },
      },
      child: Focus(
        autofocus: true,
        child: DragTarget<Object>(
          onWillAcceptWithDetails: (details) => details.data is ReadmeElementType || details.data is Snippet,
          onAcceptWithDetails: (details) {
            if (details.data is ReadmeElementType) provider.addElement(details.data as ReadmeElementType);
            else if (details.data is Snippet) provider.addSnippet(details.data as Snippet);
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              color: isDark ? AppColors.editorBackgroundDark : AppColors.editorBackgroundLight,
              child: Stack(
                children: [
                  // Performance-Optimized Grid
                  if (provider.showGrid)
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: DottedGridPainter(isDark: isDark),
                        ),
                      ),
                    ),

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
                              curve: Curves.easeOutCubic,
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
                                    color: Colors.black.withAlpha(isDark ? 60 : 15),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                                border: Border.all(
                                  color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(10),
                                  width: provider.deviceMode == DeviceMode.desktop ? 1 : 10, // Visual frame
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: GestureDetector(
                                onTap: () => provider.selectElement(''),
                                child: provider.elements.isEmpty
                                    ? _buildEmptyState(context)
                                    : _buildElementList(context, provider, canvasPadding, isDark),
                              ),
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),

                  // Enhanced Toolbar (Visible on hover/scroll)
                  _buildFloatingToolbar(context, provider, isDark),

                  // Drop Indicator
                  if (candidateData.isNotEmpty) _buildDropIndicator(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildElementList(BuildContext context, ProjectProvider provider, EdgeInsets padding, bool isDark) {
    // RepaintBoundary here ensures that reordering doesn't repaint the whole app
    return RepaintBoundary(
      child: ReorderableListView.builder(
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
                if (data is ReadmeElementType) provider.insertElement(index, data);
                else if (data is Snippet) provider.insertSnippet(index, data);
              },
              child: CanvasItem(
                element: element,
                isSelected: element.id == provider.selectedElementId,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingToolbar(BuildContext context, ProjectProvider provider, bool isDark) {
    return Positioned(
      top: 20,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF1E293B) : Colors.white).withOpacity(0.9),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: (isDark ? Colors.white : Colors.black).withAlpha(20)),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _toolbarButton(Icons.undo_rounded, 'Undo', provider.undo),
              _toolbarButton(Icons.redo_rounded, 'Redo', provider.redo),
              const SizedBox(width: 4, height: 24, child: VerticalDivider()),
              _toolbarButton(
                Icons.delete_outline_rounded,
                'Delete',
                provider.selectedElementId != null ? () => provider.removeElement(provider.selectedElementId!) : null,
                color: Colors.redAccent,
              ),
              const SizedBox(width: 4, height: 24, child: VerticalDivider()),
              _toolbarButton(
                Icons.grid_3x3_rounded,
                'Grid',
                provider.toggleGrid,
                isActive: provider.showGrid,
              ),
              _toolbarButton(
                Icons.cleaning_services_rounded,
                'Clear All',
                () => _confirmClear(context, provider),
                color: Colors.orangeAccent,
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
      color: isActive ? Colors.blue : (onTap == null ? Colors.grey.withAlpha(100) : color),
      visualDensity: VisualDensity.compact,
      splashRadius: 20,
    );
  }

  void _confirmClear(BuildContext context, ProjectProvider provider) {
    showSafeDialog(
      context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Workspace?'),
        content: const Text('This will remove all elements from your project.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              provider.clearElements();
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildDropIndicator(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.withAlpha(150), width: 4),
          color: Colors.blue.withAlpha(20),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_circle_outline, color: Colors.blue, size: 64),
              const SizedBox(height: 16),
              Text(
                'Drop to Add Component',
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
      child: Column(
        children: [
          Icon(Icons.dashboard_customize_outlined, size: 80, color: Colors.blue.withAlpha(100)),
          const SizedBox(height: 32),
          Text(
            'Craft Your README',
            style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Drag components from the sidebar or pick a template to get started.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 16, color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 16,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Quick Start'),
                onPressed: () => Provider.of<ProjectProvider>(context, listen: false).loadTemplate(Templates.all.first),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.style),
                label: const Text('Browse Templates'),
                onPressed: () {}, // Handled in settings panel or separate button
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation, bool isDark) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Material(
          elevation: 10,
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
      ..color = isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(10)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    const double gap = 30.0;
    final List<Offset> points = [];

    // Pre-calculate points to avoid expensive logic in the loop if we were doing more
    for (double x = 0; x <= size.width; x += gap) {
      for (double y = 0; y <= size.height; y += gap) {
        points.add(Offset(x, y));
      }
    }
    
    // Using PointMode.points is generally fast, but some browsers might struggle with it.
    // If it's "not working", we can try small drawRects or drawCircles, but points are best.
    // Let's ensure strokeWidth is sufficient.
    canvas.drawPoints(PointMode.points, points, paint);
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
        if (accepts) setState(() => _isHovered = true);
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
                  boxShadow: [BoxShadow(color: Colors.blue.withAlpha(100), blurRadius: 8)],
                ),
              ),
            widget.child,
          ],
        );
      },
    );
  }
}
