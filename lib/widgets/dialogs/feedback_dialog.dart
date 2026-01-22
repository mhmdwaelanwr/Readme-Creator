import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:pasteboard/pasteboard.dart';
import '../../core/constants/app_colors.dart';
import '../../services/feedback_service.dart';
import '../../utils/dialog_helper.dart';

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key});

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _selectedType = 'bug';
  bool _isSubmitting = false;
  bool _isDragging = false;
  
  PlatformFile? _attachedFile;

  final Map<String, Map<String, dynamic>> _types = {
    'bug': {'label': 'Report a Bug', 'icon': Icons.bug_report_rounded, 'color': Colors.red},
    'feature': {'label': 'Request Feature', 'icon': Icons.add_chart_rounded, 'color': Colors.blue},
    'general': {'label': 'General Feedback', 'icon': Icons.message_rounded, 'color': Colors.green},
  };

  @override
  void initState() {
    super.initState();
    // Start listening for keyboard events if needed, but we'll use CallbackShortcuts or RawKeyboardListener
  }

  Future<void> _handlePaste() async {
    final imageBytes = await Pasteboard.image;
    if (imageBytes != null) {
      setState(() {
        _attachedFile = PlatformFile(
          name: 'pasted_image_${DateTime.now().millisecondsSinceEpoch}.png',
          size: imageBytes.length,
          bytes: imageBytes,
        );
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image pasted from clipboard!')),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf', 'jpeg'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _attachedFile = result.files.first;
      });
    }
  }

  Future<void> _submit() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      await FeedbackService().submitFeedback(
        type: _selectedType,
        message: _messageController.text.trim(),
        attachmentBytes: _attachedFile?.bytes,
        attachmentName: _attachedFile?.name,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you! Feedback sent.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyV, control: true): _handlePaste,
        const SingleActivator(LogicalKeyboardKey.keyV, meta: true): _handlePaste,
      },
      child: DropTarget(
        onDragEntered: (details) => setState(() => _isDragging = true),
        onDragExited: (details) => setState(() => _isDragging = false),
        onDragDone: (details) async {
          if (details.files.isNotEmpty) {
            final file = details.files.first;
            final bytes = await file.readAsBytes();
            setState(() {
              _attachedFile = PlatformFile(
                name: file.name,
                size: bytes.length,
                bytes: bytes,
              );
              _isDragging = false;
            });
          }
        },
        child: StyledDialog(
          title: const DialogHeader(
            title: 'Feedback & Support',
            icon: Icons.support_agent_rounded,
            color: AppColors.primary,
          ),
          width: 500,
          content: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: _isDragging ? const EdgeInsets.all(16) : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: _isDragging ? AppColors.primary.withAlpha(30) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: _isDragging ? Border.all(color: AppColors.primary, width: 2, style: BorderStyle.solid) : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isDragging) 
                  Center(child: Text('Drop image here!', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primary))),
                
                Text(
                  'How can we help you?',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                _buildTypeSelector(),
                const SizedBox(height: 20),
                TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  maxLines: 4,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Describe your issue... (Ctrl+V to paste image)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: isDark ? Colors.white.withAlpha(10) : Colors.grey.withAlpha(10),
                  ),
                ),
                const SizedBox(height: 16),
                _buildAttachmentSection(isDark),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting 
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(_isSubmitting ? 'Sending...' : 'Send Feedback'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: _types.entries.map((e) {
        final isSelected = _selectedType == e.key;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedType = e.key),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? e.value['color'].withAlpha(30) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? e.value['color'] : Colors.grey.withAlpha(50), width: 2),
              ),
              child: Column(
                children: [
                  Icon(e.value['icon'], color: isSelected ? e.value['color'] : Colors.grey),
                  const SizedBox(height: 4),
                  Text(e.value['label'], style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? e.value['color'] : Colors.grey), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAttachmentSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(5) : Colors.black.withAlpha(5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_file_rounded, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text('Attachment (Drop or Paste)', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600])),
              const Spacer(),
              if (_attachedFile == null)
                TextButton.icon(onPressed: _pickFile, icon: const Icon(Icons.add_a_photo_rounded, size: 16), label: const Text('Add File', style: TextStyle(fontSize: 12)))
              else
                IconButton(icon: const Icon(Icons.close_rounded, size: 18, color: Colors.red), onPressed: () => setState(() => _attachedFile = null)),
            ],
          ),
          if (_attachedFile != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: AppColors.primary.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_attachedFile!.name, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                    Text('${(_attachedFile!.size / 1024).toStringAsFixed(1)} KB', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
