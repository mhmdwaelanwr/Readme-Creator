import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/readme_element.dart';
import '../providers/library_provider.dart';
import '../providers/project_provider.dart';
import '../models/snippet.dart';

class ComponentsPanel extends StatefulWidget {
  const ComponentsPanel({super.key});

  @override
  State<ComponentsPanel> createState() => _ComponentsPanelState();
}

class _ComponentsPanelState extends State<ComponentsPanel> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildFilteredSection(String title, List<ComponentItem> items, bool isDark) {
    final filteredItems = items.where((item) => item.label.toLowerCase().contains(_searchQuery)).toList();

    if (filteredItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_searchQuery.isEmpty) _buildSectionHeader(title, isDark),
        ...filteredItems.map((item) => _buildDraggableItem(context, item.type, item.label, item.icon)),
        if (_searchQuery.isEmpty) const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final libraryProvider = Provider.of<LibraryProvider>(context);

    // ... (item definitions are outside valid replacement scope if I don't include them, but I will include them to be safe or target after them)
    // Actually, I'll target the return statement mostly.

    final typographyItems = [
      ComponentItem(ReadmeElementType.heading, 'Heading', Icons.title),
      ComponentItem(ReadmeElementType.paragraph, 'Paragraph', Icons.text_fields),
      ComponentItem(ReadmeElementType.blockquote, 'Blockquote', Icons.format_quote),
      ComponentItem(ReadmeElementType.codeBlock, 'Code Block', Icons.code),
    ];

    final mediaItems = [
      ComponentItem(ReadmeElementType.image, 'Image', Icons.image),
      ComponentItem(ReadmeElementType.icon, 'Icon/Logo', Icons.emoji_emotions),
      ComponentItem(ReadmeElementType.linkButton, 'Link Button', Icons.link),
      ComponentItem(ReadmeElementType.badge, 'Badge', Icons.shield),
      ComponentItem(ReadmeElementType.socials, 'Social Links', Icons.share),
      ComponentItem(ReadmeElementType.embed, 'Embed', Icons.code_off),
      ComponentItem(ReadmeElementType.githubStats, 'GitHub Stats', Icons.bar_chart),
      ComponentItem(ReadmeElementType.contributors, 'Contributors', Icons.people),
      ComponentItem(ReadmeElementType.dynamicWidget, 'Dynamic Widget', Icons.extension),
    ];

    final structureItems = [
      ComponentItem(ReadmeElementType.list, 'List', Icons.list),
      ComponentItem(ReadmeElementType.table, 'Table', Icons.table_chart),
      ComponentItem(ReadmeElementType.divider, 'Divider', Icons.horizontal_rule),
      ComponentItem(ReadmeElementType.collapsible, 'Collapsible', Icons.expand_more),
    ];

    final advancedItems = [
      ComponentItem(ReadmeElementType.mermaid, 'Mermaid Diagram', Icons.account_tree),
      ComponentItem(ReadmeElementType.toc, 'Table of Contents', Icons.list_alt),
      ComponentItem(ReadmeElementType.raw, 'Raw Markdown / HTML', Icons.code),
    ];

    final builtInSnippets = [
      Snippet(
        id: 'template_skills',
        name: 'Skills Table',
        elementJson: '{"type":"table","headers":["Language","Proficiency"],"rows":[["Dart","Expert"],["Flutter","Expert"]],"alignments":[0,0],"id":"temp_skills"}',
      ),
      Snippet(
        id: 'template_contact',
        name: 'Contact Info',
        elementJson: '{"type":"socials","profiles":[{"platform":"github","username":"username"},{"platform":"linkedin","username":"username"}],"style":"for-the-badge","id":"temp_contact"}',
      ),
      Snippet(
        id: 'template_faq',
        name: 'FAQ Section',
        elementJson: '{"type":"collapsible","summary":"Frequently Asked Questions","content":"Q: How do I install?\\n\\nA: Run `npm install`.","id":"temp_faq"}',
      ),
      Snippet(
        id: 'template_spotify',
        name: 'Spotify Status',
        elementJson: '{"type":"dynamicWidget","widgetType":"spotify","identifier":"user_id","theme":"default","id":"temp_spotify"}',
      ),
      Snippet(
        id: 'template_youtube',
        name: 'YouTube Video',
        elementJson: '{"type":"dynamicWidget","widgetType":"youtube","identifier":"VIDEO_ID","theme":"default","id":"temp_youtube"}',
      ),
      Snippet(
        id: 'template_github_stats',
        name: 'GitHub Stats',
        elementJson: '{"type":"githubStats","repoName":"username/repo","showStars":true,"showForks":true,"showIssues":true,"showLicense":true,"id":"temp_gh_stats"}',
      ),
      Snippet(
        id: 'template_contributors',
        name: 'Contributors',
        elementJson: '{"type":"contributors","repoName":"username/repo","style":"grid","id":"temp_contributors"}',
      ),
    ];

    return DefaultTabController(
      length: 2,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
              border: Border(right: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: TabBar(
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Theme.of(context).primaryColor,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'Components'),
                      Tab(text: 'Snippets'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                    ),
                    style: GoogleFonts.inter(),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Components Tab
                      ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _buildFilteredSection('Typography', typographyItems, isDark),
                          _buildFilteredSection('Media & Links', mediaItems, isDark),
                          _buildFilteredSection('Structure', structureItems, isDark),
                          _buildFilteredSection('Advanced', advancedItems, isDark),
                          const SizedBox(height: 20),
                        ],
                      ),
                      // Snippets Tab
                      ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          if (builtInSnippets.isNotEmpty) ...[
                            _buildSectionHeader('Templates', isDark),
                            ...builtInSnippets.map((s) => _buildDraggableSnippet(context, s, isDark, isTemplate: true)),
                            const SizedBox(height: 16),
                          ],
                          _buildSectionHeader('My Snippets', isDark),
                          libraryProvider.snippets.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 32.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.dashboard_customize, size: 48, color: Theme.of(context).colorScheme.primary.withAlpha(100)),
                                        const SizedBox(height: 16),
                                        const Text('No snippets saved.\\nRight-click an element to save.', textAlign: TextAlign.center),
                                      ],
                                    ),
                                  ),
                                )
                              : Column(
                                  children: libraryProvider.snippets.map((snippet) {
                                    if (_searchQuery.isNotEmpty && !snippet.name.toLowerCase().contains(_searchQuery)) {
                                      return const SizedBox.shrink();
                                    }
                                    return _buildDraggableSnippet(context, snippet, isDark);
                                  }).toList(),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableItem(BuildContext context, ReadmeElementType type, String label, IconData icon) {
    // We can use Draggable for drag and drop to canvas if supported,
    // OR just InkWell to add on click.
    // Assuming EditorCanvas handles Droppable or we just add on click.
    // The previous implementation likely only had InkWell.
    // Let's make it Draggable AND InkWell.
    return Draggable<ReadmeElementType>(
      data: type,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              const SizedBox(width: 8),
              Text(label, style: GoogleFonts.inter()),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildItemTile(context, type, label, icon),
      ),
      child: _buildItemTile(context, type, label, icon),
    );
  }

  Widget _buildItemTile(BuildContext context, ReadmeElementType type, String label, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).dividerColor.withAlpha(50)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Provider.of<ProjectProvider>(context, listen: false).addElement(type);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 14), overflow: TextOverflow.ellipsis)),
              const Icon(Icons.add, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.grey[400] : Colors.grey[700],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDraggableSnippet(BuildContext context, Snippet snippet, bool isDark, {bool isTemplate = false}) {
    return Draggable<Snippet>(
      data: snippet,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isTemplate ? Icons.copy : Icons.bookmark, size: 16),
              const SizedBox(width: 8),
              Text(snippet.name, style: GoogleFonts.inter()),
            ],
          ),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: isTemplate ? null : (isDark ? Colors.blue.withAlpha(20) : Colors.blue.withAlpha(10)),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: isTemplate ? BorderSide(color: Theme.of(context).dividerColor.withAlpha(50)) : BorderSide.none,
        ),
        child: ListTile(
          dense: true,
          leading: Icon(isTemplate ? Icons.copy : Icons.bookmark, size: 18, color: isTemplate ? Colors.grey : Colors.blue),
          title: Text(snippet.name, style: GoogleFonts.inter(fontSize: 13, fontWeight: isTemplate ? FontWeight.normal : FontWeight.w500)),
          trailing: isTemplate
              ? const Icon(Icons.add, size: 16)
              : IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () {
                    Provider.of<LibraryProvider>(context, listen: false).deleteSnippet(snippet.id);
                  },
                ),
          onTap: () {
            // Parse JSON and add element
            try {
              // We use addSnippet which handles parsing and adding safely
              final provider = Provider.of<ProjectProvider>(context, listen: false);
              provider.addSnippet(snippet);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding snippet: $e')));
            }
          },
        ),
      ),
    );
  }
}

class ComponentItem {
  final ReadmeElementType type;
  final String label;
  final IconData icon;
  ComponentItem(this.type, this.label, this.icon);
}
