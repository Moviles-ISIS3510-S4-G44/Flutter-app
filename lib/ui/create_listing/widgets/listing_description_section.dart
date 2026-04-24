import 'package:flutter/material.dart';
import 'package:marketplace_flutter_application/ui/create_listing/create_listing_viewmodel.dart';
import 'package:provider/provider.dart';

class ListingDescriptionSection extends StatelessWidget {
  const ListingDescriptionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreateListingViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Item Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F1F1F),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Write at least 10 characters.',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          maxLines: 6,
          onChanged: viewModel.updateDescription,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF1F1F1F),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText:
                'Describe your item, its condition, and any important details...',
            hintStyle: const TextStyle(
              fontSize: 15,
              color: Color(0xFF9AA4B2),
              fontWeight: FontWeight.w400,
            ),
            errorText: viewModel.descriptionError,
            errorMaxLines: 2,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFD6DCE5),
                width: 1.4,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFD6DCE5),
                width: 1.4,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFF3D13B),
                width: 1.8,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFD32F2F),
                width: 1.4,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFD32F2F),
                width: 1.8,
              ),
            ),
          ),
        ),
      ],
    );
  }
}