import 'package:flutter/material.dart';

class DestinationCard extends StatelessWidget {
  const DestinationCard({
    super.key,
    required this.city,
    required this.properties,
    required this.color,
    this.imageUrl,
    this.onTap,
  });

  final String city;
  final int properties;
  final Color color;
  final String? imageUrl;
  final VoidCallback? onTap;

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
    final String? source = imageUrl;
    if (source == null || source.trim().isEmpty) {
      return Container(color: color);
    }

    final Uri? uri = Uri.tryParse(source);
    final bool isNetworkImage = uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');

    if (isNetworkImage) {
      return Image.network(
        source,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(color: color),
      );
    }

    return Image.asset(
      source,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(color: color),
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
            Container(color: color),
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
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    city,
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
                  Text(
                    '$properties Properties',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(color: Color(0xA6000000), blurRadius: 6),
                      ],
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
}
