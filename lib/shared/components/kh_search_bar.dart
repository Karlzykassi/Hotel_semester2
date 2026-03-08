import 'package:flutter/material.dart';

class KhSearchBar extends StatelessWidget {
  const KhSearchBar({
    super.key,
    required this.hint,
    this.onTap,
    this.controller,
  });

  final String hint;
  final VoidCallback? onTap;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: onTap != null,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
