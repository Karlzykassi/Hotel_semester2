import 'package:flutter/material.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/features/booking/booking_screen.dart';
import 'package:hote_v2/features/home/home_screen.dart';
import 'package:hote_v2/features/profile/profile_screen.dart';
import 'package:hote_v2/features/search/search_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({
    super.key,
    this.initialIndex = 0,
  });

  static const routeName = '/shell';
  final int initialIndex;

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _index;

  List<Widget> get _screens => <Widget>[
        HomeScreen(onSearchTap: _openSearch),
        const SearchScreen(),
        const BookingScreen(),
        const ProfileScreen(),
      ];

  void _openSearch() {
    setState(() => _index = 1);
  }

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        height: 92,
        decoration: const BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomItem(
                icon: Icons.home_outlined,
                label: 'Home',
                selected: _index == 0,
                onTap: () => setState(() => _index = 0)),
            _BottomItem(
                icon: Icons.search_rounded,
                label: 'Search',
                selected: _index == 1,
                onTap: () => setState(() => _index = 1)),
            _BottomItem(
                icon: Icons.wallet_membership_outlined,
                label: 'Booking',
                selected: _index == 2,
                onTap: () => setState(() => _index = 2)),
            _BottomItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                selected: _index == 3,
                onTap: () => setState(() => _index = 3)),
          ],
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: selected ? 35 : 30),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
