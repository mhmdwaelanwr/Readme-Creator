import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/project_provider.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../services/subscription_service.dart';
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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _adminEmailController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isOwner = _authService.currentUser?.email == AuthService.adminEmail;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings_rounded, color: Colors.purpleAccent),
            const SizedBox(width: 12),
            Text('SaaS Control Center', style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 20)),
          ],
        ),
        actions: [
          _buildUserBadge(isDark),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          _buildSidebar(isDark),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: Column(
              children: [
                _buildModernTabBar(isDark, isOwner),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildUsersTab(isDark),
                      _buildFeedbackTab(isDark),
                      _buildTemplatesManager(isDark),
                      _buildAccessControlTab(isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(bool isDark) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              final count = snapshot.data?.docs.length ?? 0;
              final proCount = snapshot.data?.docs.where((d) => d['isPro'] == true).length ?? 0;
              return Column(
                children: [
                  _buildStatCard('TOTAL USERS', count.toString(), Icons.people_rounded, Colors.blue),
                  const SizedBox(height: 16),
                  _buildStatCard('PRO MEMBERS', proCount.toString(), Icons.star_rounded, Colors.amber),
                ],
              );
            },
          ),
          const Spacer(),
          _buildInfoBox('PRO Tip: Check "Feedback" tab daily for Sponsorship Proofs.', isDark),
        ],
      ),
    );
  }

  Widget _buildModernTabBar(bool isDark, bool isOwner) {
    return TabBar(
      controller: _tabController,
      labelColor: AppColors.primary,
      unselectedLabelColor: Colors.grey,
      indicatorColor: AppColors.primary,
      labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
      tabs: const [
        Tab(icon: Icon(Icons.group_rounded), text: 'Users'),
        Tab(icon: Icon(Icons.message_rounded), text: 'Feedback'),
        Tab(icon: Icon(Icons.cloud_done_rounded), text: 'Templates'),
        Tab(icon: Icon(Icons.security_rounded), text: 'Admins'),
      ],
    );
  }

  Widget _buildUsersTab(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search by email...',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              var users = snapshot.data!.docs;
              if (_searchController.text.isNotEmpty) {
                users = users.where((u) => u['email'].toString().contains(_searchController.text)).toList();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final bool isPro = user['isPro'] ?? false;
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      title: Text(user['email'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Joined: ${user['joinDate']?.toDate().toString().split(' ')[0] ?? '---'}'),
                      trailing: Switch(
                        value: isPro,
                        activeColor: Colors.amber,
                        onChanged: (val) => _togglePro(user.id, val),
                      ),
                      leading: Icon(isPro ? Icons.stars_rounded : Icons.person_outline_rounded, color: isPro ? Colors.amber : Colors.grey),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackTab(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('feedback').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final messages = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            final String? url = msg['attachmentUrl'];
            final String type = msg['type'] ?? 'general';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ExpansionTile(
                leading: _getTypeIcon(type),
                title: Text(msg['userEmail']),
                subtitle: Text(msg['message'], maxLines: 1, overflow: TextOverflow.ellipsis),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Message:', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(msg['message']),
                        const SizedBox(height: 16),
                        if (url != null)
                          ElevatedButton.icon(
                            onPressed: () => _launchUrl(url),
                            icon: const Icon(Icons.attach_file_rounded),
                            label: const Text('View Attachment (Proof)'),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(onPressed: () => _deleteFeedback(msg.id), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTemplatesManager(bool isDark) {
    return const Center(child: Text('Template Manager Content Here'));
  }

  Widget _buildAccessControlTab(bool isDark) {
    return const Center(child: Text('Admin Management Content Here'));
  }

  Widget _getTypeIcon(String type) {
    switch (type) {
      case 'bug': return const Icon(Icons.bug_report_rounded, color: Colors.red);
      case 'feature': return const Icon(Icons.add_chart_rounded, color: Colors.blue);
      default: return const Icon(Icons.message_rounded, color: Colors.green);
    }
  }

  void _togglePro(String uid, bool status) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'isPro': status});
    if (mounted) ToastHelper.show(context, 'User Pro status updated');
  }

  void _deleteFeedback(String id) async {
    await FirebaseFirestore.instance.collection('feedback').doc(id).delete();
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color.withAlpha(15), borderRadius: BorderRadius.circular(24), border: Border.all(color: color.withAlpha(30))),
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
    return const CircleAvatar(backgroundColor: Colors.purpleAccent, child: Icon(Icons.person, color: Colors.white));
  }

  Widget _buildInfoBox(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blue.withAlpha(10), borderRadius: BorderRadius.circular(16)),
      child: Text(text, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600])),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}
