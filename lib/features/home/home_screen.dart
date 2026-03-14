import 'package:flutter/material.dart';
import 'package:hote_v2/core/constants/app_assets.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/data/mock/app_data.dart';
import 'package:hote_v2/data/models/booking_flow_data.dart';
import 'package:hote_v2/data/models/hotel_item.dart';
import 'package:hote_v2/data/models/search_result_item.dart';
import 'package:hote_v2/features/booking/hotel_details_screen.dart';
import 'package:hote_v2/features/booking/reservation_form_screen.dart';
import 'package:hote_v2/features/search/search_results_screen.dart';
import 'package:hote_v2/shared/components/destination_card.dart';
import 'package:hote_v2/shared/components/hotel_card.dart';
import 'package:hote_v2/shared/components/kh_search_bar.dart';
import 'package:hote_v2/shared/components/section_title.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onSearchTap});

  static const _headerRadius = Radius.circular(28);
  final VoidCallback? onSearchTap;

  BookingFlowData _bookingFlowFromHotel(HotelItem hotel) {
    return BookingFlowData.fromResult(
      SearchResultItem(
        name: hotel.name,
        city: hotel.city,
        rating: hotel.rating,
        price: 300,
        imageColor: hotel.imageColor,
        imageUrl: hotel.imageUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildTopHeader()),
            SliverPersistentHeader(
              pinned: true,
              delegate: _FixedHeaderDelegate(
                height: 76,
                child: _buildHelloHeader(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: KhSearchBar(
                        hint: 'Phnom Penh',
                        onTap: onSearchTap,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: SectionTitle(title: 'Popular Hotel'),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 192,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        itemBuilder: (context, index) {
                          final hotel = AppData.popularHotels[index];
                          return HotelCard(
                            hotel: hotel,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => HotelDetailsScreen(
                                  bookingFlow: _bookingFlowFromHotel(hotel),
                                ),
                              ),
                            ),
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
                      height: 192,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        itemBuilder: (context, index) {
                          final destination = AppData.destinations[index];
                          return DestinationCard(
                            city: destination.name,
                            properties: destination.properties,
                            color: Color(destination.imageColor),
                            imageUrl: destination.imageUrl,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => SearchResultsScreen(
                                  initialCity: destination.name,
                                ),
                              ),
                            ),
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
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x24000000),
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Color(0x12000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Be ready for Black Friday',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Promotions, deals and special offers for your next booking.',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: 150,
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      ReservationFormScreen.routeName,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primary,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(0, 48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Get Offer',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: SizedBox(
                              width: 160,
                              height: 135,
                              child: Image.asset(
                                'assets/offer.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 15, 18, 12),
      color: AppTheme.primary,
      child: Row(
        children: [
          Image.asset(
            AppAssets.logowhite,
            width: 50,
          ),
          const SizedBox(width: 10),
          const Text(
            'KHMER HOTEL',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          const Icon(Icons.notifications, color: Colors.white, size: 30),
          const SizedBox(width: 12),
          const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 30),
        ],
      ),
    );
  }

  Widget _buildHelloHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 0, 10, 0),
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: _headerRadius,
          bottomRight: _headerRadius,
        ),
      ),
      child: const Text(
        'HELLO, Username',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _FixedHeaderDelegate extends SliverPersistentHeaderDelegate {
  _FixedHeaderDelegate({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _FixedHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
