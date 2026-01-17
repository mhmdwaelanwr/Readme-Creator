import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/readme_element.dart';
import '../models/snippet.dart';
import '../providers/project_provider.dart';
import '../services/auth_service.dart';
import 'canvas_item.dart';
import '../core/constants/app_colors.dart';
import '../utils/dialog_helper.dart';
import '../utils/toast_helper.dart';
import 'dialogs/login_dialog.dart';

class EditorCanvas extends StatelessWidget {
  const EditorCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectProvider>(context);
    final authService = AuthService();
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
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): () {
          if (!authService.isReady) {
            ToastHelper.show(context, 'Cloud Sync requires Firebase Setup.', isError: true);
          }
        },
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true): () => provider.undo(),
        const SingleActivator(LogicalKeyboardKey.keyY, control: true): () => provider.redo(),
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
                  // High-Contrast Grid Logic
                  if (provider.showGrid)
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: DottedGridPainter(isDark: isDark),
                        ),
                      ),
                    ),

                  // Main Interactive Workspace
                  Positioned.fill(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 100),
                          _buildAuthContextBanner(context, authService, isDark),
                          const SizedBox(height: 20),
                          Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              constraints: BoxConstraints(
                                maxWidth: maxWidth,
                                minHeight: deviceHeight ?? 400,
                              ),
                              margin: const EdgeInsets.symmetric(horizontal: 24),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.canvasBackgroundDark : AppColors.canvasBackgroundLight,
                                borderRadius: BorderRadius.circular(borderRadius),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                                border: Border.all(
                                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                                  width: provider.deviceMode == DeviceMode.desktop ? 1 : 12,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: GestureDetector(
                                onTap: () => provider.selectElement(''),
                                behavior: HitTestBehavior.opaque,
                                child: provider.elements.isEmpty
                                    ? _buildEmptyState(context)
                                    : _buildElementList(provider, canvasPadding, isDark),
                              ),
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),

                  // Integrated Toolbar
                  _buildFloatingToolbar(context, provider, isDark),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAuthContextBanner(BuildContext context, AuthService auth, bool isDark) {
    if (auth.githubToken != null) return const SizedBox.shrink();

    return Container(
      width: 400,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 16, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'GitHub integration inactive. Login to enable auto-import.',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87),
            ),
          ),
          TextButton(
            onPressed: () => showSafeDialog(context, builder: (context) => const LoginDialog()),
            child: const Text('Login', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
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
      proxyDecorator: (child, index, animation) => Material(
        elevation: 8,
        color: isDark ? const Color(0xFF334155) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
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
            color: (isDark ? const Color(0xFF1E293B) : Colors.white).withOpacity(0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
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
                () {
                  provider.clearElements();
                  ToastHelper.show(context, 'Workspace cleared');
                },
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
      color: isActive ? Colors.blue : (onTap == null ? Colors.grey.withOpacity(0.5) : color),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 40),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome_mosaic_rounded, size: 80, color: Colors.blue),
          const SizedBox(height: 32),
          Text(
            'Start Your Masterpiece',
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Drag components from the library to build your documentation', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class DottedGridPainter extends CustomPainter {
  final bool isDark;
  DottedGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    const double gap = 30.0;
    for (double x = 0; x <= size.width; x += gap) {
      for (double y = 0; y <= size.height; y += gap) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
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
                  boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 8)],
                ),
              ),
            widget.child,
          ],
        );
      },
    );
  }
}
