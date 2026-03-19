class ListingSummary {
  final String id;
  final String title;
  final String price;
  final String category;
  final String imageUrl;
  final double averageRating;

  const ListingSummary({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.averageRating,
  });
}