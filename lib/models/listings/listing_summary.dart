class ListingSummary {
  final String id;
  final String sellerId;
  final String title;
  final int price;
  final String category;
  final String imageUrl;
  final String? location;

  const ListingSummary({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.location,
  });
}