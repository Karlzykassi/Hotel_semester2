import 'package:flutter/material.dart';
import 'package:hote_v2/core/constants/app_assets.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/data/models/booking_flow_data.dart';
import 'package:hote_v2/data/models/search_result_item.dart';
import 'package:hote_v2/features/booking/booking_date_screen.dart';
import 'package:hote_v2/features/home/map_screen.dart';
import 'package:hote_v2/shared/components/primary_button.dart';

class HotelDetailsScreen extends StatelessWidget {
  const HotelDetailsScreen({
    super.key,
    required this.bookingFlow,
  });

  final BookingFlowData bookingFlow;

  @override
  Widget build(BuildContext context) {
    final hotel = bookingFlow.hotel;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailImageSection(hotel: hotel),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hotel.name,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 18,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${hotel.city}, Cambodia',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 10),
                          const Text(
                            'Details',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _hotelDescription(hotel.name),
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1.45,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Facilities',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 1,
                            crossAxisSpacing: 50,
                            childAspectRatio: 1.12,
                            children: [
                              _FacilityItem(
                                icon: Icons.pool_outlined,
                                label: 'Swimming Pool',
                              ),
                              _FacilityItem(
                                icon: Icons.star_border_rounded,
                                label: '5-Star Rating',
                              ),
                              _FacilityItem(
                                icon: Icons.fitness_center_rounded,
                                label: 'Family Gym',
                              ),
                              _FacilityItem(
                                icon: Icons.room_service_outlined,
                                label: '24h Service',
                              ),
                              _FacilityItem(
                                icon: Icons.restaurant_outlined,
                                label: 'Good Food',
                              ),
                              _FacilityItem(
                                icon: Icons.local_bar_outlined,
                                label: 'Sky Bar',
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Location',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      MapScreen(bookingFlow: bookingFlow),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(18),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.asset(
                                AppAssets.mapPreview,
                                height: 200,
                                width: double.infinity,
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
            Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 16,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: AppTheme.textPrimary),
                        children: [
                          TextSpan(
                            text: '\$${hotel.price}',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                          const TextSpan(
                            text: '/night',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Booking Now',
                      height: 52,
                      radius: 28,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => BookingDateScreen(
                              bookingFlow: bookingFlow,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _hotelDescription(String hotelName) {
    return '$hotelName offers stylish rooms, a skyline lounge, and warm Khmer hospitality. Enjoy modern comforts, an outdoor pool, local dining, and a relaxing stay close to the city highlights.';
  }
}

class _DetailImageSection extends StatelessWidget {
  const _DetailImageSection({required this.hotel});

  final SearchResultItem hotel;

  Widget _buildImage() {
    final source = hotel.imageUrl;
    if (source == null || source.trim().isEmpty) {
      return Container(color: Color(hotel.imageColor));
    }

    final uri = Uri.tryParse(source);
    final isNetworkImage = uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');

    if (isNetworkImage) {
      return Image.network(
        source,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(color: Color(hotel.imageColor));
        },
      );
    }

    return Image.asset(
      source,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(color: Color(hotel.imageColor));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      child: Stack(
        children: [
          SizedBox(
            height: 260,
            width: double.infinity,
            child: _buildImage(),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x22000000),
                    Color(0x00000000),
                    Color(0x1A000000),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 14,
            left: 14,
            child: _CircleIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          const Positioned(
            top: 14,
            right: 54,
            child: _CircleIconButton(
              icon: Icons.bookmark_border_rounded,
            ),
          ),
          const Positioned(
            top: 14,
            right: 14,
            child: _CircleIconButton(
              icon: Icons.more_horiz_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x30FFFFFF),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _FacilityItem extends StatelessWidget {
  const _FacilityItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppTheme.primary, size: 40),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
