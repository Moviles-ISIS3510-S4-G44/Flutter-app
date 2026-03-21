import 'package:flutter/material.dart';
import 'package:marketplace_flutter_application/models/listings/listing_detail.dart';

class ListingInfoSection extends StatelessWidget {
  final ListingDetail listing;

  const ListingInfoSection({
    super.key,
    required this.listing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                listing.title,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            _StatusBadge(status: listing.status),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '\$${listing.price}',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}