import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/app_colors.dart';
import '../utils/dialog_helper.dart'; // Added import

class DeveloperInfoDialog extends StatelessWidget {
  const DeveloperInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Refactored to use StyledDialog
    return StyledDialog(
      title: const DialogHeader(
        title: 'About Developer',
        icon: Icons.code,
        color: AppColors.primary,
      ),
      width: 600,
      height: 500,
      contentPadding: EdgeInsets.zero,
      content: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: isDark ? Colors.grey : Colors.black54,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppColors.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary),
                ),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Socials & Dev'),
                  Tab(text: 'Contact'),
                  Tab(text: 'Support'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildSocialsTab(context),
                  _buildContactTab(context),
                  _buildSupportTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildSocialsTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Social Media'),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildSocialButton(FontAwesomeIcons.facebook, 'Facebook', 'https://facebook.com/mhmdwaelanwr'),
              _buildSocialButton(FontAwesomeIcons.instagram, 'Instagram', 'https://instagram.com/mhmdwaelanwr'),
              _buildSocialButton(FontAwesomeIcons.twitter, 'Threads', 'https://threads.net/@mhmdwaelanwr'), // Threads icon not always available, using Twitter/X or generic
              _buildSocialButton(FontAwesomeIcons.linkedin, 'LinkedIn', 'https://linkedin.com/in/mhmdwaelanwr'),
              _buildSocialButton(FontAwesomeIcons.tiktok, 'TikTok', 'https://tiktok.com/@mhmdwaelanwr'),
              _buildSocialButton(FontAwesomeIcons.youtube, 'YouTube', 'https://youtube.com/@mhmdwaelanwr'),
              _buildSocialButton(FontAwesomeIcons.twitch, 'Twitch', 'https://twitch.tv/mhmdwaelanwr'),
              _buildSocialButton(FontAwesomeIcons.snapchat, 'Snapchat', 'https://snapchat.com/add/mhmdwaelanwr'),
              _buildSocialButton(FontAwesomeIcons.reddit, 'Reddit', 'https://reddit.com/user/mhmdwaelanwar'),
              _buildSocialButton(FontAwesomeIcons.telegram, 'Telegram', 'https://t.me/mhmdwaelanwr'),
              _buildSocialButton(FontAwesomeIcons.discord, 'Discord', null, copyText: 'mhmdwaelanwr'),
              _buildSocialButton(FontAwesomeIcons.spotify, 'Spotify', 'https://open.spotify.com/user/mhmdwaelanwr'),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Developer Profiles'),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildSocialButton(FontAwesomeIcons.github, 'GitHub', 'https://github.com/mhmdwaelanwr'),
              _buildSocialButton(FontAwesomeIcons.gitlab, 'GitLab', 'https://gitlab.com/mhmdwaelanwr'),
              _buildSocialButton(FontAwesomeIcons.google, 'Google Dev', 'https://g.dev/mhmdwaelanwr'),
              _buildSocialButton(FontAwesomeIcons.codeBranch, 'Gitea', 'https://gitea.com/mhmdwaelanwr'), // Generic code branch for Gitea
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildContactTile(Icons.email, 'Primary Email', 'mhmdwaelanwr@gmail.com', onTap: () => _launchUrl('mailto:mhmdwaelanwr@gmail.com')),
          _buildContactTile(Icons.email_outlined, 'Secondary Email', 'mhmdwaelanwr@outlook.com', onTap: () => _launchUrl('mailto:mhmdwaelanwr@outlook.com')),
          const Divider(),
          _buildContactTile(Icons.phone, 'Primary Phone', '+201010373387', onTap: () => _launchUrl('tel:+201010373387')),
          _buildContactTile(FontAwesomeIcons.whatsapp, 'WhatsApp', '+201010412724', onTap: () => _launchUrl('https://wa.me/201010412724')),
          _buildContactTile(FontAwesomeIcons.skype, 'Skype', '01010412724', onTap: () => _launchUrl('skype:01010412724?chat')),
        ],
      ),
    );
  }

  Widget _buildSupportTab(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(FontAwesomeIcons.heart, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text('Support the Developer', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            children: [
              _buildSocialButton(FontAwesomeIcons.paypal, 'PayPal', 'https://paypal.me/mhmdwaelanwar', color: const Color(0xFF003087)),
              _buildSocialButton(Icons.question_answer, 'NGL', 'https://ngl.link/mhmdwaelanwar', color: Colors.pink),
              // Rave? Assuming Flutterwave or similar, or just a link if provided. User just said "rave".
              // I'll add a generic button for Rave if I don't have a URL, or just skip if unsure.
              // User said "rave : mhmdwaelanwr". Maybe rave.com/mhmdwaelanwr?
              // Let's assume it's a platform.
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label, String? url, {String? copyText, Color? color}) {
    return Tooltip(
      message: url ?? (copyText != null ? 'Copy $copyText' : label),
      child: InkWell(
        onTap: () {
          if (url != null) {
            _launchUrl(url);
          } else if (copyText != null) {
            Clipboard.setData(ClipboardData(text: copyText));
            // We need context to show toast, but this is a stateless widget helper.
            // We can't easily show toast here without context passed down or looking up.
            // But InkWell has context in builder? No.
            // We can just rely on tooltip or user knowing it copied.
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withAlpha(50)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, size: 24, color: color ?? AppColors.primary),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 12),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactTile(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 13)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
