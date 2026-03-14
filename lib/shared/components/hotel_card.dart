import 'package:flutter/material.dart';
import 'package:hote_v2/data/models/hotel_item.dart';

class HotelCard extends StatelessWidget {
  const HotelCard({
    super.key,
    required this.hotel,
    this.onTap,
    this.showRating = true,
  });

  final HotelItem hotel;
  final VoidCallback? onTap;
  final bool showRating;

  static const double _cardWidth = 360;
  static const double _cardHeight = 180;
  static const List<BoxShadow> _floatingShadow = [
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
  ];

  Widget _buildCardImage() {
    final String? source = hotel.imageUrl;
    if (source == null || source.trim().isEmpty) {
      return Container(color: Color(hotel.imageColor));
    }

    final Uri? uri = Uri.tryParse(source);
    final bool isNetworkImage = uri != null &&
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: _cardWidth,
        height: _cardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x22000000), width: 0.8),
          boxShadow: _floatingShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: Color(hotel.imageColor)),
            _buildCardImage(),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x1A000000),
                    Color(0x22000000),
                    Color(0xA6000000),
                  ],
                ),
              ),
            ),
            if (showRating)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xCC111111),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Color(0xFFFFB800),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        hotel.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFFFB800),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      shadows: [
                        Shadow(color: Color(0xA6000000), blurRadius: 6),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 15,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hotel.city,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            shadows: [
                              Shadow(color: Color(0xA6000000), blurRadius: 6),
                            ],
                          ),
                        ),
                      ),
                    ],
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
