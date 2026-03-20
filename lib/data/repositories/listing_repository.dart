import 'package:marketplace_flutter_application/data/dtos/listing_dto.dart';
import 'package:marketplace_flutter_application/data/services/listing_api_service.dart';
import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';

class ListingRepository {
  final ListingApiService _listingApiService;

  ListingRepository({
    ListingApiService? listingApiService,
  }) : _listingApiService = listingApiService ?? ListingApiService();

  Future<List<ListingSummary>> getListings() async {
    final listingDtos = await _listingApiService.getListings();
    return listingDtos.map(_toListingSummary).toList();
  }

  ListingSummary _toListingSummary(ListingDto dto) {
    return ListingSummary(
      id: dto.id,
      title: dto.title,
      price: dto.price.toString(),
      category: dto.categoryId.toString(),
      imageUrl: dto.images.isNotEmpty ? dto.images[0] : '',
    );
  }
}