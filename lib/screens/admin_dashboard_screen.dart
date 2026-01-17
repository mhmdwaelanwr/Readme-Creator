import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../services/firestore_service.dart';
import '../models/readme_element.dart';
import '../models/snippet.dart';
import '../core/constants/app_colors.dart';
import '../utils/dialog_helper.dart';
import '../utils/toast_helper.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<ProjectProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Control Center', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(() {}),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar Info
          Container(
            width: 280,
            color: isDark ? Colors.white.withAlpha(5) : Colors.black.withAlpha(3),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatCard('Active Templates', provider.cloudTemplates.length.toString(), Icons.layers_rounded, Colors.blue),
                const SizedBox(height: 16),
                _buildStatCard('Public Snippets', '0', Icons.bookmark_rounded, Colors.purple), // Placeholder
                const Spacer(),
                _buildAdminInfo(isDark),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // Main Content
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: const [
                      Tab(text: 'Cloud Templates'),
                      Tab(text: 'Public Snippets'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildTemplatesManager(context, provider, isDark),
                        _buildSnippetsManager(context, isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTemplateDialog(context, provider),
        label: const Text('New Cloud Template'),
        icon: const Icon(Icons.cloud_upload_rounded),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text(value, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminInfo(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(5) : Colors.black.withAlpha(5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          CircleAvatar(radius: 16, child: Icon(Icons.admin_panel_settings_rounded, size: 18)),
          SizedBox(width: 12),
          Text('Developer Access', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTemplatesManager(BuildContext context, ProjectProvider provider, bool isDark) {
    if (provider.cloudTemplates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('No cloud templates found.', style: GoogleFonts.inter(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: provider.cloudTemplates.length,
      itemBuilder: (context, index) {
        final template = provider.cloudTemplates[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.withAlpha(30))),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.description_rounded, color: Colors.white)),
            title: Text(template.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(template.description, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit_rounded, color: Colors.blue), onPressed: () {}),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  onPressed: () {
                    // Logic to delete template from Firestore
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSnippetsManager(BuildContext context, bool isDark) {
    return const Center(child: Text('Snippet Management Coming Soon'));
  }

  void _showAddTemplateDialog(BuildContext context, ProjectProvider provider) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showSafeDialog(
      context,
      builder: (context) => AlertDialog(
        title: const Text('Convert Current Project to Template'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This will make your current canvas elements available as a public template for everyone.'),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Template Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Short Description', border: OutlineInputBorder()),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final elementsJson = provider.elements.map((e) => e.toJson()).toList();
                await _firestoreService.savePublicTemplate(
                  name: nameController.text,
                  description: descController.text,
                  elements: elementsJson,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ToastHelper.show(context, 'Template Published Globally!');
                }
              }
            },
            child: const Text('Publish Cloud Template'),
          ),
        ],
      ),
    );
  }
}
