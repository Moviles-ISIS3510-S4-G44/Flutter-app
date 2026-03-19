import 'package:flutter/material.dart';

class AppBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onTap;

  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      color: const Color(0xFFFFF0B8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NavItem(
            icon: Icons.home,
            label: 'Home',
            isSelected: selectedIndex == 0,
            onTap: () => onTap?.call(0),
          ),
          _NavItem(
            icon: Icons.search,
            label: 'Search',
            isSelected: selectedIndex == 1,
            onTap: () => onTap?.call(1),
          ),
          _NavItem(
            icon: Icons.add,
            label: 'List',
            isSelected: selectedIndex == 2,
            onTap: () => onTap?.call(2),
            isCenter: true,
          ),
          _NavItem(
            icon: Icons.chat_bubble_outline,
            label: 'Inbox',
            isSelected: selectedIndex == 3,
            onTap: () => onTap?.call(3),
          ),
          _NavItem(
            icon: Icons.person_outline,
            label: 'Profile',
            isSelected: selectedIndex == 4,
            onTap: () => onTap?.call(4),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isCenter;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.onTap,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCenter)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFFD700),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                size: 22,
                color: Color(0xFF1F1F1F),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFF3E39A) : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                icon,
                size: 22,
                color: const Color(0xFF1F1F1F),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F1F1F),
            ),
          ),
        ],
      ),
    );
  }
}
