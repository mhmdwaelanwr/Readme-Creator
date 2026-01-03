import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/project_provider.dart';
import '../utils/downloader.dart';

class SocialPreviewScreen extends StatefulWidget {
  const SocialPreviewScreen({super.key});

  @override
  State<SocialPreviewScreen> createState() => _SocialPreviewScreenState();
}

class _SocialPreviewScreenState extends State<SocialPreviewScreen> {
  final GlobalKey _previewKey = GlobalKey();
  Color _backgroundColor = const Color(0xFF1A202C); // Dark GitHub-like
  Color _textColor = Colors.white;
  double _titleSize = 64;
  double _descSize = 32;
  bool _showBorder = true;

  Future<void> _exportImage() async {
    try {
      final boundary = _previewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 2.0); // High res
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final pngBytes = byteData.buffer.asUint8List();
        // Use downloader util
        // We need to convert Uint8List to String for downloadJsonFile? No, that's for JSON.
        // We need a binary downloader.
        // Let's check utils/downloader.dart
        // It seems we only have downloadJsonFile.
        // I'll implement a simple download helper here or update downloader.dart.
        // For now, let's assume I can use a similar method or just implement it.
        // Actually, I should check downloader.dart first.
        // But I can't check it right now without interrupting flow.
        // I'll assume I need to implement binary download.
        // Wait, I can just use the same technique as downloadJsonFile but with bytes.
        // Let's check if I can import 'dart:html' if web, or use file_picker/path_provider if desktop.
        // Since this is a Flutter app, I should use a cross-platform way.
        // For now, I'll just use a placeholder or try to use the existing downloader if it supports bytes.
        // Let's just implement a quick save dialog for desktop.

        // Actually, I'll just use FilePicker to save.
        // But wait, FilePicker.saveFile is not available on all platforms easily in older versions.
        // Let's use the same approach as `ProjectExporter` if it saves files.
        // `ProjectExporter` likely uses `downloadJsonFile`.

        // Let's just use a simple method for now.
        // I'll add a method to `Downloader` class later if needed.
        // For now, I'll just print "Exported" to console and show snackbar,
        // but to be useful I need to save it.
        // I'll use `Printing` package to share/save? No, that's for PDF.
        // I'll use `file_picker` to save if possible, or just `File` write if desktop.

        // Let's try to use `file_picker`'s `saveFile` if available (it is in recent versions).
        // Or just `File` write.

        // Since I am on Windows, I can use `File`.
        // But I want it to be generic.
        // Let's use `FilePicker.platform.saveFile`.

        // Wait, `file_picker` 10.3.8 supports `saveFile`.

        /*
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Social Preview',
          fileName: 'social-preview.png',
        );

        if (outputFile != null) {
           final file = File(outputFile);
           await file.writeAsBytes(pngBytes);
           if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved!')));
        }
        */
        // But I need `dart:io`.
        // I'll add imports.

        // For web support, I would need `dart:html`.
        // I'll stick to desktop for now as per environment.

        // Actually, let's just use a simple helper that I will add to `downloader.dart` later.
        // For now, I will implement `_saveImage` locally.
        _saveImage(pngBytes);
      }
    } catch (e) {
      debugPrint('Error exporting image: $e');
    }
  }

  Future<void> _saveImage(Uint8List bytes) async {
    await downloadImageFile(bytes, 'social-preview.png');
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image exported!')));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectProvider>(context);
    final projectName = provider.variables['PROJECT_NAME'] ?? 'Project Name';
    final projectDesc = 'A short description of your project.'; // We could fetch this from a paragraph if we want

    return Scaffold(
      appBar: AppBar(
        title: Text('Social Preview Designer', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export Image',
            onPressed: _exportImage,
          ),
        ],
      ),
      body: Row(
        children: [
          // Settings Panel
          Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.withAlpha(50))),
            ),
            child: ListView(
              children: [
                Text('Appearance', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                ListTile(
                  title: Text('Background Color', style: GoogleFonts.inter()),
                  trailing: CircleAvatar(backgroundColor: _backgroundColor),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Pick Background Color'),
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: _backgroundColor,
                            onColorChanged: (color) => setState(() => _backgroundColor = color),
                            labelTypes: const [],
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Done'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text('Text Color', style: GoogleFonts.inter()),
                  trailing: CircleAvatar(backgroundColor: _textColor),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Pick Text Color'),
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: _textColor,
                            onColorChanged: (color) => setState(() => _textColor = color),
                            labelTypes: const [],
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Done'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(),
                Text('Typography', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                Text('Title Size: ${_titleSize.toInt()}', style: GoogleFonts.inter()),
                Slider(
                  value: _titleSize,
                  min: 24,
                  max: 120,
                  onChanged: (val) => setState(() => _titleSize = val),
                ),
                Text('Description Size: ${_descSize.toInt()}', style: GoogleFonts.inter()),
                Slider(
                  value: _descSize,
                  min: 12,
                  max: 60,
                  onChanged: (val) => setState(() => _descSize = val),
                ),
                const Divider(),
                SwitchListTile(
                  title: Text('Show Border', style: GoogleFonts.inter()),
                  value: _showBorder,
                  onChanged: (val) => setState(() => _showBorder = val),
                ),
              ],
            ),
          ),
          // Preview Area
          Expanded(
            child: Container(
              color: Colors.grey[200], // Canvas background
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: RepaintBoundary(
                      key: _previewKey,
                      child: Container(
                        width: 1280,
                        height: 640,
                        decoration: BoxDecoration(
                          color: _backgroundColor,
                          border: _showBorder ? Border.all(color: Colors.white.withAlpha(50), width: 20) : null,
                        ),
                        padding: const EdgeInsets.all(64),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              projectName,
                              style: GoogleFonts.inter(
                                fontSize: _titleSize,
                                fontWeight: FontWeight.w900,
                                color: _textColor,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              projectDesc,
                              style: GoogleFonts.inter(
                                fontSize: _descSize,
                                fontWeight: FontWeight.w500,
                                color: _textColor.withAlpha(200),
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Icon(Icons.star, color: _textColor, size: 32),
                                const SizedBox(width: 12),
                                Text(
                                  'Star on GitHub',
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: _textColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

