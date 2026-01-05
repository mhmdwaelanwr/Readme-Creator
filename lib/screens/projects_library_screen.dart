import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/library_provider.dart';
import '../providers/project_provider.dart';
import '../utils/dialog_helper.dart';

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

    final filteredProjects = libraryProvider.projects.where((project) {
      final matchesName = project.name.toLowerCase().contains(_searchQuery);
      final matchesDesc = project.description.toLowerCase().contains(_searchQuery);
      final matchesTags = project.tags.any((tag) => tag.toLowerCase().contains(_searchQuery));
      return matchesName || matchesDesc || matchesTags;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('My Projects Library', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search projects',
                hintText: 'Name, description, or tags...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: filteredProjects.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 64, color: Theme.of(context).colorScheme.primary.withAlpha(100)),
                        const SizedBox(height: 16),
                        Text('No projects found', style: GoogleFonts.inter(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredProjects.length,
                    itemBuilder: (context, index) {
                      final project = filteredProjects[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withAlpha(80)),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            showSafeDialog(
                              context,
                              builder: (context) => AlertDialog(
                                title: Text('Load "${project.name}"?'),
                                content: const Text('This will replace your current workspace.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      projectProvider.importFromJson(project.jsonContent);
                                      Navigator.pop(context); // Close dialog
                                      Navigator.pop(context); // Close library screen
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Loaded ${project.name}')));
                                    },
                                    child: const Text('Load'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        project.name,
                                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert),
                                      onSelected: (value) {
                                        if (value == 'delete') {
                                          showSafeDialog(
                                            context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Delete Project?'),
                                              content: Text('Are you sure you want to delete "${project.name}"?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    libraryProvider.deleteProject(project.id);
                                                    Navigator.pop(context);
                                                  },
                                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, color: Colors.red, size: 20),
                                              SizedBox(width: 8),
                                              Text('Delete', style: TextStyle(color: Colors.red)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (project.description.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    project.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: project.tags.map((tag) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.secondaryContainer.withAlpha(100),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            tag,
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        )).toList(),
                                      ),
                                    ),
                                    Text(
                                      project.lastModified.toString().split('.')[0],
                                      style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
