import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/app_colors.dart';
import '../utils/dialog_helper.dart';
import '../utils/toast_helper.dart';

class DeveloperInfoDialog extends StatelessWidget {
  const DeveloperInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return StyledDialog(
      title: const DialogHeader(
        title: 'Developer Profile',
        icon: Icons.person_search_rounded,
        color: AppColors.primary,
      ),
      width: 700,
      height: 750,
      contentPadding: EdgeInsets.zero,
      content: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            // Header Profile Section
            _buildProfileHeader(context, isDark),
            
            // Modern TabBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withAlpha(180)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(60),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  dividerColor: Colors.transparent,
                  labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: const [
                    Tab(text: 'Socials & Dev'),
                    Tab(text: 'Contact'),
                    Tab(text: 'Support'),
                  ],
                ),
              ),
            ),
            
            Expanded(
              child: TabBarView(
                children: [
                  _buildSocialsTab(context, isDark),
                  _buildContactTab(context, isDark),
                  _buildSupportTab(context, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Avatar with animated glow effect
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
            ),
            child: const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF1E293B),
              child: Icon(Icons.code_rounded, size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mohamed Anwar',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Full-Stack Developer & UI/UX Enthusiast',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Passionate about building clean, efficient, and open-source tools for developers.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialsTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(Icons.share_rounded, 'CONNECT WITH ME'),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0,
            children: [
              _buildSocialGridItem(context, FontAwesomeIcons.facebook, 'Facebook', 'https://facebook.com/mhmdwaelanwr', Colors.blue[700]!),
              _buildSocialGridItem(context, FontAwesomeIcons.instagram, 'Instagram', 'https://instagram.com/mhmdwaelanwr', Colors.pink),
              _buildSocialGridItem(context, FontAwesomeIcons.threads, 'Threads', 'https://threads.net/@mhmdwaelanwr', isDark ? Colors.white : Colors.black),
              _buildSocialGridItem(context, FontAwesomeIcons.linkedin, 'LinkedIn', 'https://linkedin.com/in/mhmdwaelanwr', Colors.blue[800]!),
              _buildSocialGridItem(context, FontAwesomeIcons.tiktok, 'TikTok', 'https://tiktok.com/@mhmdwaelanwr', isDark ? Colors.white : Colors.black),
              _buildSocialGridItem(context, FontAwesomeIcons.youtube, 'YouTube', 'https://youtube.com/@mhmdwaelanwr', Colors.red),
              _buildSocialGridItem(context, FontAwesomeIcons.twitch, 'Twitch', 'https://twitch.tv/mhmdwaelanwr', Colors.deepPurple),
              _buildSocialGridItem(context, FontAwesomeIcons.snapchat, 'Snapchat', 'https://snapchat.com/add/mhmdwaelanwr', Colors.yellow[700]!),
              _buildSocialGridItem(context, FontAwesomeIcons.reddit, 'Reddit', 'https://reddit.com/user/mhmdwaelanwar', Colors.orange[800]!),
              _buildSocialGridItem(context, FontAwesomeIcons.telegram, 'Telegram', 'https://t.me/mhmdwaelanwr', Colors.blue),
              _buildSocialGridItem(context, FontAwesomeIcons.discord, 'Discord', null, Colors.indigoAccent, copyText: 'mhmdwaelanwr'),
              _buildSocialGridItem(context, FontAwesomeIcons.spotify, 'Spotify', 'https://open.spotify.com/user/mhmdwaelanwr', Colors.green),
            ],
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(Icons.terminal_rounded, 'DEVELOPER ECOSYSTEM'),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0,
            children: [
              _buildSocialGridItem(context, FontAwesomeIcons.github, 'GitHub', 'https://github.com/mhmdwaelanwr', isDark ? Colors.white : Colors.black),
              _buildSocialGridItem(context, FontAwesomeIcons.gitlab, 'GitLab', 'https://gitlab.com/mhmdwaelanwr', Colors.orange),
              _buildSocialGridItem(context, FontAwesomeIcons.google, 'Google Dev', 'https://g.dev/mhmdwaelanwr', Colors.blue),
              _buildSocialGridItem(context, FontAwesomeIcons.codeBranch, 'Gitea', 'https://gitea.com/mhmdwaelanwr', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildContactTile(context, Icons.email_rounded, 'Primary Email', 'mhmdwaelanwr@gmail.com', onTap: () => _launchUrl('mailto:mhmdwaelanwr@gmail.com')),
        _buildContactTile(context, Icons.alternate_email_rounded, 'Secondary Email', 'mhmdwaelanwr@outlook.com', onTap: () => _launchUrl('mailto:mhmdwaelanwr@outlook.com')),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          child: Divider(indent: 16, endIndent: 16),
        ),
        _buildContactTile(context, Icons.phone_iphone_rounded, 'Direct Line', '+201010373387', onTap: () => _launchUrl('tel:+201010373387')),
        _buildContactTile(context, FontAwesomeIcons.whatsapp, 'WhatsApp Chat', '+201010412724', color: Colors.green, onTap: () => _launchUrl('https://wa.me/201010412724')),
        _buildContactTile(context, FontAwesomeIcons.skype, 'Skype ID', '01010412724', color: Colors.blue, onTap: () => _launchUrl('skype:01010412724?chat')),
      ],
    );
  }

  Widget _buildSupportTab(BuildContext context, bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(15),
                    shape: BoxShape.circle,
                  ),
                ),
                const Icon(FontAwesomeIcons.solidHeart, color: Colors.red, size: 64),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Fueled by Passion',
              style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Your support helps me maintain and improve this tool for everyone. Every contribution counts!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 48),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                _buildActionBtn(context, FontAwesomeIcons.paypal, 'Support via PayPal', 'https://paypal.me/mhmdwaelanwar', color: const Color(0xFF003087)),
                _buildActionBtn(context, Icons.question_answer_rounded, 'Send Secret Message', 'https://ngl.link/mhmdwaelanwar', color: Colors.pinkAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppColors.primary.withAlpha(200),
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialGridItem(BuildContext context, IconData icon, String label, String? url, Color iconColor, {String? copyText}) {
    return Tooltip(
      message: url ?? (copyText != null ? 'Copy $copyText' : label),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (url != null) {
              _launchUrl(url);
            } else if (copyText != null) {
              Clipboard.setData(ClipboardData(text: copyText));
              ToastHelper.show(context, '$label copied to clipboard');
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withAlpha(30)),
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withAlpha(5) : Colors.black.withAlpha(3),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: iconColor),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn(BuildContext context, IconData icon, String label, String url, {Color? color}) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(label),
      onPressed: () => _launchUrl(url),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
    );
  }

  Widget _buildContactTile(BuildContext context, IconData icon, String title, String subtitle, {Color? color, VoidCallback? onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.withAlpha(30)),
      ),
      color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withAlpha(5) : Colors.white,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (color ?? AppColors.primary).withAlpha(20),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color ?? AppColors.primary, size: 24),
        ),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14)),
        subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])),
        trailing: const Icon(Icons.arrow_outward_rounded, size: 18, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch $urlString: $e');
    }
  }
}
