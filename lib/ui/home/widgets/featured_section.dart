import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';
import 'package:marketplace_flutter_application/ui/home/widgets/listingCard.dart';

class FeaturedSection extends StatelessWidget {
  final List<ListingSummary> listings;
  final Map<String, double> distances;

  const FeaturedSection({
    super.key,
    required this.listings,
    this.distances = const {},
  });

  @override
  Widget build(BuildContext context) {
    if (listings.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Featured',
            style:  TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: Color(0xFF1F1F1F),
            ),
          ),
<<<<<<< HEAD
          const SizedBox(height: 10),
          SizedBox(
            height: 230,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: listings.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final listing = listings[index];

                return SizedBox(
                  width: 160,
                  child: ListingCard(
                    listing: listing,
                    showFeaturedBadge: true,
                    onTap: () {
                      context.push('/listing-map/${listing.id}');
                    },
                  ),
                );
              },
            ),
=======
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: listings.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final listing = listings[index];
              return SizedBox(
                width: 170,
                child: ListingCard(
                  listing: listing,
                  showFeaturedBadge: true,
                  distanceKm: distances[listing.id],
                  onTap: () => context.push('/listing-map/${listing.id}'),
                ),
              );
            },
>>>>>>> 9debd14 (add distance to feature)
          ),
        ],
      ),
    );
  }
}