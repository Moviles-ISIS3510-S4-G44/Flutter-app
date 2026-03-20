class ListingDetail {
  final String id;
  final String sellerId;
  final String categoryId;
  final String title;
  final String description;
  final String price;
  final String condition;
  final List<String> images;
  final String status;
  final String location;

  const ListingDetail({
    required this.id,
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
}