import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:markdown/markdown.dart' as md;
import '../models/readme_element.dart';
import '../widgets/components_panel.dart';
import '../widgets/editor_canvas.dart';
import '../widgets/settings_panel.dart';
import '../providers/project_provider.dart';
import '../providers/library_provider.dart';
import '../utils/templates.dart';
import '../utils/project_exporter.dart';
import '../utils/downloader.dart';
import '../utils/onboarding_helper.dart';
import 'projects_library_screen.dart';
import '../generator/markdown_generator.dart';
import 'social_preview_screen.dart';
import 'github_actions_generator.dart';
import '../services/health_check_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _componentsKey = GlobalKey();
  final GlobalKey _canvasKey = GlobalKey();
  final GlobalKey _settingsKey = GlobalKey();
  final GlobalKey _exportKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showPreview = false;
  bool _isFocusMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OnboardingHelper.showOnboarding(
        context: context,
        componentsKey: _componentsKey,
        canvasKey: _canvasKey,
        settingsKey: _settingsKey,
        exportKey: _exportKey,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Advanced Readme Creator'),
        actions: isDesktop ? _buildDesktopActions(context) : _buildMobileActions(context),
      ),
      drawer: isDesktop ? null : const Drawer(child: ComponentsPanel()),
      endDrawer: isDesktop ? null : const Drawer(child: SettingsPanel()),
      body: isDesktop ? _buildDesktopBody(context) : _buildMobileBody(context),
    );
  }

  List<Widget> _buildDesktopActions(BuildContext context) {
    return [
      Consumer<ProjectProvider>(
        builder: (context, provider, child) {
          return Row(
            children: [
              // Device Mode Toggles
              IconButton(
                icon: const Icon(Icons.desktop_mac),
                color: provider.deviceMode == DeviceMode.desktop ? Colors.blue : null,
                tooltip: 'Desktop View',
                onPressed: () => provider.setDeviceMode(DeviceMode.desktop),
              ),
              IconButton(
                icon: const Icon(Icons.tablet_mac),
                color: provider.deviceMode == DeviceMode.tablet ? Colors.blue : null,
                tooltip: 'Tablet View',
                onPressed: () => provider.setDeviceMode(DeviceMode.tablet),
              ),
              IconButton(
                icon: const Icon(Icons.phone_iphone),
                color: provider.deviceMode == DeviceMode.mobile ? Colors.blue : null,
                tooltip: 'Mobile View',
                onPressed: () => provider.setDeviceMode(DeviceMode.mobile),
              ),
              const VerticalDivider(),
              PopupMenuButton<ProjectTemplate>(
                tooltip: 'Templates',
                icon: const Icon(Icons.file_copy),
                onSelected: (template) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Load ${template.name}?'),
                      content: const Text('This will replace your current workspace.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            provider.loadTemplate(template);
                            Navigator.pop(context);
                          },
                          child: const Text('Load'),
                        ),
                      ],
                    ),
                  );
                },
                itemBuilder: (context) => Templates.all.map((t) {
                  return PopupMenuItem(
                    value: t,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(t.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  );
                }).toList(),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Project Settings',
                onPressed: () => _showProjectSettingsDialog(context, provider),
              ),
              IconButton(
                icon: Icon(provider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                tooltip: 'Toggle Theme',
                onPressed: () => provider.toggleTheme(),
              ),
              IconButton(
                icon: Icon(provider.showGrid ? Icons.grid_on : Icons.grid_off),
                tooltip: 'Toggle Grid',
                onPressed: () => provider.toggleGrid(),
              ),
              IconButton(
                icon: Icon(_isFocusMode ? Icons.fullscreen_exit : Icons.fullscreen),
                tooltip: _isFocusMode ? 'Exit Focus Mode' : 'Focus Mode',
                onPressed: () {
                  setState(() {
                    _isFocusMode = !_isFocusMode;
                  });
                },
              ),
              const VerticalDivider(),
              IconButton(
                icon: const Icon(Icons.library_books),
                tooltip: 'My Projects Library',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProjectsLibraryScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.health_and_safety),
                tooltip: 'Health Check',
                onPressed: () {
                  final issues = HealthCheckService.analyze(provider.elements);
                  _showHealthCheckDialog(context, issues, provider);
                },
              ),
              IconButton(
                icon: const Icon(Icons.print),
                tooltip: 'Print / Export PDF',
                onPressed: () => _printReadme(context, provider),
              ),
            ],
          );
        },
      ),
      IconButton(
        key: _exportKey,
        icon: const Icon(Icons.download),
        tooltip: 'Export Project',
        onPressed: () {
          final provider = Provider.of<ProjectProvider>(context, listen: false);
          ProjectExporter.export(
            elements: provider.elements,
            variables: provider.variables,
            licenseType: provider.licenseType,
            includeContributing: provider.includeContributing,
            listBullet: provider.listBullet,
            sectionSpacing: provider.sectionSpacing,
            exportHtml: provider.exportHtml,
          );
        },
      ),
      _buildMoreOptionsButton(context),
    ];
  }

  List<Widget> _buildMobileActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.settings),
        tooltip: 'Settings',
        onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
      ),
      _buildMoreOptionsButton(context),
    ];
  }

  Widget _buildMoreOptionsButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'More Options',
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'save_library',
          child: Row(children: [Icon(Icons.save_alt, color: Colors.grey), SizedBox(width: 8), Text('Save to Library')]),
        ),
        const PopupMenuItem(
          value: 'snapshots',
          child: Row(children: [Icon(Icons.history, color: Colors.grey), SizedBox(width: 8), Text('Local Snapshots')]),
        ),
        const PopupMenuItem(
          value: 'clear_workspace',
          child: Row(children: [Icon(Icons.delete_forever, color: Colors.red), SizedBox(width: 8), Text('Clear Workspace', style: TextStyle(color: Colors.red))]),
        ),
        const PopupMenuItem(
          value: 'import_markdown',
          child: Row(children: [Icon(Icons.file_upload, color: Colors.grey), SizedBox(width: 8), Text('Import Markdown')]),
        ),
        const PopupMenuItem(
          value: 'social_preview',
          child: Row(children: [Icon(Icons.image, color: Colors.grey), SizedBox(width: 8), Text('Social Preview Designer')]),
        ),
        const PopupMenuItem(
          value: 'github_actions',
          child: Row(children: [Icon(Icons.build, color: Colors.grey), SizedBox(width: 8), Text('GitHub Actions Generator')]),
        ),
        const PopupMenuItem(
          value: 'export_json',
          child: Row(children: [Icon(Icons.javascript, color: Colors.grey), SizedBox(width: 8), Text('Export Project (JSON)')]),
        ),
        const PopupMenuItem(
          value: 'import_json',
          child: Row(children: [Icon(Icons.data_object, color: Colors.grey), SizedBox(width: 8), Text('Import Project (JSON)')]),
        ),
        const PopupMenuItem(
          value: 'help',
          child: Row(children: [Icon(Icons.help_outline, color: Colors.grey), SizedBox(width: 8), Text('Show Tour')]),
        ),
      ],
      onSelected: (value) async {
        final provider = Provider.of<ProjectProvider>(context, listen: false);
        if (value == 'save_library') {
          _showSaveToLibraryDialog(context, provider);
        } else if (value == 'snapshots') {
          _showSnapshotsDialog(context, provider);
        } else if (value == 'clear_workspace') {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Clear Workspace?'),
              content: const Text('This will remove all elements. This action cannot be undone (unless you have a snapshot).'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    provider.clearElements();
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Clear'),
                ),
              ],
            ),
          );
        } else if (value == 'import_markdown') {
          _showImportMarkdownDialog(context, provider);
        } else if (value == 'social_preview') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SocialPreviewScreen()),
          );
        } else if (value == 'github_actions') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GitHubActionsGenerator()),
          );
        } else if (value == 'export_json') {
          final json = provider.exportToJson();
          downloadJsonFile(json, 'readme_project.json');
        } else if (value == 'import_json') {
          try {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['json'],
            );

            if (result != null) {
              String? content;
              if (result.files.first.bytes != null) {
                content = utf8.decode(result.files.first.bytes!);
              }
              if (content != null) {
                provider.importFromJson(content);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Project imported successfully')));
                }
              }
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error importing: $e')));
            }
          }
        } else if (value == 'help') {
          OnboardingHelper.restartOnboarding(
            context: context,
            componentsKey: _componentsKey,
            canvasKey: _canvasKey,
            settingsKey: _settingsKey,
            exportKey: _exportKey,
          );
        }
      },
    );
  }

  Widget _buildDesktopBody(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              if (!_isFocusMode)
                Expanded(
                  flex: 2,
                  child: Container(
                    key: _componentsKey,
                    child: const ComponentsPanel(),
                  ),
                ),
              if (!_isFocusMode) const VerticalDivider(width: 1),
              Expanded(
                flex: 5,
                child: Container(
                  key: _canvasKey,
                  child: const EditorCanvas(),
                ),
              ),
              if (_showPreview) ...[
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 4,
                  child: Container(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[50],
                    child: Consumer<ProjectProvider>(
                      builder: (context, provider, _) {
                        final generator = MarkdownGenerator();
                        final markdown = generator.generate(provider.elements);
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: SelectableText(
                            markdown,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
              if (!_isFocusMode) const VerticalDivider(width: 1),
              if (!_isFocusMode)
                Expanded(
                  flex: 3,
                  child: Container(
                    key: _settingsKey,
                    child: const SettingsPanel(),
                  ),
                ),
            ],
          ),
        ),
        _buildStatusBar(context),
      ],
    );
  }

  Widget _buildMobileBody(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            key: _canvasKey,
            child: const EditorCanvas(),
          ),
        ),
        _buildStatusBar(context),
      ],
    );
  }

  Widget _buildStatusBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0), // Slate 800 / Slate 200
        border: Border(top: BorderSide(color: isDark ? Colors.black12 : Colors.white54)),
      ),
      child: Consumer<ProjectProvider>(
        builder: (context, provider, _) {
          final elementCount = provider.elements.length;
          final wordCount = provider.elements.fold<int>(0, (sum, e) {
            if (e is HeadingElement) {
              return sum + (e as HeadingElement).text.split(' ').length;
            }
            if (e is ParagraphElement) {
              return sum + (e as ParagraphElement).text.split(' ').length;
            }
            return sum;
          });

          final issues = HealthCheckService.analyze(provider.elements);
          final errorCount = issues.where((i) => i.severity == IssueSeverity.error).length;
          final warningCount = issues.where((i) => i.severity == IssueSeverity.warning).length;

          return Row(
            children: [
              Icon(Icons.widgets_outlined, size: 14, color: isDark ? Colors.white70 : Colors.black54),
              const SizedBox(width: 4),
              Text('$elementCount Elements', style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87)),
              const SizedBox(width: 16),
              Icon(Icons.text_fields, size: 14, color: isDark ? Colors.white70 : Colors.black54),
              const SizedBox(width: 4),
              Text('$wordCount Words', style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87)),
              const SizedBox(width: 16),
              if (errorCount > 0 || warningCount > 0)
                InkWell(
                  onTap: () => _showHealthCheckDialog(context, issues, provider),
                  child: Row(
                    children: [
                      if (errorCount > 0) ...[
                        const Icon(Icons.error, size: 14, color: Colors.redAccent),
                        const SizedBox(width: 4),
                        Text('$errorCount Errors', style: const TextStyle(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                      ],
                      if (warningCount > 0) ...[
                        const Icon(Icons.warning, size: 14, color: Colors.orangeAccent),
                        const SizedBox(width: 4),
                        Text('$warningCount Warnings', style: const TextStyle(fontSize: 11, color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                      ],
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    const Icon(Icons.check_circle, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text('Healthy', style: TextStyle(fontSize: 11, color: Colors.green[700], fontWeight: FontWeight.bold)),
                  ],
                ),
              const Spacer(),
              if (_isFocusMode)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('FOCUS MODE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                ),
              const SizedBox(width: 12),
              Icon(Icons.cloud_done, size: 14, color: isDark ? Colors.white54 : Colors.black45),
              const SizedBox(width: 4),
              Text('Auto-saved', style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black45)),
            ],
          );
        },
      ),
    );
  }

  void _showProjectSettingsDialog(BuildContext context, ProjectProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Project Settings'),
        content: SizedBox(
          width: 500,
          child: DefaultTabController(
            length: 5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TabBar(
                  labelColor: Colors.blue,
                  isScrollable: true,
                  tabs: [
                    Tab(text: 'Variables'),
                    Tab(text: 'License'),
                    Tab(text: 'Contributing'),
                    Tab(text: 'Colors'),
                    Tab(text: 'Formatting'),
                  ],
                ),
                SizedBox(
                  height: 300,
                  child: TabBarView(
                    children: [
                      // Variables Tab
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: provider.variables.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: TextFormField(
                                initialValue: entry.value,
                                decoration: InputDecoration(
                                  labelText: entry.key,
                                  border: const OutlineInputBorder(),
                                ),
                                onChanged: (value) => provider.updateVariable(entry.key, value),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      // License Tab
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Select License for your project:'),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              initialValue: provider.licenseType,
                              decoration: const InputDecoration(border: OutlineInputBorder()),
                              items: const [
                                DropdownMenuItem(value: 'None', child: Text('None')),
                                DropdownMenuItem(value: 'MIT', child: Text('MIT License')),
                                DropdownMenuItem(value: 'Apache 2.0', child: Text('Apache License 2.0')),
                              ],
                              onChanged: (value) {
                                if (value != null) provider.setLicenseType(value);
                              },
                            ),
                            const SizedBox(height: 16),
                            const Text('A LICENSE file will be generated and included in the export.', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      // Contributing Tab
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text('Include CONTRIBUTING.md'),
                              subtitle: const Text('Adds a standard contributing guide to the export.'),
                              value: provider.includeContributing,
                              onChanged: (value) => provider.setIncludeContributing(value),
                            ),
                          ],
                        ),
                      ),
                      // Colors Tab
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ListTile(
                              title: const Text('Primary Color'),
                              subtitle: Text('#${provider.primaryColor.toARGB32().toRadixString(16).toUpperCase().substring(2)}'),
                              trailing: CircleAvatar(backgroundColor: provider.primaryColor),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Pick Primary Color'),
                                    content: SingleChildScrollView(
                                      child: ColorPicker(
                                        pickerColor: provider.primaryColor,
                                        onColorChanged: (color) => provider.setPrimaryColor(color),
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
                              title: const Text('Secondary Color'),
                              subtitle: Text('#${provider.secondaryColor.toARGB32().toRadixString(16).toUpperCase().substring(2)}'),
                              trailing: CircleAvatar(backgroundColor: provider.secondaryColor),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Pick Secondary Color'),
                                    content: SingleChildScrollView(
                                      child: ColorPicker(
                                        pickerColor: provider.secondaryColor,
                                        onColorChanged: (color) => provider.setSecondaryColor(color),
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
                          ],
                        ),
                      ),
                      // Formatting Tab
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text('Export HTML'),
                              subtitle: const Text('Include a formatted HTML file in the export.'),
                              value: provider.exportHtml,
                              onChanged: (value) => provider.setExportHtml(value),
                            ),
                            const Divider(),
                            InputDecorator(
                              decoration: const InputDecoration(labelText: 'List Bullet Style', border: OutlineInputBorder()),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: provider.listBullet,
                                  isDense: true,
                                  items: const [
                                    DropdownMenuItem(value: '*', child: Text('* (Asterisk)')),
                                    DropdownMenuItem(value: '-', child: Text('- (Dash)')),
                                    DropdownMenuItem(value: '+', child: Text('+ (Plus)')),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) provider.setListBullet(value);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            InputDecorator(
                              decoration: const InputDecoration(labelText: 'Section Spacing (Newlines)', border: OutlineInputBorder()),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: provider.sectionSpacing,
                                  isDense: true,
                                  items: const [
                                    DropdownMenuItem(value: 0, child: Text('0 (Compact)')),
                                    DropdownMenuItem(value: 1, child: Text('1 (Standard)')),
                                    DropdownMenuItem(value: 2, child: Text('2 (Spacious)')),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) provider.setSectionSpacing(value);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSnapshotsDialog(BuildContext context, ProjectProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Local Snapshots'),
        content: SizedBox(
          width: 400,
          height: 400,
          child: Column(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Create New Snapshot'),
                onPressed: () {
                  provider.saveSnapshot();
                  Navigator.pop(context);
                  _showSnapshotsDialog(context, provider); // Reopen to show new snapshot
                },
              ),
              const Divider(),
              Expanded(
                child: provider.snapshots.isEmpty
                    ? const Center(child: Text('No snapshots saved.'))
                    : ListView.builder(
                        itemCount: provider.snapshots.length,
                        itemBuilder: (context, index) {
                          // We don't have timestamps in the snapshot string currently,
                          // but we could parse it to show some info, or just show "Snapshot #".
                          // Since it's a stack, index 0 is latest.
                          return ListTile(
                            leading: const Icon(Icons.history),
                            title: Text('Snapshot ${provider.snapshots.length - index}'),
                            subtitle: index == 0 ? const Text('Latest') : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.restore),
                                  tooltip: 'Restore',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Restore Snapshot?'),
                                        content: const Text('Current work will be replaced.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              provider.restoreSnapshot(index);
                                              Navigator.pop(context); // Close confirm
                                              Navigator.pop(context); // Close list
                                            },
                                            child: const Text('Restore'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'Delete',
                                  onPressed: () {
                                    provider.deleteSnapshot(index);
                                    Navigator.pop(context);
                                    _showSnapshotsDialog(context, provider);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _printReadme(BuildContext context, ProjectProvider provider) async {
    final markdownGenerator = MarkdownGenerator();
    final readmeContent = markdownGenerator.generate(
      provider.elements,
      variables: provider.variables,
      listBullet: provider.listBullet,
      sectionSpacing: provider.sectionSpacing,
    );

    final htmlContent = md.markdownToHtml(
      readmeContent,
      extensionSet: md.ExtensionSet.gitHubWeb,
    );

    final fullHtml = '''
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
body { font-family: sans-serif; line-height: 1.5; padding: 20px; }
h1, h2, h3 { margin-top: 24px; margin-bottom: 16px; font-weight: 600; }
h1 { font-size: 2em; border-bottom: 1px solid #eaecef; padding-bottom: .3em; }
h2 { font-size: 1.5em; border-bottom: 1px solid #eaecef; padding-bottom: .3em; }
code { background-color: #f6f8fa; padding: .2em .4em; border-radius: 6px; font-family: monospace; }
pre { background-color: #f6f8fa; padding: 16px; border-radius: 6px; overflow: auto; }
pre code { background-color: transparent; padding: 0; }
blockquote { border-left: .25em solid #d0d7de; color: #656d76; padding: 0 1em; margin: 0; }
table { border-spacing: 0; border-collapse: collapse; width: 100%; }
table th, table td { padding: 6px 13px; border: 1px solid #d0d7de; }
table tr:nth-child(2n) { background-color: #f6f8fa; }
img { max-width: 100%; }
</style>
</head>
<body>
$htmlContent
</body>
</html>
''';

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => await Printing.convertHtml(
        format: format,
        html: fullHtml,
      ),
    );
  }

  void _showSaveToLibraryDialog(BuildContext context, ProjectProvider provider) {
    final libraryProvider = Provider.of<LibraryProvider>(context, listen: false);
    final nameController = TextEditingController(text: provider.variables['PROJECT_NAME'] ?? 'My Project');
    final descController = TextEditingController();
    final tagsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save to Library'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Project Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tagsController,
                decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
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
              final tags = tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
              libraryProvider.saveProject(
                name: nameController.text,
                description: descController.text,
                tags: tags,
                jsonContent: provider.exportToJson(),
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Project saved to library')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showHealthCheckDialog(BuildContext context, List<HealthIssue> issues, ProjectProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Health Check'),
        content: SizedBox(
          width: 400,
          height: 300,
          child: ListView.builder(
            itemCount: issues.length,
            itemBuilder: (context, index) {
              final issue = issues[index];
              return ListTile(
                leading: Icon(
                  issue.severity == IssueSeverity.error ? Icons.error : (issue.severity == IssueSeverity.warning ? Icons.warning : Icons.info),
                  color: issue.severity == IssueSeverity.error ? Colors.red : (issue.severity == IssueSeverity.warning ? Colors.orange : Colors.blue),
                ),
                title: Text(issue.message, style: const TextStyle(fontSize: 14)),
                trailing: issue.elementId != null
                    ? IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          provider.selectElement(issue.elementId!);
                          Navigator.pop(context);
                        },
                      )
                    : null,
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showImportMarkdownDialog(BuildContext context, ProjectProvider provider) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Markdown'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Paste your Markdown content below or pick a file.'),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                maxLines: 10,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '# My Project\n\nDescription...',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Pick Markdown File'),
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['md', 'txt'],
                    withData: true,
                  );
                  if (result != null && result.files.isNotEmpty) {
                    final bytes = result.files.first.bytes;
                    if (bytes != null) {
                      textController.text = utf8.decode(bytes);
                    }
                  }
                },
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
              if (textController.text.isNotEmpty) {
                provider.importMarkdown(textController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Markdown imported successfully')));
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }
}

