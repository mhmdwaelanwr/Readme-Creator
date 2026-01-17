import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/app_colors.dart';
import '../utils/dialog_helper.dart';

class DeveloperInfoDialog extends StatelessWidget {
  const DeveloperInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StyledDialog(
      title: const DialogHeader(
        title: 'About Developer',
        icon: Icons.code,
        color: AppColors.primary,
      ),
      width: 650,
      height: 600,
      contentPadding: EdgeInsets.zero,
      content: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  labelColor: isDark ? Colors.white : AppColors.primary,
                  unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: AppColors.primary.withAlpha(isDark ? 40 : 20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withAlpha(100)),
                  ),
                  dividerColor: Colors.transparent,
                  labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
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

  Widget _buildSocialsTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('SOCIAL MEDIA'),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              _buildSocialGridItem(FontAwesomeIcons.facebook, 'Facebook', 'https://facebook.com/mhmdwaelanwr', Colors.blue[700]!),
              _buildSocialGridItem(FontAwesomeIcons.instagram, 'Instagram', 'https://instagram.com/mhmdwaelanwr', Colors.pink),
              _buildSocialGridItem(FontAwesomeIcons.threads, 'Threads', 'https://threads.net/@mhmdwaelanwr', isDark ? Colors.white : Colors.black),
              _buildSocialGridItem(FontAwesomeIcons.linkedin, 'LinkedIn', 'https://linkedin.com/in/mhmdwaelanwr', Colors.blue[800]!),
              _buildSocialGridItem(FontAwesomeIcons.tiktok, 'TikTok', 'https://tiktok.com/@mhmdwaelanwr', isDark ? Colors.white : Colors.black),
              _buildSocialGridItem(FontAwesomeIcons.youtube, 'YouTube', 'https://youtube.com/@mhmdwaelanwr', Colors.red),
              _buildSocialGridItem(FontAwesomeIcons.twitch, 'Twitch', 'https://twitch.tv/mhmdwaelanwr', Colors.deepPurple),
              _buildSocialGridItem(FontAwesomeIcons.snapchat, 'Snapchat', 'https://snapchat.com/add/mhmdwaelanwr', Colors.yellow[700]!),
              _buildSocialGridItem(FontAwesomeIcons.reddit, 'Reddit', 'https://reddit.com/user/mhmdwaelanwar', Colors.orange[800]!),
              _buildSocialGridItem(FontAwesomeIcons.telegram, 'Telegram', 'https://t.me/mhmdwaelanwr', Colors.blue),
              _buildSocialGridItem(FontAwesomeIcons.discord, 'Discord', null, Colors.indigoAccent, copyText: 'mhmdwaelanwr'),
              _buildSocialGridItem(FontAwesomeIcons.spotify, 'Spotify', 'https://open.spotify.com/user/mhmdwaelanwr', Colors.green),
            ],
          ),
          const SizedBox(height: 32),
          _buildSectionTitle('DEVELOPER PROFILES'),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              _buildSocialGridItem(FontAwesomeIcons.github, 'GitHub', 'https://github.com/mhmdwaelanwr', isDark ? Colors.white : Colors.black),
              _buildSocialGridItem(FontAwesomeIcons.gitlab, 'GitLab', 'https://gitlab.com/mhmdwaelanwr', Colors.orange),
              _buildSocialGridItem(FontAwesomeIcons.google, 'Google Dev', 'https://g.dev/mhmdwaelanwr', Colors.blue),
              _buildSocialGridItem(FontAwesomeIcons.codeBranch, 'Gitea', 'https://gitea.com/mhmdwaelanwr', Colors.green),
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
        _buildContactTile(Icons.email_rounded, 'Primary Email', 'mhmdwaelanwr@gmail.com', onTap: () => _launchUrl('mailto:mhmdwaelanwr@gmail.com')),
        _buildContactTile(Icons.email_outlined, 'Secondary Email', 'mhmdwaelanwr@outlook.com', onTap: () => _launchUrl('mailto:mhmdwaelanwr@outlook.com')),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(),
        ),
        _buildContactTile(Icons.phone_rounded, 'Primary Phone', '+201010373387', onTap: () => _launchUrl('tel:+201010373387')),
        _buildContactTile(FontAwesomeIcons.whatsapp, 'WhatsApp', '+201010412724', color: Colors.green, onTap: () => _launchUrl('https://wa.me/201010412724')),
        _buildContactTile(FontAwesomeIcons.skype, 'Skype', '01010412724', color: Colors.blue, onTap: () => _launchUrl('skype:01010412724?chat')),
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: const Icon(FontAwesomeIcons.solidHeart, color: Colors.red, size: 64),
            ),
            const SizedBox(height: 24),
            Text(
              'Support My Work',
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'If you find this tool helpful, consider supporting its development.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildSocialButton(FontAwesomeIcons.paypal, 'PayPal', 'https://paypal.me/mhmdwaelanwar', color: const Color(0xFF003087)),
                _buildSocialButton(Icons.question_answer_rounded, 'NGL', 'https://ngl.link/mhmdwaelanwar', color: Colors.pinkAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.primary.withAlpha(180),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSocialGridItem(IconData icon, String label, String? url, Color iconColor, {String? copyText}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (url != null) {
            _launchUrl(url);
          } else if (copyText != null) {
            Clipboard.setData(ClipboardData(text: copyText));
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withAlpha(40)),
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey.withAlpha(5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: iconColor),
              const SizedBox(height: 10),
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label, String url, {Color? color}) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      onPressed: () => _launchUrl(url),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }

  Widget _buildContactTile(IconData icon, String title, String subtitle, {Color? color, VoidCallback? onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withAlpha(30)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (color ?? AppColors.primary).withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color ?? AppColors.primary, size: 22),
        ),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
        trailing: const Icon(Icons.open_in_new_rounded, size: 16, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
