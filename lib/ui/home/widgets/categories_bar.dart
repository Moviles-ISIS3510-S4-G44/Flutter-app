import 'package:flutter/material.dart';

class CategoriesBar extends StatefulWidget {
  const CategoriesBar({super.key});

  @override
  State<CategoriesBar> createState() => _CategoriesBarState();
}

class _CategoriesBarState extends State<CategoriesBar> {
  //Por ahora, porque no tengo backend, pero luego esto vendrá de la API
  final List<String> _categories = [
    'Books',
    'Electronics',
    'Furniture',
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final bool isSelected = index == _selectedIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFF3E7B3) 
                    : const Color(0xFFEDEDED), 
                borderRadius: BorderRadius.circular(999),
              ),
              child: Center(
                child: Text(
                  _categories[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: const Color(0xFF1F1F1F),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}