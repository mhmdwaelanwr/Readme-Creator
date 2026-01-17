import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/auth_service.dart';
import '../../utils/dialog_helper.dart';
import '../../utils/toast_helper.dart';
import '../../core/constants/app_colors.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _handleSignIn(Future<dynamic> Function() signInMethod, String providerName) async {
    // Check if Firebase is actually configured
    if (!_authService.isReady) {
      ToastHelper.show(context, 'Firebase is not initialized yet. Check your setup.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await signInMethod();
      if (result != null) {
        if (mounted) {
          Navigator.pop(context);
          ToastHelper.show(context, 'Successfully signed in with $providerName');
        }
      } else {
        // Handle case where user cancels login or result is null
        if (mounted) {
          ToastHelper.show(context, 'Sign-in cancelled or failed.', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.show(context, 'Login Error: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StyledDialog(
      title: const DialogHeader(
        title: 'Join the Community',
        icon: Icons.auto_awesome_rounded,
        color: AppColors.primary,
      ),
      width: 450,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeroSection(isDark),
          const SizedBox(height: 24),
          
          if (!_authService.isReady) 
            _buildWarningBox('Firebase connection not detected. Please complete "flutterfire configure" to enable cloud features.', isDark),

          const SizedBox(height: 16),
          
          if (_isLoading)
            _buildLoadingState(isDark)
          else ...[
            _buildLoginButton(
              context: context,
              icon: FontAwesomeIcons.google,
              label: 'Sign in with Google',
              color: Colors.redAccent,
              onTap: () => _handleSignIn(_authService.signInWithGoogle, 'Google'),
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildLoginButton(
              context: context,
              icon: FontAwesomeIcons.github,
              label: 'Sign in with GitHub',
              color: isDark ? Colors.white : Colors.black,
              onTap: () => _handleSignIn(_authService.signInWithGitHub, 'GitHub'),
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildLoginButton(
              context: context,
              icon: Icons.person_outline_rounded,
              label: 'Use Guest Account',
              color: Colors.blueGrey,
              onTap: () => _handleSignIn(_authService.signInAnonymously, 'Guest Mode'),
              isDark: isDark,
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'Secured by Firebase Authentication',
            style: GoogleFonts.inter(fontSize: 10, color: Colors.grey.withAlpha(100), fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _buildHeroSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary.withAlpha(30), AppColors.primary.withAlpha(10)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withAlpha(30)),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_sync_rounded, size: 40, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            'Cloud Sync is here!',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'Access your projects and custom snippets from any device.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBox(String message, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withAlpha(isDark ? 20 : 10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withAlpha(50)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: GoogleFonts.inter(fontSize: 11, color: Colors.orange[800], fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Column(
      children: [
        const CircularProgressIndicator(strokeWidth: 3),
        const SizedBox(height: 16),
        Text('Connecting to service...', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
      ],
    );
  }

  Widget _buildLoginButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withAlpha(isDark ? 40 : 30)),
            color: isDark ? Colors.white.withAlpha(5) : Colors.white,
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 16),
              Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              const Icon(Icons.login_rounded, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
