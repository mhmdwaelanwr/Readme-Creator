import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
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

  // Controllers for Email/Pass
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Controllers for Phone
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String? _verificationId;
  String _selectedCountryCode = '20'; // Default to Egypt

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          _buildInfoBanner(isDark),
          _buildTabBar(isDark),
          Expanded(
            child: _isLoading 
              ? _buildLoadingState(isDark)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSocialLoginTab(context, isDark),
                    _buildEmailLoginTab(context, isDark),
                    _buildPhoneLoginTab(context, isDark),
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

  Widget _buildInfoBanner(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(isDark ? 30 : 10),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_done_rounded, size: 16, color: AppColors.primary.withAlpha(200)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sign in to enable real-time cloud synchronization.',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary.withAlpha(200)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withAlpha(8) : Colors.black.withAlpha(4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF6366F1)]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: AppColors.primary.withAlpha(60), blurRadius: 8, offset: const Offset(0, 2))],
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

  Widget _buildSocialLoginTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildLoginButton(
          icon: FontAwesomeIcons.google,
          label: 'Continue with Google',
          color: Colors.redAccent,
          onTap: () => _handleSignIn(_authService.signInWithGoogle, 'Google'),
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildLoginButton(
          icon: FontAwesomeIcons.apple,
          label: 'Continue with Apple',
          color: isDark ? Colors.white : Colors.black,
          onTap: () => _handleSignIn(_authService.signInWithApple, 'Apple'),
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildLoginButton(
          icon: FontAwesomeIcons.github,
          label: 'Continue with GitHub',
          color: isDark ? Colors.white : const Color(0xFF24292E),
          onTap: () => _handleSignIn(_authService.signInWithGitHub, 'GitHub'),
          isDark: isDark,
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 12),
        _buildLoginButton(
          icon: Icons.person_outline_rounded,
          label: 'Continue as Guest',
          color: Colors.blueGrey,
          onTap: () => _handleSignIn(_authService.signInAnonymously, 'Guest Mode'),
          isDark: isDark,
          isOutline: true,
        ),
      ],
    );
  }

  Widget _buildEmailLoginTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildAuthField(controller: _emailController, label: 'Email Address', icon: Icons.alternate_email_rounded, isDark: isDark),
          const SizedBox(height: 16),
          _buildAuthField(controller: _passwordController, label: 'Password', icon: Icons.lock_outline_rounded, isDark: isDark, isPassword: true),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => _handleSignIn(() => _authService.signInWithEmail(_emailController.text, _passwordController.text), 'Email'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
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

  Widget _buildPhoneLoginTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (_verificationId == null) ...[
            Row(
              children: [
                // Country Code Picker - Same logic as Social Links
                Container(
                  width: 120, // Slightly wider to avoid overflow
                  height: 54,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withAlpha(5) : Colors.black.withAlpha(3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withAlpha(30)),
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
                          overflow: TextOverflow.ellipsis,
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
                    isDark: isDark, 
                    hint: '1012345678'
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                label: const Text('Send Code'),
              ),
            ),
          ] else ...[
            _buildAuthField(controller: _otpController, label: 'Verification Code', icon: Icons.mark_email_read_rounded, isDark: isDark, hint: '123456'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => _handleSignIn(() => _authService.signInWithPhoneCredential(_verificationId!, _otpController.text), 'Phone'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
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

  Widget _buildAuthField({required TextEditingController controller, required String label, required IconData icon, required bool isDark, String? hint, bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: isDark ? Colors.white.withAlpha(5) : Colors.black.withAlpha(3),
      ),
      style: GoogleFonts.inter(fontSize: 14),
    );
  }

  Widget _buildLoginButton({required IconData icon, required String label, required Color color, required VoidCallback onTap, required bool isDark, bool isOutline = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isOutline ? color.withAlpha(100) : Colors.grey.withAlpha(30)),
            color: isOutline ? Colors.transparent : (isDark ? Colors.white.withAlpha(5) : Colors.white),
            boxShadow: isOutline ? null : [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 16),
              Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
              const Spacer(),
              Icon(Icons.login_rounded, size: 16, color: Colors.grey.withAlpha(150)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
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
