import 'package:flutter/material.dart';
import 'package:hote_v2/core/constants/app_assets.dart';

class HotelImage extends StatelessWidget {
  const HotelImage({
    super.key,
    required this.source,
    required this.fallbackColor,
    this.fit = BoxFit.cover,
  });

  final String? source;
  final int fallbackColor;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final String trimmed = source?.trim() ?? '';
    if (trimmed.isEmpty) {
      return _fallbackAsset();
    }

    final Uri? uri = Uri.tryParse(trimmed);
    final bool isNetworkImage = uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');

    if (isNetworkImage) {
      return Image.network(
        trimmed,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _fallbackAsset(),
      );
    }

    return Image.asset(
      trimmed,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _fallbackAsset(),
    );
  }

  Widget _fallbackAsset() {
    return DecoratedBox(
      decoration: BoxDecoration(color: Color(fallbackColor)),
      child: Image.asset(
        AppAssets.hotel1,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(color: Color(fallbackColor));
        },
      ),
    );
  }
}
