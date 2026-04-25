import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:marketplace_flutter_application/ui/cart/cart_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/shared/widgets/app_bottom_nav_bar.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  static const Color background = Color(0xFFEEF2F7);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6E6E6E);
  static const Color borderColor = Color(0xFFE5E7EB);

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/Home');
        break;
      case 1:
        context.go('/Sell');
        break;
      case 2:
        break; // ya estamos en cart
      case 3:
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  String _formatPrice(int price) {
    final text = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final position = text.length - i;
      buffer.write(text[i]);
      if (position > 1 && position % 3 == 1) buffer.write('.');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartViewModel>();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'My Cart',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, cart),
              child: const Text(
                'Clear all',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? _EmptyState()
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      final listing = item.listing;
                      return _CartItemTile(
                        imageUrl: listing.images.isNotEmpty
                            ? listing.images.first
                            : '',
                        title: listing.title,
                        price: _formatPrice(listing.price),
                        condition: listing.condition,
                        onTap: () =>
                            context.push('/listing/${listing.id}'),
                        onRemove: () => cart.remove(listing.id),
                      );
                    },
                  ),
                ),
                _CartSummary(
                  itemCount: cart.count,
                  total: _formatPrice(cart.totalPrice),
                ),
              ],
            ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 2,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }

  void _confirmClear(BuildContext context, CartViewModel cart) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Clear cart'),
        content: const Text(
            'Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              cart.clear();
              Navigator.of(ctx).pop();
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

// Empty state

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add listings you want to buy later.',
            style: TextStyle(fontSize: 14, color: Color(0xFF6E6E6E)),
          ),
        ],
      ),
    );
  }
}

// Cart item tile

class _CartItemTile extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final String condition;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.condition,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Imagen
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFF0F0F0),
                      child: const Center(
                        child: Icon(Icons.image_outlined,
                            size: 28, color: Colors.black38),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        condition,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6E6E6E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$ $price',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),
              // Botón quitar
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
                color: Colors.redAccent,
                tooltip: 'Remove',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Cart summary 

class _CartSummary extends StatelessWidget {
  final int itemCount;
  final String total;

  const _CartSummary({required this.itemCount, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6E6E6E),
                ),
              ),
              Text(
                '\$ $total',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Checkout próximamente'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3483FA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Checkout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}