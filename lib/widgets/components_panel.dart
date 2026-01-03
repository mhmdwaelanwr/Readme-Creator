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
    ];

    return DefaultTabController(
      length: 2,
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Components'),
                Tab(text: 'Snippets'),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search components...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                ),
                style: GoogleFonts.inter(),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(
                children: [
                  // Components Tab
                  ListView(
                    padding: const EdgeInsets.all(12.0),
                    children: [
                      _buildFilteredSection('Typography', typographyItems, isDark),
                      _buildFilteredSection('Media & Links', mediaItems, isDark),
                      _buildFilteredSection('Structure', structureItems, isDark),
                      _buildFilteredSection('Advanced', advancedItems, isDark),
                    ],
                  ),
                  // Snippets Tab
                  libraryProvider.snippets.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.dashboard_customize, size: 48, color: Theme.of(context).colorScheme.primary.withAlpha(100)),
                              const SizedBox(height: 16),
                              const Text('No snippets saved.\nRight-click an element to save.', textAlign: TextAlign.center),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12.0),
                          itemCount: libraryProvider.snippets.length,
                          itemBuilder: (context, index) {
                            final snippet = libraryProvider.snippets[index];
                            if (_searchQuery.isNotEmpty && !snippet.name.toLowerCase().contains(_searchQuery)) {
                              return const SizedBox.shrink();
                            }
                            return _buildDraggableSnippet(context, snippet, isDark);
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 16.0, left: 4.0),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
        ),
      ),
    );
  }

  Widget _buildDraggableItem(BuildContext context, ReadmeElementType type, String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: _getTooltipMessage(type),
      waitDuration: const Duration(milliseconds: 500),
      child: Draggable<ReadmeElementType>(
        data: type,
        rootOverlay: true,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: Material(
          elevation: 8.0,
          borderRadius: BorderRadius.circular(16),
          color: Colors.transparent,
          child: Container(
            width: 240,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.primary.withAlpha(100)),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(50), blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 16),
                Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
              ],
            ),
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant.withAlpha(80)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                // Optional: Add tap to add functionality if needed, but drag is primary
                Provider.of<ProjectProvider>(context, listen: false).addElement(type);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withAlpha(100),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: colorScheme.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                    ),
                    Icon(Icons.drag_indicator, size: 18, color: colorScheme.onSurfaceVariant.withAlpha(100)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableSnippet(BuildContext context, Snippet snippet, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;
    return Draggable<Snippet>(
      data: snippet,
      feedback: Material(
        elevation: 8.0,
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
        child: Container(
          width: 240,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(50), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.content_paste, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(snippet.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant.withAlpha(80)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
               Provider.of<ProjectProvider>(context, listen: false).addSnippet(snippet);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.content_paste, color: Colors.green, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      snippet.name,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: colorScheme.error,
                    onPressed: () {
                      Provider.of<LibraryProvider>(context, listen: false).deleteSnippet(snippet.id);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getTooltipMessage(ReadmeElementType type) {
    switch (type) {
      case ReadmeElementType.heading:
        return 'Heading: Generates # Heading code';
      case ReadmeElementType.paragraph:
        return 'Paragraph: Standard text block';
      case ReadmeElementType.image:
        return 'Image: Generates ![Alt](URL) code';
      case ReadmeElementType.linkButton:
        return 'Link Button: Generates [Text](URL) link';
      case ReadmeElementType.codeBlock:
        return 'Code Block: Generates ```code``` block';
      case ReadmeElementType.list:
        return 'List: Generates bullet or numbered lists';
      case ReadmeElementType.badge:
        return 'Badge: Generates shield/badge image link';
      case ReadmeElementType.table:
        return 'Table: Generates Markdown table structure';
      case ReadmeElementType.icon:
        return 'Icon: Adds tech stack icons';
      case ReadmeElementType.embed:
        return 'Embed: Adds links to Gists or Videos';
      case ReadmeElementType.githubStats:
        return 'GitHub Stats: Adds dynamic repo stats';
      case ReadmeElementType.contributors:
        return 'Contributors: Adds contributors list/grid';
      case ReadmeElementType.mermaid:
        return 'Mermaid: Adds Mermaid.js diagrams';
      case ReadmeElementType.toc:
        return 'TOC: Auto-generated Table of Contents';
      case ReadmeElementType.socials:
        return 'Social Links: Adds social media badges';
      case ReadmeElementType.blockquote:
        return 'Blockquote: Adds a quoted text block';
      case ReadmeElementType.divider:
        return 'Divider: Adds a horizontal rule';
      case ReadmeElementType.collapsible:
        return 'Collapsible: Adds a details/summary section';
    }
  }
}

class ComponentItem {
  final ReadmeElementType type;
  final String label;
  final IconData icon;
  ComponentItem(this.type, this.label, this.icon);
}
