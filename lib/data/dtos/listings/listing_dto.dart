class ListingDto {
  final String id;
  final String sellerId;
  final String categoryId;
  final String title;
  final String description;
  final int price;
  final String condition;
  final List<String> images;
  final String? location;

  const ListingDto({
    required this.id,
    required this.sellerId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.price,
    required this.condition,
    required this.images,
    this.location,
  });

  factory ListingDto.fromJson(Map<String, dynamic> json) {
    final categoryRaw = json['category_id'];
    final priceRaw = json['price'];
    final imagesRaw = json['images'];

    return ListingDto(
      id: json['id'] as String,
      sellerId: json['seller_id'] as String,
      categoryId: categoryRaw?.toString() ?? '',
      title: json['title'] as String,
      description: json['description'] as String,
      price: priceRaw is int
          ? priceRaw
          : priceRaw is num
              ? priceRaw.toInt()
              : int.tryParse(priceRaw?.toString() ?? '') ?? 0,
      condition: json['condition'] as String,
      images: imagesRaw is List
          ? imagesRaw.map((image) => image.toString()).toList()
          : const <String>[],
      location: json['location']?.toString(),
    );
  }
}