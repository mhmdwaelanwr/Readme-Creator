import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/dracula.dart';

class GitHubActionsGenerator extends StatefulWidget {
  const GitHubActionsGenerator({super.key});

  @override
  State<GitHubActionsGenerator> createState() => _GitHubActionsGeneratorState();
}

class _GitHubActionsGeneratorState extends State<GitHubActionsGenerator> {
  bool _scheduleEnabled = true;
  String _cronSchedule = '0 0 * * *'; // Daily at midnight
  bool _pushEnabled = true;
  bool _workflowDispatchEnabled = true;

  // Actions
  bool _checkout = true;
  bool _setupNode = false;
  bool _updateFeed = false;
  String _feedUrl = '';
  bool _commitChanges = true;

  String _generateYaml() {
    final buffer = StringBuffer();
    buffer.writeln('name: Update README');
    buffer.writeln();
    buffer.writeln('on:');
    if (_scheduleEnabled) {
      buffer.writeln('  schedule:');
      buffer.writeln('    - cron: "$_cronSchedule"');
    }
    if (_pushEnabled) {
      buffer.writeln('  push:');
      buffer.writeln('    branches: [ main, master ]');
    }
    if (_workflowDispatchEnabled) {
      buffer.writeln('  workflow_dispatch:');
    }
    buffer.writeln();
    buffer.writeln('jobs:');
    buffer.writeln('  build:');
    buffer.writeln('    runs-on: ubuntu-latest');
    buffer.writeln('    steps:');

    if (_checkout) {
      buffer.writeln('      - uses: actions/checkout@v3');
    }

    if (_setupNode) {
      buffer.writeln('      - uses: actions/setup-node@v3');
      buffer.writeln('        with:');
      buffer.writeln('          node-version: 16');
    }

    if (_updateFeed && _feedUrl.isNotEmpty) {
      // Example using a popular action for RSS
      buffer.writeln('      - name: Update Feed');
      buffer.writeln('        uses: sarisia/actions-readme-feed@v1');
      buffer.writeln('        with:');
      buffer.writeln('          url: "$_feedUrl"');
      buffer.writeln('          file: "README.md"');
    }

    if (_commitChanges) {
      buffer.writeln('      - name: Commit changes');
      buffer.writeln('        run: |');
      buffer.writeln('          git config --global user.name "GitHub Actions Bot"');
      buffer.writeln('          git config --global user.email "actions@github.com"');
      buffer.writeln('          git add README.md');
      buffer.writeln('          git commit -m "Update README" || exit 0');
      buffer.writeln('          git push');
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub Actions Generator', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy YAML',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _generateYaml()));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Config
          Container(
            width: 350,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.withAlpha(50))),
            ),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Triggers', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text('Schedule (Cron)', style: GoogleFonts.inter()),
                  value: _scheduleEnabled,
                  onChanged: (val) => setState(() => _scheduleEnabled = val),
                ),
                if (_scheduleEnabled)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextFormField(
                      initialValue: _cronSchedule,
                      decoration: const InputDecoration(labelText: 'Cron Expression', border: OutlineInputBorder()),
                      style: GoogleFonts.firaCode(),
                      onChanged: (val) => setState(() => _cronSchedule = val),
                    ),
                  ),
                SwitchListTile(
                  title: Text('Push to main/master', style: GoogleFonts.inter()),
                  value: _pushEnabled,
                  onChanged: (val) => setState(() => _pushEnabled = val),
                ),
                SwitchListTile(
                  title: Text('Manual Dispatch', style: GoogleFonts.inter()),
                  value: _workflowDispatchEnabled,
                  onChanged: (val) => setState(() => _workflowDispatchEnabled = val),
                ),
                const Divider(),
                Text('Steps', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: Text('Checkout Repo', style: GoogleFonts.inter()),
                  value: _checkout,
                  onChanged: (val) => setState(() => _checkout = val ?? true),
                ),
                CheckboxListTile(
                  title: Text('Setup Node.js', style: GoogleFonts.inter()),
                  value: _setupNode,
                  onChanged: (val) => setState(() => _setupNode = val ?? false),
                ),
                CheckboxListTile(
                  title: Text('Update RSS Feed', style: GoogleFonts.inter()),
                  value: _updateFeed,
                  onChanged: (val) => setState(() => _updateFeed = val ?? false),
                ),
                if (_updateFeed)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextFormField(
                      initialValue: _feedUrl,
                      decoration: const InputDecoration(labelText: 'RSS Feed URL', border: OutlineInputBorder()),
                      style: GoogleFonts.inter(),
                      onChanged: (val) => setState(() => _feedUrl = val),
                    ),
                  ),
                CheckboxListTile(
                  title: Text('Commit Changes', style: GoogleFonts.inter()),
                  value: _commitChanges,
                  onChanged: (val) => setState(() => _commitChanges = val ?? true),
                ),
              ],
            ),
          ),
          // Preview
          Expanded(
            child: Container(
              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F8F8),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('preview.yml', style: GoogleFonts.firaCode(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: HighlightView(
                        _generateYaml(),
                        language: 'yaml',
                        theme: isDark ? draculaTheme : githubTheme,
                        padding: const EdgeInsets.all(12),
                        textStyle: GoogleFonts.firaCode(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
