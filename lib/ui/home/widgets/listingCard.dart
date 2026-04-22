import 'package:flutter/material.dart';
import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';

class ListingCard extends StatelessWidget {
  final ListingSummary listing;
  final bool showFeaturedBadge;
  final VoidCallback? onTap;

  const ListingCard({
    super.key,
    required this.listing,
    this.showFeaturedBadge = false,
    this.onTap,
  });

  String _formatPrice(dynamic price) {
    final value = int.tryParse(price.toString()) ?? 0;
    final text = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final position = text.length - i;
      buffer.write(text[i]);
      if (position > 1 && position % 3 == 1) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      listing.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFF0F0F0),
                          child: const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 32,
                              color: Colors.black38,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (showFeaturedBadge)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4D21F),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Featured',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F1F1F),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.1,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$ ${_formatPrice(listing.price)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1,
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