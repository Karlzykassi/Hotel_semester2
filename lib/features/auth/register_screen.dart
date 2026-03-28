import 'package:flutter/material.dart';
import 'package:hote_v2/core/services/app_services.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/features/auth/login_screen.dart';
import 'package:hote_v2/features/auth/services/social_auth_service.dart';
import 'package:hote_v2/features/auth/widgets/social_auth_buttons.dart';
import 'package:hote_v2/features/shell/main_shell_screen.dart';
import 'package:hote_v2/shared/components/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  bool _isSocialLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onCreateAccountPressed() async {
    setState(() => _isSubmitting = true);

    try {
      final result = await AppServices.auth.signUpWithEmail(
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) {
        return;
      }

      if (result.requiresEmailConfirmation) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Check your email to confirm your account, then log in.'),
          ),
        );
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
        return;
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        MainShellScreen.routeName,
        (Route<dynamic> route) => false,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      final String message = error
          .toString()
          .replaceFirst('AuthException(message: ', '')
          .replaceAll(')', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _goToLogin() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  Future<void> _handleSocialSignIn({
    required String provider,
    required Future<String?> Function() signIn,
  }) async {
    setState(() => _isSocialLoading = true);

    try {
      final String? identity = await signIn();
      if (!mounted) {
        return;
      }

      if (identity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$provider sign-in was cancelled.')),
        );
        return;
      }

      final String label = identity.trim().isEmpty ? provider : identity;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in with $label')),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        MainShellScreen.routeName,
        (Route<dynamic> route) => false,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$provider sign-in failed. Please check provider setup and try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSocialLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    await _handleSocialSignIn(
      provider: 'Google',
      signIn: SocialAuthService.signInWithGoogle,
    );
  }

  Future<void> _signInWithFacebook() async {
    await _handleSocialSignIn(
      provider: 'Facebook',
      signIn: SocialAuthService.signInWithFacebook,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                      onPressed: _goToLogin,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Create your account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Set up your details once and start booking hotels across Cambodia in minutes.',
                      style: TextStyle(
                        color: Color(0xFFFDE9DE),
                        fontSize: 15,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(34),
                      topRight: Radius.circular(34),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Fill in the details below to create your account.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const _FieldLabel('Full name'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'Enter your full name',
                          ),
                        ),
                        const SizedBox(height: 18),
                        const _FieldLabel('Phone number'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'Enter your phone number',
                          ),
                        ),
                        const SizedBox(height: 18),
                        const _FieldLabel('Email'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'Enter your email',
                          ),
                        ),
                        const SizedBox(height: 18),
                        const _FieldLabel('Password'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Create a password',
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          label: _isSubmitting
                              ? 'Creating account...'
                              : 'Create Account',
                          onPressed:
                              _isSubmitting ? null : _onCreateAccountPressed,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              'Already have an account?',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextButton(
                              onPressed: _goToLogin,
                              child: const Text('Login'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        SocialAuthButtons(
                          isLoading: _isSocialLoading,
                          onGooglePressed: _signInWithGoogle,
                          onFacebookPressed: _signInWithFacebook,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }
}
