class ListingSummary {
  final String id;
  final String title;
  final String price;
  final String category;
  final String imageUrl;
  final double averageRating;
  final double? latitude;
  final double? longitude;

  const ListingSummary({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.averageRating = 0.0,
    this.latitude,
    this.longitude,
  });

  factory ListingSummary.fromJson(Map<String, dynamic> json) {
    return ListingSummary(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      price: json['price']?.toString() ?? '\$0',
      category: json['category_id'] as String? ?? 'General',
      imageUrl: json['image_url'] as String? ?? 'https://via.placeholder.com/150',
      averageRating: json['average_rating'] != null
          ? (json['average_rating'] as num).toDouble()
          : 0.0,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
    );
  }
}