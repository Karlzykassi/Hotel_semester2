import 'package:flutter/material.dart';
import 'package:hote_v2/core/constants/app_assets.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/features/shell/main_shell_screen.dart';
import 'package:hote_v2/shared/components/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  void _goToPage(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _controller,
              onPageChanged: (index) => setState(() => _page = index),
              children: [
                _IntroLogoPage(onSkip: () => _goToPage(2)),
                _IntroIllustrationPage(
                  onSkip: () => _goToPage(2),
                  onBack: () => _goToPage(0),
                ),
                _SignInOptionsPage(onBack: () => _goToPage(1)),
              ],
            ),
            if (_page < 2)
              Positioned(
                right: 24,
                bottom: 44,
                child: InkWell(
                  onTap: () => _goToPage(_page + 1),
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_right_rounded,
                        color: Colors.white, size: 42),
                  ),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final isActive = index == _page;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppTheme.primary
                          : AppTheme.primary.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroLogoPage extends StatelessWidget {
  const _IntroLogoPage({required this.onSkip});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: onSkip,
              child: const Text('Skip',
                  style: TextStyle(fontSize: 16, color: Colors.black87)),
            ),
          ),
          const Spacer(),
          Center(
            child: Column(
              children: [
                Image.asset(AppAssets.logo, width: 200, fit: BoxFit.contain),
                const SizedBox(height: 18),
                const Text(
                  'KHMER HOTEL',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'GOOD OF SERVICE',
                  style: TextStyle(
                    color: Color(0xFFBC7A44),
                    fontSize: 16,
                    letterSpacing: 5,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _IntroIllustrationPage extends StatelessWidget {
  const _IntroIllustrationPage({
    required this.onSkip,
    required this.onBack,
  });

  final VoidCallback onSkip;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              const Spacer(),
              TextButton(
                onPressed: onSkip,
                child: const Text('Skip',
                    style: TextStyle(fontSize: 16, color: Colors.black87)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Image.asset(AppAssets.onboardingIllustration,
                height: 300, fit: BoxFit.contain),
          ),
          const SizedBox(height: 28),
          const Text(
            'You are always in control',
            style: TextStyle(
                color: AppTheme.primary,
                fontSize: 46,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          const Text(
            'If you choose to allow tracking, we will use your activity across other app and websites to personalize the ads you see.',
            style: TextStyle(
                fontSize: 16, color: AppTheme.textPrimary, height: 1.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'You can change this any time in your phone setting.',
            style: TextStyle(fontSize: 16, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _SignInOptionsPage extends StatelessWidget {
  const _SignInOptionsPage({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          const SizedBox(height: 44),
          const Text(
            'Sign in for Access to your Booking Details',
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: 42,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 44),
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Register',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    fontSize: 22,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    fontSize: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          PrimaryButton(label: 'Continue with Google', onPressed: () {}),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Continue with Email',
            onPressed: () {
              Navigator.pushReplacementNamed(
                  context, MainShellScreen.routeName);
            },
          ),
          const SizedBox(height: 12),
          PrimaryButton(label: 'Continue with Facebook', onPressed: () {}),
        ],
      ),
    );
  }
}
