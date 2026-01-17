import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../utils/dialog_helper.dart';
import '../developer_info_dialog.dart';

class AboutAppDialog extends StatelessWidget {
  const AboutAppDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return StyledDialog(
      title: const DialogHeader(
        title: 'About Readme Creator',
        icon: Icons.info_outline_rounded,
        color: AppColors.primary,
      ),
      width: 550,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          // App Logo & Name Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.primary.withAlpha(isDark ? 30 : 15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colorScheme.primary.withAlpha(30)),
            ),
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ).createShader(bounds),
                  child: const Icon(Icons.description_rounded, size: 72, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  'Readme Creator',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Version 1.0.0',
                  style: GoogleFonts.inter(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'The ultimate open-source tool for generating professional GitHub README files. Designed for developers who value speed, quality, and aesthetics.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              height: 1.6,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 32),
          // Developer Card
          _buildInfoCard(
            context,
            icon: Icons.developer_mode_rounded,
            title: 'Developed By',
            subtitle: 'Mohamed Anwar',
            onTap: () {
              Navigator.pop(context);
              showSafeDialog(
                context,
                builder: (context) => const DeveloperInfoDialog(),
              );
            },
          ),
          const SizedBox(height: 12),
          // GitHub Link Card
          _buildInfoCard(
            context,
            icon: Icons.code_rounded,
            title: 'Open Source Project',
            subtitle: 'View Source on GitHub',
            color: Colors.black,
            onTap: () => _launchUrl('https://github.com/mhmdwaelanwr/Readme-Creator'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
        FilledButton.icon(
          onPressed: () => _launchUrl('https://github.com/mhmdwaelanwr/Readme-Creator/stargazers'),
          icon: const Icon(Icons.star_rounded, size: 18),
          label: const Text('Star Project'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.amber[700],
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Color? color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withAlpha(isDark ? 40 : 30)),
      ),
      color: isDark ? Colors.white.withAlpha(5) : Colors.black.withAlpha(5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (color ?? AppColors.primary).withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color ?? AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
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
