import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/readme_element.dart';
import '../providers/project_provider.dart';
import '../core/constants/dev_icons.dart';
import '../services/github_service.dart';
import 'giphy_picker_dialog.dart';
import '../core/constants/social_platforms.dart';
import '../core/constants/country_codes.dart';
import '../services/ai_service.dart';
import '../utils/debouncer.dart';
import '../utils/dialog_helper.dart';

class ElementSettingsForm extends StatefulWidget {
  final ReadmeElement element;

  const ElementSettingsForm({super.key, required this.element});

  @override
  State<ElementSettingsForm> createState() => _ElementSettingsFormState();
}

class _ElementSettingsFormState extends State<ElementSettingsForm> {
  late TextEditingController _textController;
  late TextEditingController _urlController;
  late TextEditingController _altTextController;
  late TextEditingController _codeController;
  late TextEditingController _languageController;
  late TextEditingController _labelController;
  late TextEditingController _imageUrlController;
  late TextEditingController _targetUrlController;
  late TextEditingController _widthController;
  late TextEditingController _nameController;
  late TextEditingController _typeNameController;

  String _currentElementId = '';
  final Debouncer _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _initControllers();
    _updateControllersFromElement();
    _currentElementId = widget.element.id;
  }

  void _initControllers() {
    _textController = TextEditingController();
    _urlController = TextEditingController();
    _altTextController = TextEditingController();
    _codeController = TextEditingController();
    _languageController = TextEditingController();
    _labelController = TextEditingController();
    _imageUrlController = TextEditingController();
    _targetUrlController = TextEditingController();
    _widthController = TextEditingController();
    _nameController = TextEditingController();
    _typeNameController = TextEditingController();

    _textController.addListener(() => _onTextChanged());
    _urlController.addListener(() => _onUrlChanged());
    _altTextController.addListener(() => _onAltTextChanged());
    _codeController.addListener(() => _onCodeChanged());
    _languageController.addListener(() => _onLanguageChanged());
    _labelController.addListener(() => _onLabelChanged());
    _imageUrlController.addListener(() => _onImageUrlChanged());
    _targetUrlController.addListener(() => _onTargetUrlChanged());
    _widthController.addListener(() => _onWidthChanged());
    _nameController.addListener(() => _onNameChanged());
    _typeNameController.addListener(() => _onTypeNameChanged());
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _textController.dispose();
    _urlController.dispose();
    _altTextController.dispose();
    _codeController.dispose();
    _languageController.dispose();
    _labelController.dispose();
    _imageUrlController.dispose();
    _targetUrlController.dispose();
    _widthController.dispose();
    _nameController.dispose();
    _typeNameController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ElementSettingsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.element.id != _currentElementId) {
      _currentElementId = widget.element.id;
      _updateControllersFromElement();
    } else {
      // Check for external updates (e.g. from Dropdown)
      _syncControllersIfChanged();
    }
  }

  void _updateControllersFromElement() {
    final e = widget.element;
    if (e is HeadingElement) _textController.text = e.text;
    if (e is ParagraphElement) _textController.text = e.text;
    if (e is MermaidElement) _codeController.text = e.code;
    if (e is TOCElement) _textController.text = e.title;
    if (e is ImageElement) {
      _urlController.text = e.url;
      _altTextController.text = e.altText;
      _widthController.text = e.width?.toString() ?? '';
    }
    if (e is LinkButtonElement) {
      _textController.text = e.text;
      _urlController.text = e.url;
    }
    if (e is CodeBlockElement) {
      _codeController.text = e.code;
      _languageController.text = e.language;
    }
    if (e is BadgeElement) {
      _labelController.text = e.label;
      _imageUrlController.text = e.imageUrl;
      _targetUrlController.text = e.targetUrl;
    }
    if (e is IconElement) {
      _nameController.text = e.name;
      _urlController.text = e.url;
      _widthController.text = e.size.toString();
    }
    if (e is EmbedElement) {
      _urlController.text = e.url;
      _typeNameController.text = e.typeName;
    }
    if (e is GitHubStatsElement) {
      _textController.text = e.repoName;
    }
    if (e is ContributorsElement) {
      _textController.text = e.repoName;
    }
    if (e is BlockquoteElement) {
      _textController.text = e.text;
    }
    if (e is CollapsibleElement) {
      _textController.text = e.summary;
      _codeController.text = e.content;
    }
  }

  void _syncControllersIfChanged() {
    final e = widget.element;
    if (e is HeadingElement) _syncText(_textController, e.text);
    if (e is ParagraphElement) _syncText(_textController, e.text);
    if (e is ImageElement) {
      _syncText(_urlController, e.url);
      _syncText(_altTextController, e.altText);
      _syncText(_widthController, e.width?.toString() ?? '');
    }
    if (e is LinkButtonElement) {
      _syncText(_textController, e.text);
      _syncText(_urlController, e.url);
    }
    if (e is CodeBlockElement) {
      _syncText(_codeController, e.code);
      _syncText(_languageController, e.language);
    }
    if (e is BadgeElement) {
      _syncText(_labelController, e.label);
      _syncText(_imageUrlController, e.imageUrl);
      _syncText(_targetUrlController, e.targetUrl);
    }
    if (e is IconElement) {
      _syncText(_nameController, e.name);
      _syncText(_urlController, e.url);
      _syncText(_widthController, e.size.toString());
    }
    if (e is EmbedElement) {
      _syncText(_urlController, e.url);
      _syncText(_typeNameController, e.typeName);
    }
    if (e is GitHubStatsElement) {
      _syncText(_textController, e.repoName);
    }
    if (e is ContributorsElement) {
      _syncText(_textController, e.repoName);
    }
    if (e is BlockquoteElement) {
      _syncText(_textController, e.text);
    }
    if (e is CollapsibleElement) {
      _syncText(_textController, e.summary);
      _syncText(_codeController, e.content);
    }
  }

  void _syncText(TextEditingController controller, String value) {
    if (controller.text != value) {
      controller.text = value;
      // Move cursor to end to avoid jumping to start
      controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
    }
  }

  void _wrapSelection(TextEditingController controller, String wrapper) {
    final text = controller.text;
    final selection = controller.selection;

    if (selection.isValid && selection.start != selection.end) {
      final newText = text.replaceRange(selection.start, selection.end, '$wrapper${selection.textInside(text)}$wrapper');
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: selection.start + wrapper.length,
          extentOffset: selection.end + wrapper.length,
        ),
      );
    } else {
      final start = selection.isValid ? selection.start : text.length;
      final newText = text.replaceRange(start, start, '$wrapper$wrapper');
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start + wrapper.length),
      );
    }
    // Trigger update manually as setting value programmatically might not trigger listener depending on implementation,
    // but usually it does NOT trigger listener in Flutter unless user types.
    // Wait, controller.addListener IS triggered by setting .text or .value.
    // So we don't need manual update.
  }

  void _notifyUpdate() {
    Provider.of<ProjectProvider>(context, listen: false).updateElement();
  }

  void _debounceUpdate() {
    _debouncer.run(_notifyUpdate);
  }

  void _onTextChanged() {
    final e = widget.element;
    if (e is HeadingElement && e.text != _textController.text) {
      e.text = _textController.text;
      _debounceUpdate();
    } else if (e is ParagraphElement && e.text != _textController.text) {
      e.text = _textController.text;
      _debounceUpdate();
    } else if (e is LinkButtonElement && e.text != _textController.text) {
      e.text = _textController.text;
      _debounceUpdate();
    } else if (e is GitHubStatsElement && e.repoName != _textController.text) {
      e.repoName = _textController.text;
      _debounceUpdate();
    } else if (e is ContributorsElement && e.repoName != _textController.text) {
      e.repoName = _textController.text;
      _debounceUpdate();
    } else if (e is TOCElement && e.title != _textController.text) {
      e.title = _textController.text;
      _debounceUpdate();
    } else if (e is BlockquoteElement && e.text != _textController.text) {
      e.text = _textController.text;
      _debounceUpdate();
    } else if (e is CollapsibleElement && e.summary != _textController.text) {
      e.summary = _textController.text;
      _debounceUpdate();
    }
  }

  void _onUrlChanged() {
    final e = widget.element;
    if (e is ImageElement && e.url != _urlController.text) {
      e.url = _urlController.text;
      _debounceUpdate();
    } else if (e is LinkButtonElement && e.url != _urlController.text) {
      e.url = _urlController.text;
      _debounceUpdate();
    } else if (e is IconElement && e.url != _urlController.text) {
      e.url = _urlController.text;
      _debounceUpdate();
    } else if (e is EmbedElement && e.url != _urlController.text) {
      e.url = _urlController.text;
      _debounceUpdate();
    }
  }

  void _onAltTextChanged() {
    final e = widget.element;
    if (e is ImageElement && e.altText != _altTextController.text) {
      e.altText = _altTextController.text;
      _debounceUpdate();
    }
  }

  void _onCodeChanged() {
    final e = widget.element;
    if (e is CodeBlockElement && e.code != _codeController.text) {
      e.code = _codeController.text;
      _debounceUpdate();
    } else if (e is MermaidElement && e.code != _codeController.text) {
      e.code = _codeController.text;
      _debounceUpdate();
    } else if (e is CollapsibleElement && e.content != _codeController.text) {
      e.content = _codeController.text;
      _debounceUpdate();
    }
  }

  void _onLanguageChanged() {
    final e = widget.element;
    if (e is CodeBlockElement && e.language != _languageController.text) {
      e.language = _languageController.text;
      _debounceUpdate();
    }
  }

  void _onLabelChanged() {
    final e = widget.element;
    if (e is BadgeElement && e.label != _labelController.text) {
      e.label = _labelController.text;
      _debounceUpdate();
    }
  }

  void _onImageUrlChanged() {
    final e = widget.element;
    if (e is BadgeElement && e.imageUrl != _imageUrlController.text) {
      e.imageUrl = _imageUrlController.text;
      _debounceUpdate();
    }
  }

  void _onTargetUrlChanged() {
    final e = widget.element;
    if (e is BadgeElement && e.targetUrl != _targetUrlController.text) {
      e.targetUrl = _targetUrlController.text;
      _debounceUpdate();
    }
  }

  void _onNameChanged() {
    final e = widget.element;
    if (e is IconElement && e.name != _nameController.text) {
      e.name = _nameController.text;
      _debounceUpdate();
    }
  }

  void _onTypeNameChanged() {
    final e = widget.element;
    if (e is EmbedElement && e.typeName != _typeNameController.text) {
      e.typeName = _typeNameController.text;
      _debounceUpdate();
    }
  }

  void _onWidthChanged() {
    final e = widget.element;
    if (e is ImageElement) {
      final val = double.tryParse(_widthController.text);
      if (e.width != val) {
        e.width = val;
        _debounceUpdate();
      }
    } else if (e is IconElement) {
      final val = double.tryParse(_widthController.text);
      if (val != null && e.size != val) {
        e.size = val;
        _debounceUpdate();
      }
    }
  }


  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.startsWith('#')) return null; // Anchor
    if (value.startsWith('/')) return null; // Relative path
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) {
      return 'Invalid URL (must start with http:// or https://)';
    }
    return null;
  }

  Future<void> _showAIOptions(TextEditingController controller) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.auto_fix_high, color: Colors.purple),
            title: const Text('AI Improve Text'),
            onTap: () => Navigator.pop(context, 'improve'),
          ),
          ListTile(
            leading: const Icon(Icons.spellcheck, color: Colors.blue),
            title: const Text('Fix Grammar'),
            onTap: () => Navigator.pop(context, 'grammar'),
          ),
          ListTile(
            leading: const Icon(Icons.description, color: Colors.green),
            title: const Text('Generate Description'),
            onTap: () => Navigator.pop(context, 'generate'),
          ),
        ],
      ),
    );

    if (result != null) {
      if (!mounted) return;
      final provider = Provider.of<ProjectProvider>(context, listen: false);
      final apiKey = provider.geminiApiKey;

      if (apiKey == null || apiKey.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Using Mock AI. Set API Key in Settings for real AI.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI is thinking...')));
      }

      String newText = '';
      if (result == 'improve') {
        newText = await AIService.improveText(controller.text, apiKey: apiKey);
      } else if (result == 'grammar') {
        newText = await AIService.fixGrammar(controller.text, apiKey: apiKey);
      } else if (result == 'generate') {
        newText = await AIService.generateDescription(controller.text.isEmpty ? 'Project' : controller.text, apiKey: apiKey);
      }

      if (mounted && newText.isNotEmpty) {
        controller.text = newText;
        // Trigger update
        if (widget.element is HeadingElement) {
          (widget.element as HeadingElement).text = newText;
        } else if (widget.element is ParagraphElement) {
          (widget.element as ParagraphElement).text = newText;
        }
        _notifyUpdate();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final element = widget.element;
    final provider = Provider.of<ProjectProvider>(context, listen: false);

    if (element is HeadingElement) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _textController,
                  decoration: const InputDecoration(labelText: 'Heading Text'),
                  style: GoogleFonts.inter(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.auto_awesome, color: Colors.purple),
                tooltip: 'AI Assistant',
                onPressed: () => _showAIOptions(_textController),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: element.level,
            decoration: const InputDecoration(labelText: 'Level'),
            items: const [
              DropdownMenuItem(value: 1, child: Text('H1')),
              DropdownMenuItem(value: 2, child: Text('H2')),
              DropdownMenuItem(value: 3, child: Text('H3')),
            ],
            onChanged: (value) {
              if (value != null) {
                element.level = value;
                _notifyUpdate();
              }
            },
          ),
        ],
      );
    } else if (element is ParagraphElement) {
      return Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.format_bold),
                onPressed: () => _wrapSelection(_textController, '**'),
                tooltip: 'Bold',
              ),
              IconButton(
                icon: const Icon(Icons.format_italic),
                onPressed: () => _wrapSelection(_textController, '*'),
                tooltip: 'Italic',
              ),
              IconButton(
                icon: const Icon(Icons.code),
                onPressed: () => _wrapSelection(_textController, '`'),
                tooltip: 'Inline Code',
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.auto_awesome, color: Colors.purple),
                tooltip: 'AI Assistant',
                onPressed: () => _showAIOptions(_textController),
              ),
            ],
          ),
          TextFormField(
            controller: _textController,
            decoration: const InputDecoration(labelText: 'Text'),
            maxLines: 5,
            style: GoogleFonts.inter(),
          ),
        ],
      );
    } else if (element is ImageElement) {
      return Column(
        children: [
          TextFormField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: 'Image URL',
              suffixIcon: IconButton(
                icon: const Icon(Icons.content_paste),
                tooltip: 'Paste & Fix GitHub URL',
                onPressed: () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  if (data != null && data.text != null) {
                    String url = data.text!;
                    if (url.contains('github.com') && url.contains('/blob/')) {
                      url = url.replaceFirst('/blob/', '/raw/');
                    }
                    _urlController.text = url;
                    element.url = url;
                    _notifyUpdate();
                  }
                },
              ),
            ),
            validator: _validateUrl,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: GoogleFonts.inter(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload'),
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.image,
                      withData: true, // Important for web
                    );

                    if (result != null && result.files.isNotEmpty) {
                      final file = result.files.first;
                      if (file.bytes != null) {
                        setState(() {
                          element.localData = file.bytes;
                          // We set a placeholder URL or keep it empty, but we need to indicate it's local.
                          // Let's set URL to filename for reference in Markdown
                          element.url = './${file.name}';
                          _urlController.text = element.url;
                        });
                        _notifyUpdate();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Image uploaded. Remember to add this file to your repo!')),
                          );
                        }
                      }
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.gif),
                  label: const Text('GIPHY'),
                  onPressed: () async {
                    final url = await showDialog<String>(
                      context: context,
                      builder: (context) => const GiphyPickerDialog(),
                    );
                    if (url != null) {
                      setState(() {
                        element.url = url;
                        _urlController.text = url;
                        element.localData = null; // Clear local data if any
                      });
                      _notifyUpdate();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _altTextController,
            decoration: const InputDecoration(labelText: 'Alt Text'),
            style: GoogleFonts.inter(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _widthController,
            decoration: const InputDecoration(labelText: 'Width (optional)'),
            style: GoogleFonts.inter(),
          ),
        ],
      );
    } else if (element is LinkButtonElement) {
      return Column(
        children: [
          TextFormField(
            controller: _textController,
            decoration: const InputDecoration(labelText: 'Button Text'),
            style: GoogleFonts.inter(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _urlController,
            decoration: const InputDecoration(labelText: 'URL'),
            validator: _validateUrl,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: GoogleFonts.inter(),
          ),
          if (provider.elements.whereType<HeadingElement>().isNotEmpty) ...[
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Or link to section'),
              items: provider.elements.whereType<HeadingElement>().map((h) {
                final anchor = '#${h.text.toLowerCase().replaceAll(' ', '-')}';
                return DropdownMenuItem(
                  value: anchor,
                  child: Text(h.text, style: GoogleFonts.inter()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  element.url = value;
                  _notifyUpdate();
                }
              },
            ),
          ],
        ],
      );
    } else if (element is CodeBlockElement) {
      return Column(
        children: [
          TextFormField(
            controller: _languageController,
            decoration: const InputDecoration(labelText: 'Language'),
            style: GoogleFonts.inter(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _codeController,
            decoration: const InputDecoration(labelText: 'Code'),
            maxLines: 10,
            style: GoogleFonts.firaCode(),
          ),
        ],
      );
    } else if (element is ListElement) {
      return Column(
        children: [
          SwitchListTile(
            title: Text('Ordered List', style: GoogleFonts.inter()),
            value: element.isOrdered,
            onChanged: (value) {
              setState(() {
                element.isOrdered = value;
              });
              _notifyUpdate();
            },
          ),
          ...element.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      key: ValueKey(index), // Use index as key to preserve focus
                      initialValue: item,
                      decoration: InputDecoration(labelText: 'Item ${index + 1}'),
                      style: GoogleFonts.inter(),
                      onChanged: (value) {
                        element.items[index] = value;
                        _notifyUpdate();
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      element.items.removeAt(index);
                      _notifyUpdate();
                    },
                  ),
                ],
              ),
            );
          }),
          ElevatedButton(
            onPressed: () {
              element.items.add('New Item');
              _notifyUpdate();
            },
            child: const Text('Add Item'),
          ),
        ],
      );
    } else if (element is BadgeElement) {
      return Column(
        children: [
          TextFormField(
            controller: _labelController,
            decoration: const InputDecoration(labelText: 'Label'),
            style: GoogleFonts.inter(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _imageUrlController,
            decoration: const InputDecoration(labelText: 'Image URL'),
            validator: _validateUrl,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: GoogleFonts.inter(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _targetUrlController,
            decoration: const InputDecoration(labelText: 'Target URL'),
            validator: _validateUrl,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: GoogleFonts.inter(),
          ),
          if (provider.elements.whereType<HeadingElement>().isNotEmpty) ...[
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Or link to section'),
              items: provider.elements.whereType<HeadingElement>().map((h) {
                final anchor = '#${h.text.toLowerCase().replaceAll(' ', '-')}';
                return DropdownMenuItem(
                  value: anchor,
                  child: Text(h.text, style: GoogleFonts.inter()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  element.targetUrl = value;
                  _notifyUpdate();
                }
              },
            ),
          ],
        ],
      );
    } else if (element is IconElement) {
      return Column(
        children: [
          Autocomplete<String>(
            initialValue: TextEditingValue(text: element.name),
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') {
                return const Iterable<String>.empty();
              }
              return DevIcons.icons.keys.where((String option) {
                return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (String selection) {
              element.name = selection;
              element.url = DevIcons.icons[selection]!;
              _nameController.text = selection;
              _urlController.text = element.url;
              _notifyUpdate();
            },
            fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
              // Sync local controller if needed, but Autocomplete manages its own.
              // We need to listen to it to update element name if user types something custom.
              return TextFormField(
                controller: textEditingController,
                focusNode: focusNode,
                decoration: const InputDecoration(labelText: 'Search Icon Name'),
                style: GoogleFonts.inter(),
                onFieldSubmitted: (String value) {
                  onFieldSubmitted();
                },
                onChanged: (val) {
                   element.name = val;
                   // If it matches a key exactly, update URL
                   if (DevIcons.icons.containsKey(val)) {
                     element.url = DevIcons.icons[val]!;
                     _urlController.text = element.url;
                   }
                   _notifyUpdate();
                },
              );
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _urlController,
            decoration: const InputDecoration(labelText: 'Icon URL'),
            validator: _validateUrl,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: GoogleFonts.inter(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _widthController,
            decoration: const InputDecoration(labelText: 'Size'),
            style: GoogleFonts.inter(),
          ),
          const SizedBox(height: 8),
          Text('Tip: Use devicon.dev or simpleicons.org for URLs', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
        ],
      );
    } else if (element is EmbedElement) {
      return Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: element.typeName,
            decoration: const InputDecoration(labelText: 'Embed Type'),
            items: [
              DropdownMenuItem(value: 'gist', child: Text('GitHub Gist', style: GoogleFonts.inter())),
              DropdownMenuItem(value: 'codepen', child: Text('CodePen', style: GoogleFonts.inter())),
              DropdownMenuItem(value: 'youtube', child: Text('YouTube', style: GoogleFonts.inter())),
            ],
            onChanged: (value) {
              if (value != null) {
                element.typeName = value;
                _notifyUpdate();
              }
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: 'Embed URL',
              suffixIcon: element.typeName == 'youtube'
                  ? IconButton(
                      icon: const Icon(Icons.search),
                      tooltip: 'Search Video',
                      onPressed: () async {
                        final url = await showDialog<String>(
                          context: context,
                          builder: (context) => _YouTubeHelperDialog(initialUrl: _urlController.text),
                        );
                        if (url != null) {
                          _urlController.text = url;
                          element.url = url;
                          _notifyUpdate();
                        }
                      },
                    )
                  : element.typeName == 'codepen'
                      ? IconButton(
                          icon: const Icon(Icons.search),
                          tooltip: 'CodePen Helper',
                          onPressed: () async {
                            final url = await showDialog<String>(
                              context: context,
                              builder: (context) => _CodePenHelperDialog(initialUrl: _urlController.text),
                            );
                            if (url != null) {
                              _urlController.text = url;
                              element.url = url;
                              _notifyUpdate();
                            }
                          },
                        )
                      : element.typeName == 'gist'
                          ? IconButton(
                              icon: const Icon(Icons.search),
                              tooltip: 'Gist Helper',
                              onPressed: () async {
                                final url = await showDialog<String>(
                                  context: context,
                                  builder: (context) => _GistHelperDialog(initialUrl: _urlController.text),
                                );
                                if (url != null) {
                                  _urlController.text = url;
                                  element.url = url;
                                  _notifyUpdate();
                                }
                              },
                            )
                          : null,
            ),
            validator: _validateUrl,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: GoogleFonts.inter(),
          ),
        ],
      );
    } else if (element is GitHubStatsElement) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _textController,
                  decoration: const InputDecoration(labelText: 'Repo Name (user/repo)'),
                  style: GoogleFonts.inter(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.download),
                tooltip: 'Fetch Info',
                onPressed: () async {
                  if (_textController.text.isEmpty) return;
                  final parts = _textController.text.split('/');
                  if (parts.length != 2) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid format. Use user/repo')));
                    return;
                  }

                  final service = GitHubService();
                  final data = await service.fetchRepoDetails(parts[0], parts[1]);
                  if (!context.mounted) return;

                  if (data != null) {
                    // We could populate other fields or show a dialog with info
                    // For now, let's just show a success message and maybe update description if we had one
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Found: ${data['description'] ?? 'No description'}')));
                    // If we want to use this data to populate the README, we might need a way to pass it back to the provider or add new elements.
                    // But for this specific element, it just shows stats.
                    // Let's offer to add the description as a paragraph?
                    if (data['description'] != null) {
                       showSafeDialog(
                         context,
                         builder: (dialogContext) => AlertDialog(
                           title: const Text('Add Description?'),
                           content: Text(data['description']),
                           actions: [
                             TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('No')),
                             TextButton(
                               onPressed: () {
                                 Provider.of<ProjectProvider>(context, listen: false).addElement(ReadmeElementType.paragraph);
                                 final provider = Provider.of<ProjectProvider>(context, listen: false);
                                 final last = provider.elements.last;
                                 if (last is ParagraphElement) {
                                   last.text = data['description'];
                                   provider.updateElement();
                                 }
                                 Navigator.pop(dialogContext);
                               },
                               child: const Text('Add as Paragraph')
                             ),
                           ],
                         ),
                       );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Repo not found')));
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text('Show Stars', style: GoogleFonts.inter()),
            value: element.showStars,
            onChanged: (val) {
              setState(() => element.showStars = val);
              _notifyUpdate();
            },
          ),
          SwitchListTile(
            title: Text('Show Forks', style: GoogleFonts.inter()),
            value: element.showForks,
            onChanged: (val) {
              setState(() => element.showForks = val);
              _notifyUpdate();
            },
          ),
          SwitchListTile(
            title: Text('Show Issues', style: GoogleFonts.inter()),
            value: element.showIssues,
            onChanged: (val) {
              setState(() => element.showIssues = val);
              _notifyUpdate();
            },
          ),
          SwitchListTile(
            title: Text('Show License', style: GoogleFonts.inter()),
            value: element.showLicense,
            onChanged: (val) {
              setState(() => element.showLicense = val);
              _notifyUpdate();
            },
          ),
        ],
      );
    } else if (element is ContributorsElement) {
      return Column(
        children: [
          TextFormField(
            controller: _textController,
            decoration: const InputDecoration(labelText: 'Repo Name (user/repo)'),
            style: GoogleFonts.inter(),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: element.style,
            decoration: const InputDecoration(labelText: 'Style'),
            items: [
              DropdownMenuItem(value: 'grid', child: Text('Grid (Avatars)', style: GoogleFonts.inter())),
              DropdownMenuItem(value: 'list', child: Text('List (Names)', style: GoogleFonts.inter())),
            ],
            onChanged: (value) {
              if (value != null) {
                element.style = value;
                _notifyUpdate();
              }
            },
          ),
        ],
      );
    } else if (element is TableElement) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Col'),
                onPressed: () {
                  setState(() {
                    element.headers.add('Header');
                    element.alignments.add(ColumnAlignment.left);
                    for (var row in element.rows) {
                      row.add('Cell');
                    }
                  });
                  _notifyUpdate();
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.remove),
                label: const Text('Col'),
                onPressed: element.headers.length > 1 ? () {
                  setState(() {
                    element.headers.removeLast();
                    if (element.alignments.length > element.headers.length) {
                       element.alignments.removeLast();
                    }
                    for (var row in element.rows) {
                      if (row.length > element.headers.length) {
                        row.removeLast();
                      }
                    }
                  });
                  _notifyUpdate();
                } : null,
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Row'),
                onPressed: () {
                  setState(() {
                    // Create a new growable list for the row
                    element.rows.add(List.generate(element.headers.length, (_) => 'Cell'));
                  });
                  _notifyUpdate();
                },
              ),
            ],
          ),
          const Divider(),
          Text('Columns & Headers', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: element.headers.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: element.headers[index],
                        decoration: InputDecoration(labelText: 'Header ${index + 1}'),
                        onChanged: (val) {
                          element.headers[index] = val;
                          _notifyUpdate();
                        },
                      ),
                      DropdownButton<ColumnAlignment>(
                        value: element.alignments[index],
                        isExpanded: true,
                        items: ColumnAlignment.values.map((a) {
                          return DropdownMenuItem(
                            value: a,
                            child: Text(a.toString().split('.').last),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              element.alignments[index] = val;
                            });
                            _notifyUpdate();
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Text('Rows Data', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...element.rows.asMap().entries.map((entry) {
            final rowIndex = entry.key;
            final row = entry.value;
            return ExpansionTile(
              title: Text('Row ${rowIndex + 1}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    element.rows.removeAt(rowIndex);
                  });
                  _notifyUpdate();
                },
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: row.asMap().entries.map((cellEntry) {
                      final colIndex = cellEntry.key;
                      // Safety check: ensure colIndex is within headers bounds
                      if (colIndex >= element.headers.length) return const SizedBox.shrink();

                      return SizedBox(
                        width: 140,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: cellEntry.value,
                                decoration: InputDecoration(
                                  labelText: element.headers[colIndex],
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                ),
                                onChanged: (val) {
                                  row[colIndex] = val;
                                  _notifyUpdate();
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.image, size: 16),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: 'Insert Image/Badge',
                              onPressed: () async {
                                final result = await showDialog<String>(
                                  context: context,
                                  builder: (context) => _TableCellImageDialog(initialValue: row[colIndex]),
                                );
                                if (result != null) {
                                  setState(() {
                                    row[colIndex] = result;
                                  });
                                  _notifyUpdate();
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          }),
        ],
      );
    } else if (element is MermaidElement) {
      return Column(
        children: [
          TextFormField(
            controller: _codeController,
            decoration: const InputDecoration(labelText: 'Mermaid Code'),
            maxLines: 10,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Examples:\ngraph TD; A-->B;\ngantt\n  title A Gantt Diagram\n  section Section\n  A task :a1, 2014-01-01, 30d',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      );
    } else if (element is TOCElement) {
      return Column(
        children: [
          TextFormField(
            controller: _textController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 8),
          const Text('This element will automatically generate a table of contents based on headings in your project.', style: TextStyle(color: Colors.grey)),
        ],
      );
    } else if (element is BlockquoteElement) {
      return Column(
        children: [
          TextFormField(
            controller: _textController,
            decoration: const InputDecoration(labelText: 'Quote Text'),
            maxLines: 5,
          ),
        ],
      );
    } else if (element is DividerElement) {
      return const Center(child: Text('Horizontal Divider (---)'));
    } else if (element is CollapsibleElement) {
      return Column(
        children: [
          TextFormField(
            controller: _textController,
            decoration: const InputDecoration(labelText: 'Summary (Title)'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _codeController,
            decoration: const InputDecoration(labelText: 'Content (Markdown supported)'),
            maxLines: 10,
          ),
        ],
      );
    } else if (element is SocialsElement) {
      return _buildSocialsForm(element);
    }

    return const Center(child: Text('No settings for this element'));
  }

  Widget _buildSocialsForm(SocialsElement element) {
    return Column(
      children: [
        InputDecorator(
          decoration: const InputDecoration(labelText: 'Badge Style', border: OutlineInputBorder()),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: element.style,
              isDense: true,
              items: [
                DropdownMenuItem(value: 'for-the-badge', child: Text('For The Badge', style: GoogleFonts.inter())),
                DropdownMenuItem(value: 'flat', child: Text('Flat', style: GoogleFonts.inter())),
                DropdownMenuItem(value: 'flat-square', child: Text('Flat Square', style: GoogleFonts.inter())),
                DropdownMenuItem(value: 'plastic', child: Text('Plastic', style: GoogleFonts.inter())),
                DropdownMenuItem(value: 'social', child: Text('Social', style: GoogleFonts.inter())),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    element.style = value;
                  });
                  _notifyUpdate();
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Profiles', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...element.profiles.asMap().entries.map((entry) {
          final index = entry.key;
          final profile = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withAlpha(80)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        InputDecorator(
                          decoration: const InputDecoration(labelText: 'Platform', isDense: true, border: OutlineInputBorder()),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: SocialPlatforms.platforms.containsKey(profile.platform) ? profile.platform : null,
                              isDense: true,
                              items: SocialPlatforms.platforms.keys.map((key) {
                                final platform = SocialPlatforms.platforms[key];
                                return DropdownMenuItem(
                                  value: key,
                                  child: Row(
                                    children: [
                                      if (platform != null) ...[
                                        Icon(platform.icon, size: 16, color: Color(int.parse('0xFF${platform.color}'))),
                                        const SizedBox(width: 8),
                                      ],
                                      Text(key, style: GoogleFonts.inter()),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    element.profiles[index] = SocialProfile(platform: value, username: profile.username);
                                  });
                                  _notifyUpdate();
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (profile.platform == 'Phone')
                          Row(
                            children: [
                              SizedBox(
                                width: 110,
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Code',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  ),
                                  items: [
                                    DropdownMenuItem(value: '', child: Text('Manual', overflow: TextOverflow.ellipsis, style: GoogleFonts.inter())),
                                    ...CountryCodes.list.map((c) => DropdownMenuItem(
                                      value: '+${c.code}',
                                      child: Text('${c.emoji} +${c.code}', overflow: TextOverflow.ellipsis, style: GoogleFonts.inter()),
                                    )),
                                  ],
                                  onChanged: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      String current = profile.username;
                                      if (!current.startsWith('+')) {
                                        element.profiles[index] = SocialProfile(platform: profile.platform, username: '$value$current');
                                        _notifyUpdate();
                                      }
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  initialValue: profile.username,
                                  decoration: const InputDecoration(labelText: 'Phone Number', isDense: true),
                                  style: GoogleFonts.inter(),
                                  onChanged: (value) {
                                    element.profiles[index] = SocialProfile(platform: profile.platform, username: value);
                                    _notifyUpdate();
                                  },
                                ),
                              ),
                            ],
                          )
                        else
                          TextFormField(
                            initialValue: profile.username,
                            decoration: const InputDecoration(labelText: 'Username / Handle', isDense: true),
                            style: GoogleFonts.inter(),
                            onChanged: (value) {
                              element.profiles[index] = SocialProfile(platform: profile.platform, username: value);
                              _notifyUpdate();
                            },
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        element.profiles.removeAt(index);
                      });
                      _notifyUpdate();
                    },
                  ),
                ],
              ),
            ),
          );
        }),
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add Profile'),
          onPressed: () {
            setState(() {
              element.profiles.add(SocialProfile(platform: 'GitHub', username: ''));
            });
            _notifyUpdate();
          },
        ),
      ],
    );
  }
}

class _TableCellImageDialog extends StatefulWidget {
  final String initialValue;

  const _TableCellImageDialog({required this.initialValue});

  @override
  State<_TableCellImageDialog> createState() => __TableCellImageDialogState();
}

class __TableCellImageDialogState extends State<_TableCellImageDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Cell Content', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Content (Text, Markdown, HTML)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              style: GoogleFonts.inter(),
            ),
            const SizedBox(height: 16),
            Text('Insert Media:', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.image, size: 18),
                  label: const Text('Image URL'),
                  onPressed: () {
                    _insertText('![Alt Text](https://example.com/image.png)');
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.shield, size: 18),
                  label: const Text('Badge'),
                  onPressed: () {
                    _insertText('![Label](https://img.shields.io/badge/Label-Message-blue)');
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.emoji_emotions, size: 18),
                  label: const Text('Icon'),
                  onPressed: () {
                    // Simple icon insertion
                    _insertText('<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/flutter/flutter-original.svg" width="20" height="20" alt="icon"/>');
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.gif, size: 18),
                  label: const Text('GIPHY'),
                  onPressed: () async {
                    final url = await showDialog<String>(
                      context: context,
                      builder: (context) => const GiphyPickerDialog(),
                    );
                    if (url != null) {
                      _insertText('![GIF]($url)');
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _insertText(String text) {
    final currentText = _controller.text;
    final selection = _controller.selection;
    if (selection.isValid) {
      final newText = currentText.replaceRange(selection.start, selection.end, text);
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + text.length),
      );
    } else {
      _controller.text = currentText + text;
    }
  }
}

class _YouTubeHelperDialog extends StatefulWidget {
  final String initialUrl;

  const _YouTubeHelperDialog({required this.initialUrl});

  @override
  State<_YouTubeHelperDialog> createState() => _YouTubeHelperDialogState();
}

class _YouTubeHelperDialogState extends State<_YouTubeHelperDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('YouTube URL Helper', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To embed a YouTube video, paste the video URL below. We will help you extract the video ID if needed.', style: GoogleFonts.inter()),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'YouTube Video URL',
                border: OutlineInputBorder(),
              ),
              style: GoogleFonts.inter(),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            Text('Preview:', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              width: double.maxFinite,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Builder(builder: (context) {
                  final url = _controller.text;
                  final videoId = _extractVideoId(url);
                  if (videoId != null) {
                    // Simple thumbnail preview using YouTube thumbnail URL pattern
                    return Image.network(
                      'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.black12,
                        child: const Center(child: Text('Thumbnail not found', style: TextStyle(color: Colors.red))),
                      ),
                    );
                  } else {
                    return Container(
                      color: Colors.black12,
                      child: const Center(child: Text('Invalid URL or ID not found', style: TextStyle(color: Colors.grey))),
                    );
                  }
                }),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final url = _controller.text;
            final videoId = _extractVideoId(url);
            if (videoId != null) {
              // We return the original URL or a formatted one.
              // Markdown generator handles the thumbnail generation if we pass the watch URL.
              // But user might want the embed URL for other purposes.
              // Let's return the watch URL as it's more standard for the generator to parse ID.
              // Or we can return the embed URL if the generator expects it.
              // The generator expects `element.url`.
              // Let's return the standard watch URL constructed from ID to be safe.
              final standardUrl = 'https://www.youtube.com/watch?v=$videoId';
              Navigator.pop(context, standardUrl);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid YouTube URL')));
            }
          },
          child: const Text('Use This Video'),
        ),
      ],
    );
  }

  String? _extractVideoId(String url) {
    if (url.isEmpty) return null;
    // Very simple YouTube URL parser
    // Supports:
    // - https://www.youtube.com/watch?v=VIDEO_ID
    // - https://youtu.be/VIDEO_ID
    // - https://www.youtube.com/embed/VIDEO_ID
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.host.contains('youtube.com')) {
      if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'embed') {
         return uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
      }
      return uri.queryParameters['v'];
    } else if (uri.host == 'youtu.be') {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;
    }

    return null;
  }
}

class _CodePenHelperDialog extends StatefulWidget {
  final String initialUrl;

  const _CodePenHelperDialog({required this.initialUrl});

  @override
  State<_CodePenHelperDialog> createState() => _CodePenHelperDialogState();
}

class _CodePenHelperDialogState extends State<_CodePenHelperDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('CodePen Helper', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Paste your CodePen URL. We will generate a preview image link for your README.', style: GoogleFonts.inter()),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'CodePen URL',
                hintText: 'https://codepen.io/user/pen/slug',
                border: OutlineInputBorder(),
              ),
              style: GoogleFonts.inter(),
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Text('Preview:', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              width: double.maxFinite,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Builder(builder: (context) {
                  final url = _controller.text;
                  final uri = Uri.tryParse(url);
                  if (uri != null && uri.host.contains('codepen.io') && uri.pathSegments.length >= 3) {
                    final user = uri.pathSegments[0];
                    final slug = uri.pathSegments[2];
                    final imageUrl = 'https://shots.codepen.io/$user/pen/$slug-800.jpg';
                    return Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.black12,
                        child: const Center(child: Text('Preview not available', style: TextStyle(color: Colors.grey))),
                      ),
                    );
                  } else {
                    return Container(
                      color: Colors.black12,
                      child: const Center(child: Text('Invalid CodePen URL', style: TextStyle(color: Colors.grey))),
                    );
                  }
                }),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, _controller.text);
          },
          child: const Text('Use This Pen'),
        ),
      ],
    );
  }
}

class _GistHelperDialog extends StatefulWidget {
  final String initialUrl;

  const _GistHelperDialog({required this.initialUrl});

  @override
  State<_GistHelperDialog> createState() => _GistHelperDialogState();
}

class _GistHelperDialogState extends State<_GistHelperDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('GitHub Gist Helper', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Paste your Gist URL or ID.', style: GoogleFonts.inter()),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Gist URL / ID',
                hintText: 'https://gist.github.com/user/id',
                border: OutlineInputBorder(),
              ),
              style: GoogleFonts.inter(),
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 16),
            if (_isValidGist(_controller.text))
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(child: Text('Valid Gist URL format')),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            String url = _controller.text;
            if (!url.startsWith('http')) {
              // Assume ID
              url = 'https://gist.github.com/$url';
            }
            Navigator.pop(context, url);
          },
          child: const Text('Use This Gist'),
        ),
      ],
    );
  }

  bool _isValidGist(String url) {
    if (url.isEmpty) return false;
    if (url.contains('gist.github.com')) return true;
    // Simple ID check (hex)
    final hexRegex = RegExp(r'^[a-f0-9]+$');
    if (hexRegex.hasMatch(url) && url.length > 10) return true;
    return false;
  }
}

