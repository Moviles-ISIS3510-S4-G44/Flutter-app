import 'package:flutter/material.dart';
import 'package:marketplace_flutter_application/ui/create_listing/create_listing_viewmodel.dart';
import 'package:provider/provider.dart';

class ListingConditionSection extends StatelessWidget {
  const ListingConditionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreateListingViewModel>();

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
            itemCount: viewModel.conditions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final condition = viewModel.conditions[index];
              final bool isSelected =
                  condition == viewModel.selectedCondition;

              return GestureDetector(
                onTap: () {
                  viewModel.selectCondition(condition);
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
                      condition,
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