import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/library_provider.dart';
import '../providers/project_provider.dart';
import '../utils/dialog_helper.dart';
import '../core/constants/app_colors.dart';
import '../utils/toast_helper.dart'; // Fixed missing import

class ProjectsLibraryScreen extends StatefulWidget {
  const ProjectsLibraryScreen({super.key});

  @override
  State<ProjectsLibraryScreen> createState() => _ProjectsLibraryScreenState();
}

class _ProjectsLibraryScreenState extends State<ProjectsLibraryScreen> {
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

  @override
  Widget build(BuildContext context) {
    final libraryProvider = Provider.of<LibraryProvider>(context);
    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredProjects = libraryProvider.projects.where((project) {
      final matchesName = project.name.toLowerCase().contains(_searchQuery);
      final matchesDesc = project.description.toLowerCase().contains(_searchQuery);
      final matchesTags = project.tags.any((tag) => tag.toLowerCase().contains(_searchQuery));
      return matchesName || matchesDesc || matchesTags;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.editorBackgroundDark : AppColors.editorBackgroundLight,
      appBar: AppBar(
        title: Text('My Project Library', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchHeader(isDark),
          Expanded(
            child: filteredProjects.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(24),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: filteredProjects.length,
                    itemBuilder: (context, index) {
                      final project = filteredProjects[index];
                      return _buildProjectCard(context, project, libraryProvider, projectProvider, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search your projects...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          filled: true,
          fillColor: isDark ? Colors.white.withAlpha(5) : Colors.black.withAlpha(3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        style: GoogleFonts.inter(),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, project, libraryProvider, projectProvider, bool isDark) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: isDark ? AppColors.socialPreviewDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.withAlpha(30)),
      ),
      child: InkWell(
        onTap: () => _showLoadConfirmation(context, project, projectProvider),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.folder_copy_rounded, color: AppColors.primary, size: 20),
                  ),
                  _buildCardMenu(context, project, libraryProvider),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                project.name,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  project.description.isEmpty ? 'No description provided.' : project.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(color: Colors.grey, fontSize: 13, height: 1.4),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      children: project.tags.take(3).map<Widget>((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(tag, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      )).toList(),
                    ),
                  ),
                  Text(
                    _formatDate(project.lastModified),
                    style: GoogleFonts.inter(fontSize: 10, color: Colors.grey.withAlpha(150)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardMenu(BuildContext context, project, libraryProvider) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz_rounded, color: Colors.grey),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'delete') _showDeleteConfirmation(context, project, libraryProvider);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
              SizedBox(width: 12),
              Text('Delete Project', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_mosaic_rounded, size: 80, color: Colors.grey.withAlpha(100)),
          const SizedBox(height: 24),
          Text('No Projects Found', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey)),
          Text('Your library is currently empty.', style: GoogleFonts.inter(color: Colors.grey)),
        ],
      ),
    );
  }

  void _showLoadConfirmation(BuildContext context, project, projectProvider) {
    showSafeDialog(
      context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Load Project', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to load "${project.name}"? Current workspace will be replaced.', style: GoogleFonts.inter()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              projectProvider.importFromJson(project.jsonContent);
              Navigator.pop(context);
              Navigator.pop(this.context);
              ToastHelper.show(this.context, 'Project Loaded Successfully!');
            },
            child: const Text('Load Now'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, project, libraryProvider) {
    showSafeDialog(
      context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Permanentely?'),
        content: Text('This will erase "${project.name}" from your local storage.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              libraryProvider.deleteProject(project.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
