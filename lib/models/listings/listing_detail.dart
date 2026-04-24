class ListingDetail {
  final String id;
  final String sellerId;
  final String categoryId;
  final String title;
  final String description;
  final int price;
  final String condition;
  final List<String> images;
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
    required this.location,
  });
}