class FavoriteListing {
  final String id;
  final String title;
  final int price;
  final String imageUrl;
  final String category;
  final String? location;

  const FavoriteListing({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.location,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'price': price,
        'imageUrl': imageUrl,
        'category': category,
        'location': location,
      };

  factory FavoriteListing.fromMap(Map<String, dynamic> map) => FavoriteListing(
        id: map['id'] as String,
        title: map['title'] as String,
        price: map['price'] as int,
        imageUrl: map['imageUrl'] as String,
        category: map['category'] as String,
        location: map['location'] as String?,
      );
}