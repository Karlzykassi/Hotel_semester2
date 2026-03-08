import 'package:flutter/material.dart';
import 'package:hote_v2/core/theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 58,
    this.fontSize = 16,
    this.radius = 30,
  });

  final String label;
  final VoidCallback onPressed;
  final double height;
  final double fontSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          minimumSize: Size.fromHeight(height),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          elevation: 0,
        ),
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: fontSize),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
