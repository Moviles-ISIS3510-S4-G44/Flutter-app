import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ListingHeaderImage extends StatelessWidget {
  final String imageUrl;

  const ListingHeaderImage({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        height: 320,
        width: double.infinity,
        color: Colors.grey.shade300,
        child: const Icon(
          Icons.image_not_supported_outlined,
          size: 56,
          color: Colors.grey,
        ),
      );
    }

    return SizedBox(
      height: 320,
      width: double.infinity,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        errorWidget: (context, url, error) {
          return Container(
            color: Colors.grey.shade300,
            child: const Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 56,
                color: Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }
}