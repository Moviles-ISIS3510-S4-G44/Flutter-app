import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';

class RecentlyViewedSection extends StatelessWidget {
  final List<ListingSummary> listings;

  const RecentlyViewedSection({
    super.key,
    required this.listings,
  });

  @override
  Widget build(BuildContext context) {
    if (listings.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Recently Viewed',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: Color(0xFF1F1F1F),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 148,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: listings.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final listing = listings[index];
              return _RecentlyViewedCard(
                listing: listing,
                onTap: () => context.push('/listing/${listing.id}'),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecentlyViewedCard extends StatelessWidget {
  final ListingSummary listing;
  final VoidCallback onTap;

  const _RecentlyViewedCard({
    required this.listing,
    required this.onTap,
  });

  String _formatPrice(int price) {
    final text = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final position = text.length - i;
      buffer.write(text[i]);
      if (position > 1 && position % 3 == 1) buffer.write('.');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            SizedBox(
              height: 90,
              width: double.infinity,
              child: Image.network(
                listing.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFF0F0F0),
                  child: const Center(
                    child: Icon(Icons.image_outlined,
                        size: 24, color: Colors.black38),
                  ),
                ),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(7, 5, 7, 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      listing.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$ ${_formatPrice(listing.price)}',
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}