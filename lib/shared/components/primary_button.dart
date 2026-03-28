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
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double fontSize;
  final double radius;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool canExpand = expand && constraints.hasBoundedWidth;
        final bool isEnabled = onPressed != null;

        return SizedBox(
          width: canExpand ? double.infinity : null,
          height: height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: isEnabled ? AppTheme.primaryGradient : null,
              color: isEnabled ? null : AppTheme.surfaceMuted,
              borderRadius: BorderRadius.circular(radius),
              boxShadow:
                  isEnabled ? AppTheme.buttonShadow : const <BoxShadow>[],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(radius),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: fontSize,
                      color: isEnabled ? Colors.white : AppTheme.textMuted,
                      letterSpacing: 0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
