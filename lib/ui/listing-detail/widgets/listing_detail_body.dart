import 'package:flutter/material.dart';
import 'package:marketplace_flutter_application/models/listings/listing_detail.dart';
import 'package:marketplace_flutter_application/ui/listing-detail/widgets/listing_header_image.dart';
import 'package:marketplace_flutter_application/ui/listing-detail/widgets/listing_info_section.dart';
import 'package:marketplace_flutter_application/ui/listing-detail/widgets/seller_section.dart';

class ListingDetailBody extends StatelessWidget {
  final ListingDetail listing;
  final String? sellerName;
  final String? sellerEmail;
  final bool isLoadingSeller;
  final double? distanceKm;

  const ListingDetailBody({
    super.key,
    required this.listing,
    this.sellerName,
    this.sellerEmail,
    this.isLoadingSeller = false,
    this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListingHeaderImage(
          imageUrl: listing.images.isNotEmpty ? listing.images.first : '',
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListingInfoSection(
                  listing: listing,
                  distanceKm: distanceKm,
                ),
              const SizedBox(height: 24),
              SellerSection(
                sellerName: sellerName,
                sellerEmail: sellerEmail,
                isLoading: isLoadingSeller,
              ),
              const SizedBox(height: 24),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                listing.description,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}