class AppColorSeed {
  AppColorSeed._();

  static const List<int> _palette = <int>[
    0xFF5E8B7E,
    0xFF7A89C2,
    0xFFA1826F,
    0xFF6F8AC7,
    0xFFC08A58,
    0xFF6F9B88,
    0xFF9677A9,
    0xFFC5AE95,
    0xFFD8C1A1,
    0xFFB8B094,
    0xFF7E9E8C,
    0xFF799B6C,
  ];

  static int fromText(String input) {
    if (input.trim().isEmpty) {
      return _palette.first;
    }

    final int hash = input.runes.fold<int>(
      0,
      (int previousValue, int rune) => previousValue + rune,
    );
    return _palette[hash % _palette.length];
  }
}
