import 'package:flutter/material.dart';

class ListingImagePickerSection extends StatelessWidget {
  const ListingImagePickerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              'Photos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F1F1F),
              ),
            ),
            Spacer(),
            Text(
              '0 / 5 photos',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF7A8594),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            _AddPhotoCard(),
            SizedBox(width: 12),
            _PhotoPreviewCard(),
          ],
        ),
        const SizedBox(height: 10),
        Text(
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
  const _AddPhotoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFB9C2CE),
          width: 2,
          style: BorderStyle.solid,
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
    );
  }
}

class _PhotoPreviewCard extends StatelessWidget {
  const _PhotoPreviewCard();

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
          Center(
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.image_outlined,
                size: 28,
                color: Color(0xFFB0B8C4),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD84D),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 12,
                color: Color(0xFF1F1F1F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}