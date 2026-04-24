import 'package:marketplace_flutter_application/data/dtos/listings/create_listing_request.dart';
import 'package:marketplace_flutter_application/models/listings/listing_detail.dart';
import 'package:marketplace_flutter_application/data/dtos/listings/listing_dto.dart';
import 'package:marketplace_flutter_application/data/services/listing_api_service.dart';
import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';

class ListingRepository {
  final ListingApiService _listingApiService;
  // Constructor
  ListingRepository({ListingApiService? listingApiService})
    : _listingApiService = listingApiService ?? ListingApiService();
  // Get all listings
  Future<List<ListingSummary>> getListings() async {
    final listingDtos = await _listingApiService.getListings();
    return listingDtos.map(_toListingSummary).toList();
  }

  // Create a new listing
  Future<ListingDetail> createListing(CreateListingRequest request) async {
    final listingDto = await _listingApiService.createListing(request);
    return _toListingDetail(listingDto);
  }

  // Functions to convert DTOs to domain models
  ListingSummary _toListingSummary(ListingDto dto) {
    return ListingSummary(
      id: dto.id,
      title: dto.title,
      price: dto.price,
      category: dto.categoryId.toString(),
      imageUrl: dto.images.isNotEmpty ? dto.images[0] : '',
    );
  }

  ListingDetail _toListingDetail(ListingDto dto) {
    return ListingDetail(
      id: dto.id,
      sellerId: dto.sellerId,
      categoryId: dto.categoryId,
      title: dto.title,
      description: dto.description,
      price: dto.price,
      condition: dto.condition,
      images: dto.images,
      location: dto.location,
    );
  }
  Future<ListingDetail> getListingById(String listingId) async {
  final listingDto = await _listingApiService.getListingById(listingId);
  return _toListingDetail(listingDto);
}
}
