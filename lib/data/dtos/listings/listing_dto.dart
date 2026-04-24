class ListingDto {
  final String id;
  final String sellerId;
  final String categoryId;
  final String title;
  final String description;
  final int price;
  final String condition;
  final List<String> images;
  final String location;

  const ListingDto({
    required this.id,
    required this.sellerId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.price,
    required this.condition,
    required this.images,
    required this.location,
  });

  factory ListingDto.fromJson(Map<String, dynamic> json) {
    return ListingDto(
      id: json['id'] as String,
      sellerId: json['seller_id'] as String,
      categoryId: json['category_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
      condition: json['condition'] as String,
      images: (json['images'] as List<dynamic>)
          .map((image) => image as String)
          .toList(),
      location: json['location'] as String,
    );
  }
}