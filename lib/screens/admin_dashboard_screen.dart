import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/project_provider.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/readme_element.dart';
import '../core/constants/app_colors.dart';
import '../utils/dialog_helper.dart';
import '../utils/toast_helper.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  late TabController _tabController;
  final TextEditingController _adminEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Owner gets 3 tabs, regular Admin gets 2
    _tabController = TabController(length: _authService.isAdmin ? 3 : 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _adminEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<ProjectProvider>(context);
    final bool isOwner = _authService.currentUser?.email == AuthService.adminEmail;

    return Scaffold(
      backgroundColor: isDark ? AppColors.editorBackgroundDark : AppColors.editorBackgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings_rounded, color: Colors.purpleAccent),
            const SizedBox(width: 12),
            Text('Admin Dashboard', style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 20)),
          ],
        ),
        actions: [
          _buildUserBadge(isDark),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Sidebar Stats
          _buildSidebar(provider, isDark),
          
          const VerticalDivider(width: 1, thickness: 1),
          
          // Main Dynamic Content
          Expanded(
            child: Column(
              children: [
                _buildModernTabBar(isDark, isOwner),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTemplatesManager(context, provider, isDark),
                      _buildSnippetsManager(context, isDark),
                      if (isOwner) _buildAccessControlTab(context, isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTemplateDialog(context, provider),
        label: const Text('New Cloud Template', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add_to_photos_rounded),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSidebar(ProjectProvider provider, bool isDark) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(5) : Colors.black.withAlpha(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCard('CLOUD TEMPLATES', provider.cloudTemplates.length.toString(), Icons.auto_awesome_mosaic_rounded, Colors.blue),
          const SizedBox(height: 16),
          _buildStatCard('PUBLIC SNIPPETS', '12', Icons.bookmark_rounded, Colors.purple),
          const SizedBox(height: 16),
          _buildStatCard('TOTAL USERS', '---', Icons.people_alt_rounded, Colors.green),
          const Spacer(),
          _buildInfoBox('Any template you publish here will be instantly available to all users globally.', isDark),
        ],
      ),
    );
  }

  Widget _buildModernTabBar(bool isDark, bool isOwner) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.withAlpha(30))),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: [
            const Tab(text: 'Cloud Templates'),
            const Tab(text: 'Public Snippets'),
            if (isOwner) const Tab(text: 'Access Control'),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessControlTab(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Privileged Access', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('As the Owner, you can grant Admin access to other developers.', style: GoogleFonts.inter(color: Colors.grey)),
          const SizedBox(height: 32),
          
          // Add Admin Form
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _adminEmailController,
                  decoration: InputDecoration(
                    hintText: 'Enter developer email...',
                    prefixIcon: const Icon(Icons.alternate_email_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _addAdmin,
                icon: const Icon(Icons.person_add_rounded),
                label: const Text('Grant Access'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20)),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          Text('Current Administrators', style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.grey, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('admins').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final admins = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: admins.length,
                  itemBuilder: (context, index) {
                    final admin = admins[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.security_rounded)),
                        title: Text(admin['email']),
                        subtitle: Text('Granted on: ${admin['grantedAt']?.toDate().toString().split(' ')[0] ?? '---'}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.red),
                          onPressed: () => _removeAdmin(admin.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesManager(BuildContext context, ProjectProvider provider, bool isDark) {
    if (provider.cloudTemplates.isEmpty) return _buildEmptyContent('No cloud templates found.');

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: provider.cloudTemplates.length,
      itemBuilder: (context, index) {
        final template = provider.cloudTemplates[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withAlpha(5) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withAlpha(30)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.blue.withAlpha(20), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.article_rounded, color: Colors.blue),
            ),
            title: Text(template.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            subtitle: Text(template.description, maxLines: 1),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _actionBtn(Icons.edit_rounded, Colors.blue, () {}),
                _actionBtn(Icons.delete_outline_rounded, Colors.redAccent, () => _deleteTemplate(template.name)), // Simple ID logic for now
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSnippetsManager(BuildContext context, bool isDark) {
    return _buildEmptyContent('Coming Soon: Global Snippet Library');
  }

  Widget _buildEmptyContent(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.layers_clear_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.inter(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 16),
          Text(value, style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w800)),
          Text(title, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
        ],
      ),
    );
  }

  Widget _buildUserBadge(bool isDark) {
    final user = _authService.currentUser;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 12, backgroundImage: NetworkImage(user?.photoURL ?? '')),
          const SizedBox(width: 8),
          Text('OWNER', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.purpleAccent)),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blue.withAlpha(10), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blue.withAlpha(20))),
      child: Text(text, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600], height: 1.5)),
    );
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) {
    return IconButton(icon: Icon(icon, size: 20, color: color), onPressed: onTap);
  }

  void _addAdmin() async {
    final email = _adminEmailController.text.trim();
    if (email.isEmpty) return;
    await FirebaseFirestore.instance.collection('admins').add({
      'email': email,
      'grantedAt': FieldValue.serverTimestamp(),
    });
    _adminEmailController.clear();
    if (mounted) ToastHelper.show(context, 'Admin access granted to $email');
  }

  void _removeAdmin(String id) async {
    await FirebaseFirestore.instance.collection('admins').doc(id).delete();
    if (mounted) ToastHelper.show(context, 'Admin access revoked');
  }

  void _deleteTemplate(String name) {
    // Logic to search and delete by name or ID in Firestore
  }

  void _showAddTemplateDialog(BuildContext context, ProjectProvider provider) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showSafeDialog(
      context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Sync to Cloud', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Publish your current project as an official public template.'),
            const SizedBox(height: 24),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Template Name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Short Description', border: OutlineInputBorder()), maxLines: 2),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final elementsJson = provider.elements.map((e) => e.toJson()).toList();
                await _firestoreService.savePublicTemplate(name: nameController.text, description: descController.text, elements: elementsJson);
                if (context.mounted) { Navigator.pop(context); ToastHelper.show(context, 'Live Globally!'); }
              }
            },
            child: const Text('Publish Now'),
          ),
        ],
      ),
    );
  }
}
