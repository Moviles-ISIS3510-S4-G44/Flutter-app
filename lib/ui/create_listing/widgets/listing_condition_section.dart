import 'package:flutter/material.dart';

class ListingConditionSection extends StatefulWidget {
  const ListingConditionSection({super.key});

  @override
  State<ListingConditionSection> createState() =>
      _ListingConditionSectionState();
}

class _ListingConditionSectionState extends State<ListingConditionSection> {
  final List<String> _conditions = [
    'New',
    'Like New',
    'Used',
  ];

  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Condition',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F1F1F),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _conditions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF3E39A)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFF3E39A)
                          : const Color(0xFFF0F0F0),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _conditions[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF1F1F1F)
                            : const Color.fromARGB(255, 174, 183, 194),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}