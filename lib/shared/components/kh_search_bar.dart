import 'package:flutter/material.dart';
import 'package:hote_v2/core/theme/app_theme.dart';

class KhSearchBar extends StatelessWidget {
  const KhSearchBar({
    super.key,
    required this.hint,
    this.onTap,
    this.controller,
    this.readOnly = false,
    this.onSubmitted,
  });

  final String hint;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final bool readOnly;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.cardShadow,
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly || onTap != null,
        onTap: onTap,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: AppTheme.primary,
                size: 22,
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minHeight: 48,
            minWidth: 56,
          ),
          suffixIcon: const Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(
              Icons.tune_rounded,
              color: AppTheme.textMuted,
              size: 20,
            ),
          ),
          suffixIconConstraints: BoxConstraints(
            minHeight: 42,
            minWidth: 42,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
