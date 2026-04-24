import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        _SectionTextField(
          hintText: 'Title',
          onChanged: viewModel.updateTitle,
          textCapitalization: TextCapitalization.sentences,
          maxLength: 80,
          errorText: viewModel.titleError,
        ),
        const SizedBox(height: 16),
        _SectionTextField(
          hintText: '\$ Price',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: viewModel.updatePrice,
          maxLength: 10,
          errorText: viewModel.priceError,
        ),
        const SizedBox(height: 16),
        _CategoryDropdownField(viewModel: viewModel),
        if (viewModel.categoryError != null)
          _FieldError(viewModel.categoryError!),
      ],
    );
  }
}

// Text field

class _SectionTextField extends StatelessWidget {
  final String hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final int? maxLength;
  final String? errorText;

  const _SectionTextField({
    required this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.maxLength,
    this.errorText,
  });

  static const _errorRed = Color(0xFFD32F2F);
  static const _errorRedLight = Color(0xFFFFEBEE);

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          maxLength: maxLength,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF1F1F1F),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            counterText: '',
            hintStyle: const TextStyle(
              fontSize: 15,
              color: Color(0xFF9AA4B2),
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: hasError ? _errorRedLight : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: hasError ? _errorRed : const Color(0xFFD6DCE5),
                width: 1.4,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: hasError ? _errorRed : const Color(0xFFD6DCE5),
                width: 1.4,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: hasError ? _errorRed : const Color(0xFFF3D13B),
                width: 1.8,
              ),
            ),
          ),
        ),
        if (hasError) _FieldError(errorText!),
      ],
    );
  }
}

// Category dropdown 

class _CategoryDropdownField extends StatelessWidget {
  final CreateListingViewModel viewModel;

  const _CategoryDropdownField({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoadingCategories) {
      return _buildContainer(
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Cargando categorías...',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    if (viewModel.categoriesErrorMessage != null) {
      return _buildContainer(
        child: Row(
          children: [
            const Icon(Icons.error_outline, size: 18, color: Colors.redAccent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                viewModel.categoriesErrorMessage!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.white),
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
          hintText: 'Selecciona una categoría',
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
            borderSide: const BorderSide(color: Color(0xFFD6DCE5), width: 1.4),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFD6DCE5), width: 1.4),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFF3D13B), width: 1.8),
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
        border: Border.all(color: const Color(0xFFD6DCE5), width: 1.4),
      ),
      child: child,
    );
  }
}

// Shared field error widget 

class _FieldError extends StatelessWidget {
  final String message;
  const _FieldError(this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 14, color: Color(0xFFD32F2F)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFD32F2F),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}