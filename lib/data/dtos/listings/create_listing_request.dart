class CreateListingRequest {
  final String sellerId;
  final String categoryId;
  final String title;
  final String description;
  final int price;
  final String condition;
  final List<String> images;
  final String status;
  final String location;

  const CreateListingRequest({
    required this.sellerId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.price,
    required this.condition,
    required this.images,
    required this.status,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'seller_id': sellerId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'price': price,
      'condition': condition,
      'images': images,
      'status': status,
      'location': location,
    };
  }
}