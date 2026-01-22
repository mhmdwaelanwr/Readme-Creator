import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../utils/dialog_helper.dart';
import '../developer_info_dialog.dart';
import 'feedback_dialog.dart';

class AboutAppDialog extends StatelessWidget {
  const AboutAppDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return StyledDialog(
      title: const DialogHeader(
        title: 'About App',
        icon: Icons.auto_awesome_rounded,
        color: AppColors.primary,
      ),
      width: 600,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            _buildHeroSection(context),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Markdown Creator is an advanced development utility designed to simplify the process of creating high-quality documentation. Built with a focus on speed, aesthetics, and developer experience.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildFeatureSection(context),
            const SizedBox(height: 32),
            
            // --- Support & Feedback Section (SaaS Improvement) ---
            _buildInfoCard(
              context,
              icon: Icons.support_agent_rounded,
              title: 'Need Help or Have a Suggestion?',
              subtitle: 'Support & Feedback',
              trailing: 'Contact',
              onTap: () {
                Navigator.pop(context);
                showSafeDialog(
                  context,
                  builder: (context) => const FeedbackDialog(),
                );
              },
            ),

            _buildInfoCard(
              context,
              icon: Icons.face_retouching_natural_rounded,
              title: 'Mastermind Behind the Project',
              subtitle: 'Mohamed Anwar',
              trailing: 'Profile',
              onTap: () {
                Navigator.pop(context);
                showSafeDialog(
                  context,
                  builder: (context) => const DeveloperInfoDialog(),
                );
              },
            ),
            
            _buildInfoCard(
              context,
              icon: Icons.gavel_rounded,
              title: 'Legal & Transparency',
              subtitle: 'Privacy Policy & Licenses',
              trailing: 'View',
              onTap: () {
                _showLegalMenu(context);
              },
            ),
            const SizedBox(height: 32),
            _buildTechStackFooter(context),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Dismiss', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
        FilledButton.icon(
          onPressed: () => _launchUrl('https://github.com/mhmdwaelanwr/Markdown-Creator/stargazers'),
          icon: const Icon(Icons.star_rounded, size: 18),
          label: const Text('Support with a Star'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFBBF24),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  void _showLegalMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.privacy_tip_rounded, color: AppColors.primary),
              title: const Text('Privacy Policy'),
              onTap: () {
                Navigator.pop(context);
                _launchUrl('https://your-domain.com/privacy'); // Replace with actual URL
              },
            ),
            ListTile(
              leading: const Icon(Icons.description_rounded, color: AppColors.primary),
              title: const Text('Terms of Service'),
              onTap: () {
                Navigator.pop(context);
                _launchUrl('https://your-domain.com/terms'); // Replace with actual URL
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt_rounded, color: AppColors.primary),
              title: const Text('Third-Party Licenses'),
              onTap: () {
                Navigator.pop(context);
                showLicensePage(
                  context: context,
                  applicationName: 'Markdown Creator',
                  applicationVersion: '1.0.0',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassCard(
      opacity: 0.1,
      color: AppColors.primary,
      borderRadius: 28,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(isDark ? 100 : 40),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.description_rounded, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text(
            'Markdown Creator',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              color: isDark ? Colors.white : AppColors.primary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'v1.0.0 Stable',
              style: GoogleFonts.firaCode(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureSection(BuildContext context) {
    final features = [
      {'icon': Icons.bolt, 'label': 'Lightning Fast'},
      {'icon': Icons.devices, 'label': 'Multi-Platform'},
      {'icon': Icons.auto_fix_high, 'label': 'AI Assisted'},
      {'icon': Icons.security, 'label': 'Privacy First'},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: features.map((f) => GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        borderRadius: 12,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(f['icon'] as IconData, size: 16, color: AppColors.secondary),
            const SizedBox(width: 8),
            Text(
              f['label'] as String,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String trailing,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 0.5),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              trailing,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechStackFooter(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          'BUILT WITH MODERN TECH',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Colors.grey.withAlpha(150),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _techIcon(FontAwesomeIcons.flutter, 'Flutter', Colors.blue),
            _techIcon(Icons.terminal_rounded, 'Dart', Colors.cyan),
            _techIcon(Icons.psychology_rounded, 'AI', Colors.purple),
            _techIcon(FontAwesomeIcons.markdown, 'Markdown', isDark ? Colors.white : Colors.black),
          ],
        ),
      ],
    );
  }

  Widget _techIcon(IconData icon, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Tooltip(
        message: label,
        child: Icon(icon, size: 20, color: color.withAlpha(180)),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
