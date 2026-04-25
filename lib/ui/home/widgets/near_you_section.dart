import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';
import 'package:marketplace_flutter_application/ui/home/widgets/listingCard.dart';

class NearYouSection extends StatelessWidget {
  final List<ListingSummary> listings;
  final Map<String, double> distances;

  const NearYouSection({
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
          Row(
            children: [
              const Text(
                'Near You',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  color: Color(0xFF1F1F1F),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE600),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '< 2 km',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
              ),
            ],
          ),
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
                    distanceKm: distances[listing.id],
                    onTap: () => context.push('/listing/${listing.id}'),
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