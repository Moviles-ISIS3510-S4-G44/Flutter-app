import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marketplace_flutter_application/ui/home/home_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/home/widgets/categories_bar.dart';

class HomeHeader extends StatelessWidget {
  final bool isOnline;

  const HomeHeader({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<HomeViewModel>();

    return Container(
      width: double.infinity,
      color: const Color(0xFFFFE600),
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: TextField(
                    enabled: isOnline,
                    onChanged: viewModel.updateSearchQuery,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1F1F1F),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Buscar productos...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9E9E9E),
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 14, right: 10),
                        child: Icon(
                          Icons.search,
                          size: 22,
                          color: Color(0xFF666666),
                        ),
                      ),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 46,
                        minHeight: 44,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.notifications_none_rounded,
                size: 28,
                color: Color(0xFF1F1F1F),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Consumer<HomeViewModel>(
            builder: (context, vm, _) => CategoriesBar(
              categories: vm.categories,
              selectedCategory: vm.selectedCategory,
              onCategorySelected: vm.updateSelectedCategory,
            ),
          ),
        ],
      ),
    );
  }
}