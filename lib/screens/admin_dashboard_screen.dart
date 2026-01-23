import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../core/constants/app_colors.dart';
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
  final TextEditingController _searchController = TextEditingController();
  
  // Notification Advanced Controllers
  final _notifTitleController = TextEditingController();
  final _notifBodyController = TextEditingController();
  final _notifImageUrlController = TextEditingController();
  final _notifActionController = TextEditingController();
  String _selectedPriority = 'high';
  String _selectedTarget = 'all_users';
  bool _isSendingNotif = false;

  // System Config Controllers
  final _announcementController = TextEditingController();
  final _minVersionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _notifTitleController.dispose();
    _notifBodyController.dispose();
    _notifImageUrlController.dispose();
    _notifActionController.dispose();
    _announcementController.dispose();
    _minVersionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F111A) : const Color(0xFFF8F9FD),
      body: Row(
        children: [
          _buildModernSidebar(isDark),
          Expanded(
            child: Column(
              children: [
                _buildCustomAppBar(isDark),
                _buildModernTabBar(isDark),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildStatsOverview(isDark),
                      _buildUsersTab(isDark),
                      _buildFeedbackTab(isDark),
                      _buildNotificationsTab(isDark),
                      _buildTemplatesManager(isDark),
                      _buildSystemConfigTab(isDark),
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

  Widget _buildCustomAppBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Admin Dashboard', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
              Text('Markdown Creator Pro Systems', style: GoogleFonts.inter(color: Colors.grey, fontSize: 13)),
            ],
          ),
          const Spacer(),
          _buildUserBadge(isDark),
        ],
      ),
    );
  }

  Widget _buildModernSidebar(bool isDark) {
    return Container(
      width: 260,
      color: isDark ? const Color(0xFF161922) : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, color: Colors.amber, size: 32),
              const SizedBox(width: 12),
              Text('CONSOLE', style: GoogleFonts.orbitron(fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 2)),
            ],
          ),
          const SizedBox(height: 48),
          _buildSidebarItem(Icons.analytics_outlined, 'Insights', 0),
          _buildSidebarItem(Icons.people_alt_outlined, 'User Base', 1),
          _buildSidebarItem(Icons.forum_outlined, 'Inquiries', 2),
          _buildSidebarItem(Icons.campaign_outlined, 'Broadcasts', 3),
          _buildSidebarItem(Icons.auto_awesome_motion_outlined, 'Assets', 4),
          _buildSidebarItem(Icons.settings_suggest_outlined, 'System', 5),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(20),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.security_rounded, color: Colors.blue, size: 20),
                const SizedBox(height: 8),
                Text('Admin Security', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                Text('Your session is encrypted and logged.', style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, int index) {
    bool isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () => setState(() => _tabController.animateTo(index)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(20) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : Colors.grey, size: 20),
            const SizedBox(width: 16),
            Text(title, style: GoogleFonts.inter(
              color: isSelected ? AppColors.primary : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          final users = snapshot.data?.docs ?? [];
          final proCount = users.where((d) => d['isPro'] == true).length;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: _buildStatCard('TOTAL USERS', users.length.toString(), Icons.people_rounded, Colors.blue)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('PRO MEMBERS', proCount.toString(), Icons.stars_rounded, Colors.amber)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('CONVERSION', '${((proCount/(users.isEmpty?1:users.length))*100).toStringAsFixed(1)}%', Icons.trending_up_rounded, Colors.green)),
                ],
              ),
              const SizedBox(height: 32),
              Text('Platform Health', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildHealthMonitor(isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSystemConfigTab(bool isDark) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestoreService.getAppConfig(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final config = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Global Application Control', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Modify app behavior in real-time for all users.', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              
              _buildConfigSection(
                title: 'Service Status',
                icon: Icons.power_settings_new_rounded,
                children: [
                  _buildToggleTile(
                    'Maintenance Mode', 
                    'Stops all user interactions and shows maintenance screen.',
                    config['maintenanceMode'] ?? false,
                    (v) => _updateConfig('maintenanceMode', v),
                  ),
                  const Divider(),
                  _buildToggleTile(
                    'Allow AI Generation', 
                    'Enable/Disable Gemini AI features globally.',
                    config['aiEnabled'] ?? true,
                    (v) => _updateConfig('aiEnabled', v),
                  ),
                  const Divider(),
                  _buildToggleTile(
                    'Enable Public Templates', 
                    'Control visibility of public gallery.',
                    config['templatesVisible'] ?? true,
                    (v) => _updateConfig('templatesVisible', v),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              _buildConfigSection(
                title: 'Broadcast Announcement',
                icon: Icons.campaign_rounded,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _announcementController..text = config['announcementText'] ?? '',
                          decoration: InputDecoration(
                            hintText: 'Display a banner message to all users...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text('Show Banner: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            Switch(
                              value: config['showAnnouncement'] ?? false, 
                              onChanged: (v) => _updateConfig('showAnnouncement', v),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () => _updateConfig('announcementText', _announcementController.text),
                              child: const Text('Update Banner'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              _buildConfigSection(
                title: 'Version Management',
                icon: Icons.system_update_rounded,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minVersionController..text = config['minRequiredVersion'] ?? '1.0.0',
                            decoration: const InputDecoration(labelText: 'Min Required Version'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () => _updateConfig('minRequiredVersion', _minVersionController.text),
                          child: const Text('Set & Force Update'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConfigSection({required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildToggleTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Future<void> _updateConfig(String key, dynamic value) async {
    await _firestoreService.updateAppConfig({key: value});
    if (mounted) ToastHelper.show(context, 'System setting updated!');
  }

  Widget _buildNotificationsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Advanced Notification Composer', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    _buildNotifField('Title', 'Enter notification heading...', _notifTitleController),
                    const SizedBox(height: 16),
                    _buildNotifField('Body', 'Enter message content...', _notifBodyController, maxLines: 3),
                    const SizedBox(height: 16),
                    _buildNotifField('Image URL (Optional)', 'https://...', _notifImageUrlController),
                    const SizedBox(height: 16),
                    _buildNotifField('Deep Link / Action (Optional)', 'e.g., /templates', _notifActionController),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withAlpha(5) : Colors.black.withAlpha(5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.withAlpha(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Targeting & Delivery', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      _buildDropdown('Priority', ['high', 'normal'], _selectedPriority, (v) => setState(() => _selectedPriority = v!)),
                      const SizedBox(height: 16),
                      _buildDropdown('Audience', ['all_users', 'pro_only', 'free_only'], _selectedTarget, (v) => setState(() => _selectedTarget = v!)),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: _isSendingNotif ? null : _sendAdvancedNotif,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: _isSendingNotif ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.send_rounded, color: Colors.white),
                          label: Text('SEND CAMPAIGN', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Text('Broadcast History', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildNotifHistory(),
        ],
      ),
    );
  }

  Widget _buildNotifField(String label, String hint, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.withAlpha(10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> options, String current, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: current,
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o.toUpperCase(), style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.withAlpha(10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Future<void> _sendAdvancedNotif() async {
    if (_notifTitleController.text.isEmpty || _notifBodyController.text.isEmpty) {
      ToastHelper.show(context, 'Title and Body are required');
      return;
    }

    setState(() => _isSendingNotif = true);
    try {
      await FirebaseFirestore.instance.collection('admin_notifications').add({
        'title': _notifTitleController.text,
        'body': _notifBodyController.text,
        'imageUrl': _notifImageUrlController.text,
        'action': _notifActionController.text,
        'priority': _selectedPriority,
        'target': _selectedTarget,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      ToastHelper.show(context, 'Notification campaign queued!');
      _notifTitleController.clear();
      _notifBodyController.clear();
      _notifImageUrlController.clear();
      _notifActionController.clear();
    } catch (e) {
      ToastHelper.show(context, 'Failed: $e');
    } finally {
      setState(() => _isSendingNotif = false);
    }
  }

  Widget _buildNotifHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('admin_notifications').orderBy('timestamp', descending: true).limit(5).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();
        final docs = snapshot.data!.docs;
        return Column(
          children: docs.map((doc) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.notifications_active, color: Colors.white, size: 18)),
              title: Text(doc['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(doc['body']),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(doc['target'].toString().toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  Text(doc['status'] ?? 'sent', style: const TextStyle(fontSize: 10, color: Colors.green)),
                ],
              ),
            ),
          )).toList(),
        );
      },
    );
  }

  Widget _buildHealthMonitor(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161922) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withAlpha(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildHealthIndicator('Firebase', true),
          _buildHealthIndicator('AI Engine', true),
          _buildHealthIndicator('Storage', true),
          _buildHealthIndicator('Auth', true),
        ],
      ),
    );
  }

  Widget _buildHealthIndicator(String service, bool active) {
    return Column(
      children: [
        Icon(active ? Icons.check_circle_rounded : Icons.error_rounded, color: active ? Colors.green : Colors.red),
        const SizedBox(height: 8),
        Text(service, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildModernTabBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(width: 3, color: AppColors.primary),
          insets: const EdgeInsets.symmetric(horizontal: 16),
        ),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Users'),
          Tab(text: 'Feedback'),
          Tab(text: 'Notifications'),
          Tab(text: 'Templates'),
          Tab(text: 'System Config'),
        ],
      ),
    );
  }

  Widget _buildUsersTab(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search user by email...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: isDark ? Colors.white.withAlpha(5) : Colors.black.withAlpha(5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
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
                users = users.where((u) => u['email'].toString().toLowerCase().contains(_searchController.text.toLowerCase())).toList();
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final bool isPro = user['isPro'] ?? false;
                  return Card(
                    elevation: 0,
                    color: isDark ? const Color(0xFF161922) : Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withAlpha(20))),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        backgroundColor: isPro ? Colors.amber.withAlpha(30) : Colors.grey.withAlpha(30),
                        child: Icon(isPro ? Icons.stars_rounded : Icons.person_rounded, color: isPro ? Colors.amber : Colors.grey),
                      ),
                      title: Text(user['email'], style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                      subtitle: Text('ID: ${user.id}\nJoined: ${user['joinDate']?.toDate().toString().split(' ')[0] ?? '---'}', style: const TextStyle(fontSize: 11)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('PRO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          Switch(
                            value: isPro,
                            activeColor: Colors.amber,
                            onChanged: (val) => _togglePro(user.id, val),
                          ),
                        ],
                      ),
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
          padding: const EdgeInsets.all(24),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            final String? url = msg['attachmentUrl'];
            final String type = msg['type'] ?? 'general';

            return Card(
              elevation: 0,
              color: isDark ? const Color(0xFF161922) : Colors.white,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withAlpha(20))),
              child: ExpansionTile(
                iconColor: AppColors.primary,
                leading: _getTypeIcon(type),
                title: Text(msg['userEmail'], style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                subtitle: Text(msg['message'], maxLines: 1, overflow: TextOverflow.ellipsis),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        Text('Detailed Message:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(msg['message'], style: GoogleFonts.inter(height: 1.5)),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            if (url != null)
                              ElevatedButton.icon(
                                onPressed: () => _launchUrl(url),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                icon: const Icon(Icons.attach_file_rounded, size: 16, color: Colors.white),
                                label: const Text('VIEW PROOF', style: TextStyle(color: Colors.white, fontSize: 11)),
                              ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => _deleteFeedback(msg.id),
                              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                            ),
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Text('Public Templates', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => ToastHelper.show(context, 'Feature: Add Template UI coming soon'),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('ADD NEW TEMPLATE', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestoreService.getPublicTemplates(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final templates = snapshot.data!;
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final t = templates[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(t['description'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined, size: 18)),
                                IconButton(onPressed: () => _firestoreService.deleteTemplate(t['id']), icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red)),
                              ],
                            )
                          ],
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withAlpha(40), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 20),
          Text(value, style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w800)),
          Text(title, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
        ],
      ),
    );
  }

  Widget _buildUserBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 14, backgroundColor: Colors.purpleAccent, child: Icon(Icons.person, color: Colors.white, size: 16)),
          const SizedBox(width: 12),
          Text('Super Admin', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}
