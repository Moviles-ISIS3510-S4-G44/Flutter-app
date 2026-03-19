import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marketplace_flutter_application/ui/product/product_viewmodel.dart';

class ProductDetailView extends StatefulWidget {
  final String productId;
  const ProductDetailView({super.key, required this.productId});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProductViewModel>().loadProduct(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEF2F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F1F1F)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Product',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F1F1F),
          ),
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.product == null
              ? const Center(child: Text('Product not found'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (vm.product!.imageUrl.isNotEmpty)
                        Image.network(
                          vm.product!.imageUrl,
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 300,
                            color: Colors.grey[200],
                            child: const Center(child: Icon(Icons.image_not_supported, size: 64)),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vm.product!.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1F1F1F),
                                fontFamily: 'PlusJakartaSans',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              vm.product!.price,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Color(0xFF6A5A00),
                                fontWeight: FontWeight.w700,
                                fontFamily: 'PlusJakartaSans',
                              ),
                            ),
                            const SizedBox(height: 12),
                            // category chip
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3E39A),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                vm.product!.category,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F1F1F),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // rating
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 18, color: Color(0xFFF4D21F)),
                                const SizedBox(width: 4),
                                Text(
                                  vm.product!.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F1F1F),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
