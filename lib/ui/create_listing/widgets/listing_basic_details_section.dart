import 'package:flutter/material.dart';

class ListingBasicDetailsSection extends StatelessWidget {
  const ListingBasicDetailsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _SectionTextField(
          hintText: 'Title (e.g., Organic Chemistry Textbook)',
        ),
        SizedBox(height: 16),
        _SectionTextField(
          hintText: '\$ Price',
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16),
        _CategoryDropdownField(),
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
  const _CategoryDropdownField();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD6DCE5),
          width: 1.4,
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              'Select Category',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF9AA4B2),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 22,
            color: Color(0xFF6B7280),
          ),
        ],
      ),
    );
  }
}