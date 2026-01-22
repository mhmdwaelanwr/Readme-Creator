import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../services/subscription_service.dart';
import '../../utils/dialog_helper.dart';
import 'feedback_dialog.dart';

class PaywallDialog extends StatelessWidget {
  const PaywallDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final subService = Provider.of<SubscriptionService>(context);
    final isPro = subService.isPro;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StyledDialog(
      title: const DialogHeader(
        title: 'Premium Access',
        icon: Icons.workspace_premium_rounded,
        color: Colors.amber,
      ),
      width: 550,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusBanner(isPro),
            const SizedBox(height: 24),
            _buildFeatureRow(Icons.auto_awesome_rounded, 'Unlimited AI Document Generation', 'Unlock the full power of Gemini AI.'),
            _buildFeatureRow(Icons.picture_as_pdf_rounded, 'Pro PDF Exporting', 'Export beautifully formatted documents.'),
            _buildFeatureRow(Icons.cloud_sync_rounded, 'Cloud Sync & Library', 'Save your projects to the cloud.'),
            _buildFeatureRow(Icons.ads_click_rounded, 'Zero Advertisements', 'Enjoy a clean, focused workspace.'),
            const SizedBox(height: 32),
            
            // --- Sponsorship Reward Section ---
            _buildSponsorCard(context, isPro),
            
            const SizedBox(height: 24),
            if (!isPro)
              Text(
                'Join our Early Adopters program to get Pro for free today!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Maybe Later')),
        if (!isPro)
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
            child: const Text('Join Early Adopters'),
          ),
      ],
    );
  }

  Widget _buildSponsorCard(BuildContext context, bool isPro) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.pink.withAlpha(40), Colors.purple.withAlpha(40)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.pink.withAlpha(100)),
      ),
      child: Column(
        children: [
          const Icon(Icons.volunteer_activism_rounded, color: Colors.pink, size: 32),
          const SizedBox(height: 12),
          Text(
            'Become a Sponsor',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Donate to support development and get Lifetime Pro Access as a reward.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _sponsorButton(
                'Buy Me a Coffee', 
                Icons.coffee_rounded, 
                Colors.brown,
                () => _launchUrl('https://buymeacoffee.com/yourname'), // Replace with yours
              ),
              const SizedBox(width: 12),
              if (!isPro)
                _sponsorButton(
                  'Claim My Reward', 
                  Icons.verified_user_rounded, 
                  Colors.teal,
                  () {
                    Navigator.pop(context);
                    showSafeDialog(context, builder: (_) => const FeedbackDialog());
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sponsorButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(100)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(bool isPro) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isPro ? Colors.green.withAlpha(30) : Colors.amber.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isPro ? Colors.green : Colors.amber),
      ),
      child: Row(
        children: [
          Icon(isPro ? Icons.verified_rounded : Icons.info_outline_rounded, color: isPro ? Colors.green : Colors.amber),
          const SizedBox(width: 12),
          Text(isPro ? 'Pro Status: ACTIVE' : 'Pro Status: INACTIVE', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: isPro ? Colors.green : Colors.amber[900])),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(desc, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}
