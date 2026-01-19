import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/auth_service.dart';
import '../../utils/dialog_helper.dart';
import '../../utils/toast_helper.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/country_codes.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  late TabController _tabController;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String? _verificationId;
  String _selectedCountryCode = '20';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn(Future<dynamic> Function() signInMethod, String providerName) async {
    if (!_authService.isReady) {
      ToastHelper.show(context, 'Firebase is not initialized. Please run configure first.', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final result = await signInMethod();
      if (result != null && mounted) {
        Navigator.pop(context);
        ToastHelper.show(context, 'Successfully authenticated via $providerName');
      }
    } catch (e) {
      if (mounted) ToastHelper.show(context, 'Authentication failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StyledDialog(
      title: const DialogHeader(
        title: 'Account Access',
        icon: Icons.vpn_key_rounded,
        color: AppColors.primary,
      ),
      width: 500,
      height: 650,
      contentPadding: EdgeInsets.zero,
      content: Column(
        children: [
          _buildInfoBanner(),
          _buildTabBar(),
          Expanded(
            child: _isLoading 
              ? _buildLoadingState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSocialLoginTab(),
                    _buildEmailLoginTab(),
                    _buildPhoneLoginTab(),
                  ],
                ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Dismiss', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return const GlassCard(
      opacity: 0.1,
      color: AppColors.primary,
      borderRadius: 0,
      child: Row(
        children: [
          Icon(Icons.cloud_done_rounded, size: 16, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sign in to enable real-time cloud synchronization.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(10),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          dividerColor: Colors.transparent,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'SOCIAL'),
            Tab(text: 'EMAIL'),
            Tab(text: 'PHONE'),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLoginTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildLoginButton(
          icon: FontAwesomeIcons.google,
          label: 'Continue with Google',
          color: Colors.redAccent,
          onTap: () => _handleSignIn(_authService.signInWithGoogle, 'Google'),
        ),
        _buildLoginButton(
          icon: FontAwesomeIcons.apple,
          label: 'Continue with Apple',
          color: Colors.grey,
          onTap: () => _handleSignIn(_authService.signInWithApple, 'Apple'),
        ),
        _buildLoginButton(
          icon: FontAwesomeIcons.github,
          label: 'Continue with GitHub',
          color: Colors.blueGrey,
          onTap: () => _handleSignIn(_authService.signInWithGitHub, 'GitHub'),
        ),
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 12),
        _buildLoginButton(
          icon: Icons.person_outline_rounded,
          label: 'Continue as Guest',
          color: Colors.blueGrey,
          onTap: () => _handleSignIn(_authService.signInAnonymously, 'Guest Mode'),
          isOutline: true,
        ),
      ],
    );
  }

  Widget _buildEmailLoginTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildAuthField(controller: _emailController, label: 'Email Address', icon: Icons.alternate_email_rounded),
          const SizedBox(height: 16),
          _buildAuthField(controller: _passwordController, label: 'Password', icon: Icons.lock_outline_rounded, isPassword: true),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              onPressed: () => _handleSignIn(() => _authService.signInWithEmail(_emailController.text, _passwordController.text), 'Email'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Log In', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => _handleSignIn(() => _authService.signUpWithEmail(_emailController.text, _passwordController.text), 'Account'),
            child: Text('New here? Create an account', style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneLoginTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (_verificationId == null) ...[
            Row(
              children: [
                Container(
                  width: 120,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(10),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withAlpha(20)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedCountryCode,
                      items: CountryCodes.list.map((c) => DropdownMenuItem(
                        value: c.code,
                        child: Text(
                          '${c.emoji} +${c.code}', 
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCountryCode = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAuthField(
                    controller: _phoneController, 
                    label: 'Phone Number', 
                    icon: Icons.phone_android_rounded, 
                    hint: '1012345678'
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                icon: const Icon(Icons.send_rounded, size: 18),
                onPressed: () {
                  if (_phoneController.text.isEmpty) return;
                  final fullNumber = '+${_selectedCountryCode}${_phoneController.text}';
                  _authService.verifyPhoneNumber(
                    phoneNumber: fullNumber,
                    verificationCompleted: (cred) => _handleSignIn(() => _authService.signInWithPhoneCredential(cred.verificationId!, cred.smsCode!), 'Phone'),
                    verificationFailed: (e) => ToastHelper.show(context, 'Error: ${e.message}', isError: true),
                    codeSent: (id, _) {
                      setState(() => _verificationId = id);
                      ToastHelper.show(context, 'Verification code sent to $fullNumber');
                    },
                    codeAutoRetrievalTimeout: (id) => _verificationId = id,
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                label: const Text('Send Code'),
              ),
            ),
          ] else ...[
            _buildAuthField(controller: _otpController, label: 'Verification Code', icon: Icons.mark_email_read_rounded, hint: '123456'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: () => _handleSignIn(() => _authService.signInWithPhoneCredential(_verificationId!, _otpController.text), 'Phone'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Verify & Login'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => setState(() => _verificationId = null),
              child: const Text('Use a different number', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAuthField({required TextEditingController controller, required String label, required IconData icon, String? hint, bool isPassword = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withAlpha(20)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withAlpha(20)),
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(10),
      ),
      style: GoogleFonts.inter(fontSize: 14),
    );
  }

  Widget _buildLoginButton({required IconData icon, required String label, required Color color, required VoidCallback onTap, bool isOutline = false}) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      borderRadius: 20,
      opacity: isOutline ? 0 : 0.05,
      color: isOutline ? color : null,
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 16),
          Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
          const Spacer(),
          Icon(Icons.login_rounded, size: 16, color: Colors.grey.withAlpha(150)),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
          const SizedBox(height: 20),
          Text('Securing your connection...', style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
