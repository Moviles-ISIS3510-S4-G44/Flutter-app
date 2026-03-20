import 'package:flutter/material.dart';
import 'package:marketplace_flutter_application/models/categories/category.dart';
import 'package:marketplace_flutter_application/ui/create_listing/create_listing_viewmodel.dart';
import 'package:provider/provider.dart';

class ListingBasicDetailsSection extends StatelessWidget {
  const ListingBasicDetailsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreateListingViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTextField(
          hintText: 'Title (e.g., Organic Chemistry Textbook)',
        ),
        const SizedBox(height: 16),
        const _SectionTextField(
          hintText: '\$ Price',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _CategoryDropdownField(viewModel: viewModel),
      ],
    );
  }
}

class _SectionTextField extends StatelessWidget {
  final String hintText;
  final TextInputType? keyboardType;

  const _SectionTextField({
    required this.hintText,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF1F1F1F),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 15,
          color: Color(0xFF9AA4B2),
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
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
      ),
    );
  }
}

class _CategoryDropdownField extends StatelessWidget {
  final CreateListingViewModel viewModel;

  const _CategoryDropdownField({
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoadingCategories) {
      return _buildContainer(
        child: const Text(
          'Loading categories...',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF9AA4B2),
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    if (viewModel.categoriesErrorMessage != null) {
      return _buildContainer(
        child: const Text(
          'Failed to load categories',
          style: TextStyle(
            fontSize: 15,
            color: Colors.redAccent,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.white,
      ),
      child: DropdownButtonFormField<Category>(
        value: viewModel.selectedCategory,
        isExpanded: true,
        dropdownColor: Colors.white,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 22,
          color: Color(0xFF6B7280),
        ),
        decoration: InputDecoration(
          hintText: 'Select Category',
          hintStyle: const TextStyle(
            fontSize: 15,
            color: Color(0xFF9AA4B2),
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
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
        ),
        items: viewModel.categories.map((category) {
          return DropdownMenuItem<Category>(
            value: category,
            child: Text(
              category.name,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF1F1F1F),
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
        onChanged: viewModel.selectCategory,
      ),
    );
  }

  Widget _buildContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD6DCE5),
          width: 1.4,
        ),
      ),
      child: child,
    );
  }
}