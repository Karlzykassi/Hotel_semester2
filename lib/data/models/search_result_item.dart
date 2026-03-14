class SearchResultItem {
  const SearchResultItem({
    required this.name,
    required this.city,
    required this.rating,
    required this.price,
    required this.imageColor,
    this.imageUrl,
  });

  final String name;
  final String city;
  final double rating;
  final int price;
  final int imageColor;
  final String? imageUrl;
}
