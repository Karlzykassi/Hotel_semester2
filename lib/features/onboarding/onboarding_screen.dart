import 'package:flutter/material.dart';
import 'package:hote_v2/core/constants/app_assets.dart';
import 'package:hote_v2/core/theme/app_theme.dart';

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
                _IntroIllustrationPageThree(
                  onSkip: () => _goToPage(2),
                  onBack: () => _goToPage(1),
                ),
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
                    width: 100,
                    height: 62,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 50,
                    ),
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
                  style: TextStyle(
                      fontSize: 20, color: Color.fromARGB(255, 116, 114, 114))),
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
          const SizedBox(height: 16),
          Center(
            child: Image.asset(AppAssets.onboardingIllustration2,
                fit: BoxFit.contain),
          ),
          const SizedBox(height: 28),
          const Text(
            'You are always in control',
            style: TextStyle(
                color: AppTheme.primary,
                fontSize: 36,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          const Text(
            'If you choose to allow tracking, we will use your activity across other app and websites to personalize the ads you see.',
            style: TextStyle(
                fontSize: 18, color: AppTheme.textPrimary, height: 1.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'You can change this any time in your phone setting.',
            style: TextStyle(fontSize: 18, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _IntroIllustrationPageThree extends StatelessWidget {
  const _IntroIllustrationPageThree({
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
          const SizedBox(height: 16),
          Center(
            child: Image.asset(AppAssets.onboardingIllustration3,
                fit: BoxFit.contain, width: double.infinity),
          ),
          const SizedBox(height: 28),
          const Text(
            'You are always in control',
            style: TextStyle(
                color: AppTheme.primary,
                fontSize: 36,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          const Text(
            'If you choose to allow tracking, we will use your activity across other app and websites to personalize the ads you see.',
            style: TextStyle(
                fontSize: 18, color: AppTheme.textPrimary, height: 1.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'You can change this any time in your phone setting.',
            style: TextStyle(fontSize: 18, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}
