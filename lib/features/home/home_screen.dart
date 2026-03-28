import 'package:flutter/material.dart';
import 'package:hote_v2/core/constants/app_assets.dart';
import 'package:hote_v2/core/services/app_services.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/data/models/booking_flow_data.dart';
import 'package:hote_v2/data/models/hotel_item.dart';
import 'package:hote_v2/data/models/search_result_item.dart';
import 'package:hote_v2/data/models/user_profile.dart';
import 'package:hote_v2/features/booking/hotel_details_screen.dart';
import 'package:hote_v2/features/booking/reservation_form_screen.dart';
import 'package:hote_v2/features/search/search_results_screen.dart';
import 'package:hote_v2/shared/components/destination_card.dart';
import 'package:hote_v2/shared/components/hotel_card.dart';
import 'package:hote_v2/shared/components/kh_search_bar.dart';
import 'package:hote_v2/shared/components/section_title.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onSearchTap});

  final VoidCallback? onSearchTap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<_HomeScreenData> _homeFuture;

  @override
  void initState() {
    super.initState();
    _homeFuture = _loadHomeData();
  }

  Future<_HomeScreenData> _loadHomeData() async {
    final List<HotelItem> popularHotels =
        await AppServices.hotels.fetchPopularHotels();
    final List<HotelItem> destinations =
        await AppServices.hotels.fetchDestinations();
    final UserProfile profile = await AppServices.profile.fetchProfile();

    return _HomeScreenData(
      popularHotels: popularHotels,
      destinations: destinations,
      greetingName: profile.firstName,
    );
  }

  BookingFlowData _bookingFlowFromHotel(HotelItem hotel) {
    return BookingFlowData.fromResult(
      SearchResultItem(
        id: hotel.id,
        name: hotel.name,
        city: hotel.city,
        province: hotel.province,
        rating: hotel.rating,
        price: hotel.priceFrom ?? 300,
        imageColor: hotel.imageColor,
        imageUrl: hotel.imageUrl,
        address: hotel.address,
        latitude: hotel.latitude,
        longitude: hotel.longitude,
        googleMapsUri: hotel.googleMapsUri,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_HomeScreenData>(
      future: _homeFuture,
      builder: (
        BuildContext context,
        AsyncSnapshot<_HomeScreenData> snapshot,
      ) {
        final _HomeScreenData? data = snapshot.data;
        final List<HotelItem> popularHotels =
            data?.popularHotels ?? const <HotelItem>[];
        final List<HotelItem> destinations =
            data?.destinations ?? const <HotelItem>[];
        final String greetingName = data?.greetingName.isNotEmpty == true
            ? data!.greetingName
            : AppServices.auth.greetingName;

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: _HomeHero(
                    greetingName: greetingName,
                    onSearchTap: widget.onSearchTap,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 140),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SectionTitle(
                          title: 'Popular Hotels',
                          trailing: popularHotels.isEmpty
                              ? null
                              : '${popularHotels.length} stays',
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 230,
                          child: popularHotels.isEmpty
                              ? const Center(child: CircularProgressIndicator())
                              : ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final HotelItem hotel =
                                        popularHotels[index];
                                    return HotelCard(
                                      hotel: hotel,
                                      onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => HotelDetailsScreen(
                                            bookingFlow:
                                                _bookingFlowFromHotel(hotel),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 14),
                                  itemCount: popularHotels.length,
                                ),
                        ),
                        const SizedBox(height: 24),
                        SectionTitle(
                          title: 'Destinations',
                          trailing: destinations.isEmpty
                              ? null
                              : '${destinations.length} provinces',
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 230,
                          child: destinations.isEmpty
                              ? const Center(child: CircularProgressIndicator())
                              : ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final HotelItem destination =
                                        destinations[index];
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
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 14),
                                  itemCount: destinations.length,
                                ),
                        ),
                        const SizedBox(height: 24),
                        const SectionTitle(title: 'Special Offer'),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                Color(0xFFFFE7D2),
                                Color(0xFFFFC58B),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.75),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: const Text(
                                        'Limited offer',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Get ready for your next escape.',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 24,
                                        color: AppTheme.textPrimary,
                                        height: 1.05,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Explore seasonal deals, premium stays, and flexible booking options across Cambodia.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 1.4,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
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
                                          minimumSize: const Size(0, 50),
                                        ),
                                        child: const Text('Book Offer'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: SizedBox(
                                  width: 180,
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
      },
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({
    required this.greetingName,
    required this.onSearchTap,
  });

  final String greetingName;
  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
      decoration: const BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Image.asset(
                  AppAssets.logowhite,
                  width: 35,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Khmer Hotel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const _HeroAction(icon: Icons.notifications_none_rounded),
              const SizedBox(width: 10),
              const _HeroAction(icon: Icons.chat_bubble_outline_rounded),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Hello, $greetingName',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Find a stay that feels curated, calm, and ready for your next trip.',
            style: TextStyle(
              color: Color(0xFFFDE9DE),
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          KhSearchBar(
            hint: 'Search province in Cambodia',
            onTap: onSearchTap,
          ),
        ],
      ),
    );
  }
}

class _HeroAction extends StatelessWidget {
  const _HeroAction({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: Colors.white, size: 25),
    );
  }
}

class _HomeScreenData {
  const _HomeScreenData({
    required this.popularHotels,
    required this.destinations,
    required this.greetingName,
  });

  final List<HotelItem> popularHotels;
  final List<HotelItem> destinations;
  final String greetingName;
}
