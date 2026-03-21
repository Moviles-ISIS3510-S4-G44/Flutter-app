import 'package:flutter/material.dart';
import 'package:marketplace_flutter_application/models/listings/listing_detail.dart';

class MapListingPreviewCard extends StatelessWidget {
  final ListingDetail listing;
  final VoidCallback? onTap;

  const MapListingPreviewCard({
    super.key,
    required this.listing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = listing.images.isNotEmpty ? listing.images.first : '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                blurRadius: 14,
                offset: Offset(0, 6),
                color: Color(0x14000000),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PreviewImage(imageUrl: imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: _PreviewInfo(listing: listing),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewImage extends StatelessWidget {
  final String imageUrl;

  const _PreviewImage({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 88,
        height: 88,
        child: imageUrl.isEmpty
            ? Container(
                color: Colors.grey.shade300,
                child: const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 32,
                    color: Colors.black54,
                  ),
                ),
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 32,
                        color: Colors.black54,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _PreviewInfo extends StatelessWidget {
  final ListingDetail listing;

  const _PreviewInfo({
    required this.listing,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            listing.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF1F1F1F),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            listing.sellerId,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6E6E6E),
            ),
          ),
          const Spacer(),
          Text(
            '\$${listing.price}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: Color(0xFF1F1F1F),
            ),
          ),
        ],
      ),
    );
  }
}