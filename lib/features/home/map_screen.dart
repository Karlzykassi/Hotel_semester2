import 'package:flutter/material.dart';
import 'package:hote_v2/core/constants/app_assets.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  static const routeName = '/map';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Location', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(AppAssets.mapPreview, width: double.infinity, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
