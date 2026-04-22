import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';
import 'package:marketplace_flutter_application/ui/home/widgets/listingCard.dart';

class TopInteractionsSection extends StatelessWidget {
  final List<ListingSummary> listings;
  final Map<String, double> distances;

  const TopInteractionsSection({
    super.key,
    required this.listings,
    this.distances = const {},
  });

  @override
  Widget build(BuildContext context) {
    if (listings.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Based on your activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F1F1F),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 250,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: listings.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final listing = listings[index];
                return SizedBox(
                  width: 190,
                  child: ListingCard(
                    listing: listing,
                    distanceKm: distances[listing.id],
                    onTap: () => context.push('/listing-map/${listing.id}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}