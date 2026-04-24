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
              '${images.length} photos',
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
            itemCount: images.length + 1, // siempre hay botón de agregar
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _AddPhotoCard(
                  onTap: () => _showImageSourceSheet(context, viewModel),
                );
              }

              final image = images[index - 1];

              return _PhotoPreviewCard(
                imagePath: image.path,
                onRemove: () => viewModel.removeImageAt(index - 1),
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

  void _showImageSourceSheet(
    BuildContext context,
    CreateListingViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6DCE5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Add Photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
                const SizedBox(height: 20),
                _ImageSourceOption(
                  icon: Icons.camera_alt_outlined,
                  label: 'Take Photo',
                  onTap: () async {
                    Navigator.of(context).pop();
                    await viewModel.pickImageFromCamera();
                  },
                ),
                const SizedBox(height: 12),
                _ImageSourceOption(
                  icon: Icons.photo_library_outlined,
                  label: 'Choose from Gallery',
                  onTap: () async {
                    Navigator.of(context).pop();
                    await viewModel.pickImageFromGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
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

class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFD6DCE5),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: const Color(0xFF1F1F1F),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F1F1F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}