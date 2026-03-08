import 'package:flutter/material.dart';
import 'package:hote_v2/core/constants/app_assets.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/data/mock/app_data.dart';
import 'package:hote_v2/features/booking/reservation_form_screen.dart';
import 'package:hote_v2/features/home/map_screen.dart';
import 'package:hote_v2/shared/components/destination_card.dart';
import 'package:hote_v2/shared/components/hotel_card.dart';
import 'package:hote_v2/shared/components/kh_search_bar.dart';
import 'package:hote_v2/shared/components/primary_button.dart';
import 'package:hote_v2/shared/components/section_title.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 18),
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(AppAssets.logo, width: 38, height: 38),
                      const SizedBox(width: 10),
                      const Text(
                        'KHMER HOTEL',
                        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      const Icon(Icons.notifications, color: Colors.white),
                      const SizedBox(width: 12),
                      const Icon(Icons.chat_bubble_outline, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'HELLO, Eom Seong-hyeon',
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: KhSearchBar(
                hint: 'Phnom Penh',
                onTap: () {
                  Navigator.pushNamed(context, MapScreen.routeName);
                },
              ),
            ),
            const SizedBox(height: 14),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: SectionTitle(title: 'Popular Hotel'),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 228,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemBuilder: (context, index) {
                  final hotel = AppData.popularHotels[index];
                  return HotelCard(
                    hotel: hotel,
                    onTap: () => Navigator.pushNamed(context, ReservationFormScreen.routeName),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: AppData.popularHotels.length,
              ),
            ),
            const SizedBox(height: 14),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: SectionTitle(title: 'All Destinations'),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemBuilder: (context, index) {
                  final destination = AppData.destinations[index];
                  return DestinationCard(
                    city: destination.name,
                    properties: destination.properties,
                    color: Color(destination.imageColor),
                    onTap: () => Navigator.pushNamed(context, ReservationFormScreen.routeName),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: AppData.destinations.length,
              ),
            ),
            const SizedBox(height: 18),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: SectionTitle(title: 'Offers'),
            ),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB171),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.primary),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Be ready for Black Friday and more',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Promotions, deals and special offers for your next booking.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    label: 'Get Offer',
                    onPressed: () => Navigator.pushNamed(context, ReservationFormScreen.routeName),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
