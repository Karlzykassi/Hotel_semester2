import 'package:flutter/material.dart';
import 'package:hote_v2/features/onboarding/onboarding_screen.dart';
import 'package:hote_v2/shared/components/primary_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 22),
              const Center(
                child: CircleAvatar(
                  radius: 48,
                  child: Icon(Icons.person_outline_rounded, size: 48),
                ),
              ),
              const SizedBox(height: 14),
              const Center(
                child: Text(
                  'Eom Seong-hyeon',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 28),
              const _InfoTile(title: 'Email', value: 'example@khmerhotel.com', icon: Icons.email_outlined),
              const SizedBox(height: 10),
              const _InfoTile(title: 'Phone', value: '+855 12 345 678', icon: Icons.phone_outlined),
              const SizedBox(height: 10),
              const _InfoTile(title: 'Location', value: 'Phnom Penh, Cambodia', icon: Icons.location_on_outlined),
              const Spacer(),
              PrimaryButton(
                label: 'Logout',
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const OnboardingScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.title, required this.value, required this.icon});

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
