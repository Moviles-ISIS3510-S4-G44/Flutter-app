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
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
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