import 'package:flutter/material.dart';
import 'package:marketplace_flutter_application/models/listings/listing_detail.dart';

class ListingInfoSection extends StatelessWidget {
  final ListingDetail listing;
  final double? distanceKm;

  const ListingInfoSection({
    super.key,
    required this.listing,
    this.distanceKm,
  });

  String _formatDistance(double km) {
    if (km < 1.0) return '${(km * 1000).round()} m de tu ubicación';
    return '${km.toStringAsFixed(1)} km de tu ubicación';
  }

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
        if (distanceKm != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 4),
              Text(
                _formatDistance(distanceKm!),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

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
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}