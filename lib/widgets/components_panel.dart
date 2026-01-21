import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/readme_element.dart';
import '../providers/library_provider.dart';
import '../providers/project_provider.dart';
import '../models/snippet.dart';
import '../core/constants/app_colors.dart';
import '../utils/dialog_helper.dart';

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
        GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.4, // Slightly adjusted for better fit
          ),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            return _buildDraggableItem(context, item.type, item.label, item.icon);
          },
        ),
        if (_searchQuery.isEmpty) const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final libraryProvider = Provider.of<LibraryProvider>(context);
    final projectProvider = Provider.of<ProjectProvider>(context);

    final typographyItems = [
      ComponentItem(ReadmeElementType.heading, 'Heading', Icons.title_rounded),
      ComponentItem(ReadmeElementType.paragraph, 'Paragraph', Icons.text_fields_rounded),
      ComponentItem(ReadmeElementType.blockquote, 'Quote', Icons.format_quote_rounded),
      ComponentItem(ReadmeElementType.codeBlock, 'Code', Icons.code_rounded),
    ];

    final mediaItems = [
      ComponentItem(ReadmeElementType.image, 'Image', Icons.image_rounded),
      ComponentItem(ReadmeElementType.icon, 'Icon', Icons.emoji_emotions_rounded),
      ComponentItem(ReadmeElementType.linkButton, 'Button', Icons.link_rounded),
      ComponentItem(ReadmeElementType.badge, 'Badge', Icons.shield_rounded),
      ComponentItem(ReadmeElementType.socials, 'Socials', Icons.share_rounded),
      ComponentItem(ReadmeElementType.githubStats, 'Stats', Icons.bar_chart_rounded),
      ComponentItem(ReadmeElementType.contributors, 'People', Icons.people_rounded),
      ComponentItem(ReadmeElementType.dynamicWidget, 'Widget', Icons.extension_rounded),
    ];

    final structureItems = [
      ComponentItem(ReadmeElementType.list, 'List', Icons.list_rounded),
      ComponentItem(ReadmeElementType.table, 'Table', Icons.table_chart_rounded),
      ComponentItem(ReadmeElementType.divider, 'Divider', Icons.horizontal_rule_rounded),
      ComponentItem(ReadmeElementType.collapsible, 'Foldout', Icons.unfold_more_rounded),
    ];

    return DefaultTabController(
      length: 2,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          border: Border(right: BorderSide(color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5))),
        ),
        child: Column(
          children: [
            const SizedBox(height: 4),
            TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: 'Elements'),
                Tab(text: 'Snippets'),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  filled: true,
                  fillColor: isDark ? Colors.white.withAlpha(5) : Colors.black.withAlpha(3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                style: GoogleFonts.inter(fontSize: 13),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Elements Tab
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        _buildFilteredSection('Typography', typographyItems, isDark),
                        _buildFilteredSection('Media & Graphics', mediaItems, isDark),
                        _buildFilteredSection('Structure', structureItems, isDark),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  // Snippets Tab
                  Column(
                    children: [
                      if (projectProvider.selectedElement != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _showSaveSnippetDialog(context, projectProvider.selectedElement!),
                              icon: const Icon(Icons.add_box_rounded, size: 18),
                              label: const Text('Save Selected', style: TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary.withAlpha(20),
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: _buildSnippetsTab(libraryProvider, isDark),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableItem(BuildContext context, ReadmeElementType type, String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Draggable<ReadmeElementType>(
      data: type,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 100,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              Text(label, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
            ],
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Provider.of<ProjectProvider>(context, listen: false).addElement(type),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withAlpha(5) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.withAlpha(20)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Fix for vertical overflow
              children: [
                Flexible(
                  child: Icon(icon, size: 18, color: AppColors.primary),
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 6.0, left: 2),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: Colors.grey.withAlpha(150),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSnippetsTab(LibraryProvider libraryProvider, bool isDark) {
    if (libraryProvider.snippets.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border_rounded, size: 40, color: Colors.grey.withAlpha(80)),
            const SizedBox(height: 12),
            Text('No snippets', style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: libraryProvider.snippets.length,
      itemBuilder: (context, index) {
        final snippet = libraryProvider.snippets[index];
        if (_searchQuery.isNotEmpty && !snippet.name.toLowerCase().contains(_searchQuery)) {
          return const SizedBox.shrink();
        }
        return _buildDraggableSnippet(context, libraryProvider, snippet, isDark);
      },
    );
  }

  Widget _buildDraggableSnippet(BuildContext context, LibraryProvider libraryProvider, Snippet snippet, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Draggable<Snippet>(
        data: snippet,
        feedback: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
            child: Text(snippet.name, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ),
        child: Card(
          margin: EdgeInsets.zero,
          color: isDark ? Colors.white.withAlpha(5) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: AppColors.primary.withAlpha(30)),
          ),
          child: ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: const Icon(Icons.bookmark_rounded, color: AppColors.primary, size: 16),
            title: Text(snippet.name, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
            trailing: IconButton(
              icon: const Icon(Icons.close_rounded, size: 14),
              onPressed: () => libraryProvider.deleteSnippet(snippet.id),
            ),
            onTap: () => Provider.of<ProjectProvider>(context, listen: false).addSnippet(snippet),
          ),
        ),
      ),
    );
  }

  void _showSaveSnippetDialog(BuildContext context, ReadmeElement element) {
    final nameController = TextEditingController(text: element.description);
    showSafeDialog(
      context,
      builder: (context) => AlertDialog(
        title: Text('Save Snippet', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Provider.of<LibraryProvider>(context, listen: false).saveSnippet(name: nameController.text, elementJson: jsonEncode(element.toJson()));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Snippet saved!')));
              }
            },
            child: const Text('Save'),
          ),
        ],
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
