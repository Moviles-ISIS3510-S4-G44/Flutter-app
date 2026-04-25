import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:marketplace_flutter_application/ui/cart/cart_viewmodel.dart';

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
    final cartCount = context.watch<CartViewModel>().count;

    return SizedBox(
      height: 72,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE5E5E5),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  _NavItem(
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home,
                    label: 'Home',
                    isSelected: selectedIndex == 0,
                    onTap: () => onTap?.call(0),
                  ),
                  _NavItem(
                    icon: Icons.add_box_outlined,
                    selectedIcon: Icons.add_box,
                    label: 'Sell',
                    isSelected: selectedIndex == 1,
                    onTap: () => onTap?.call(1),
                  ),
                  const Expanded(child: SizedBox()),
                  _NavItem(
                    icon: Icons.chat_bubble_outline,
                    selectedIcon: Icons.chat_bubble,
                    label: 'Messages',
                    isSelected: selectedIndex == 3,
                    onTap: () => onTap?.call(3),
                  ),
                  _NavItem(
                    icon: Icons.person_outline,
                    selectedIcon: Icons.person,
                    label: 'Profile',
                    isSelected: selectedIndex == 4,
                    onTap: () => onTap?.call(4),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -10,
            left: 0,
            right: 0,
            child: Center(
              child: _CenterCartItem(
                isSelected: selectedIndex == 2,
                cartCount: cartCount,
                onTap: () => onTap?.call(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const selectedColor = Color(0xFF3483FA);
    const unselectedColor = Color(0xFF666666);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                size: 22,
                color: isSelected ? selectedColor : unselectedColor,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? selectedColor : unselectedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterCartItem extends StatelessWidget {
  final bool isSelected;
  final int cartCount;
  final VoidCallback? onTap;

  const _CenterCartItem({
    required this.isSelected,
    required this.cartCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const selectedColor = Color(0xFF3483FA);
    const unselectedColor = Color(0xFF666666);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 86,
        height: 82,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              top: 0,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE0E0E0),
                        width: 1.2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(20, 0, 0, 0),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 26,
                      color: isSelected ? selectedColor : unselectedColor,
                    ),
                  ),
                  // Badge contador
                  if (cartCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            cartCount > 99 ? '99+' : '$cartCount',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              bottom: 6,
              child: Text(
                'Cart',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? selectedColor : unselectedColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}