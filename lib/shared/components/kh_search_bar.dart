import 'package:flutter/material.dart';

class KhSearchBar extends StatelessWidget {
  const KhSearchBar({
    super.key,
    required this.hint,
    this.onTap,
    this.controller,
    this.readOnly = false,
  });

  final String hint;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly || onTap != null,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
