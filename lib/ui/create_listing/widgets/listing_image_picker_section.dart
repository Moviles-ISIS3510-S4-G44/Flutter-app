import 'dart:io';

import 'package:flutter/material.dart';
import 'package:marketplace_flutter_application/ui/create_listing/create_listing_viewmodel.dart';
import 'package:provider/provider.dart';

class ListingImagePickerSection extends StatelessWidget {
  const ListingImagePickerSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreateListingViewModel>();
    final images = viewModel.selectedImages;
    final canAddMore = images.length < viewModel.maxImages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Photos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F1F1F),
              ),
            ),
            const Spacer(),
            Text(
              '${images.length} / ${viewModel.maxImages} photos',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF7A8594),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length + (canAddMore ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (canAddMore && index == 0) {
                return _AddPhotoCard(
                  onTap: viewModel.pickImageFromGallery,
                );
              }

              final imageIndex = canAddMore ? index - 1 : index;
              final image = images[imageIndex];

              return _PhotoPreviewCard(
                imagePath: image.path,
                onRemove: () => viewModel.removeImageAt(imageIndex),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Tip: Bright, clear photos help items sell faster.',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Color(0xFF7A8594),
          ),
        ),
      ],
    );
  }
}

class _AddPhotoCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddPhotoCard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 104,
        height: 104,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFB9C2CE),
            width: 2,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              size: 24,
              color: Color(0xFF5F6B7A),
            ),
            SizedBox(height: 8),
            Text(
              'ADD PHOTO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5F6B7A),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoPreviewCard extends StatelessWidget {
  final String imagePath;
  final VoidCallback onRemove;

  const _PhotoPreviewCard({
    required this.imagePath,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD9E0E8),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.file(
              File(imagePath),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD84D),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Color(0xFF1F1F1F),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}