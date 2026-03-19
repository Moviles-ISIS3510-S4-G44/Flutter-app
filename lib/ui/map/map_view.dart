import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:marketplace_flutter_application/ui/map/map_viewmodel.dart';
import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MapViewModel>().loadMap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapViewModel>();

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
          'Nearby Listings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F1F1F),
            fontFamily: 'PlusJakartaSans',
          ),
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: vm.currentLocation,
                    zoom: 15,
                  ),
                  markers: vm.markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  onTap: (_) {
                    // tap on empty area clears selection
                    vm.clearSelection();
                  },
                ),
                // listing count chip at top
                Positioned(
                  top: 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: () {
                      // show list of all nearby products
                      if (vm.products.isNotEmpty) {
                        _showAllListingsSheet(context, vm);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0B8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Color(0xFF6A5A00)),
                          const SizedBox(width: 6),
                          Text(
                            '${vm.products.length} listings nearby',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Color(0xFF1F1F1F),
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF6A5A00)),
                        ],
                      ),
                    ),
                  ),
                ),
                // selected product card at bottom
                if (vm.selectedProduct != null)
                  Positioned(
                    bottom: 24,
                    left: 16,
                    right: 16,
                    child: _ProductCard(
                      product: vm.selectedProduct!,
                      distanceKm: vm.selectedDistance,
                      onClose: () => vm.clearSelection(),
                    ),
                  ),
                if (vm.error != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(vm.error!),
                    ),
                  ),
              ],
            ),
    );
  }

  void _showAllListingsSheet(BuildContext context, MapViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        constraints: const BoxConstraints(maxHeight: 400),
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${vm.products.length} listings nearby',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F1F1F),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: vm.products.length,
                itemBuilder: (ctx, i) {
                  final p = vm.products[i];
                  final dist = _calcDist(vm, p);
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        p.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50, height: 50,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                      ),
                    ),
                    title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(p.price),
                    trailing: Text(
                      '${dist.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6A5A00),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      vm.selectProduct(p);
                      if (p.latitude != null && p.longitude != null) {
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLng(LatLng(p.latitude!, p.longitude!)),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calcDist(MapViewModel vm, ListingSummary p) {
    if (p.latitude == null || p.longitude == null) return 0;
    // use the viewmodel's haversine
    // quick inline calc since we cant call private method
    final dx = (p.latitude! - vm.currentLocation.latitude) * 111.32;
    final dy = (p.longitude! - vm.currentLocation.longitude) * 111.32 * 0.85;
    return sqrt(dx * dx + dy * dy);
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

class _ProductCard extends StatelessWidget {
  final ListingSummary product;
  final double? distanceKm;
  final VoidCallback onClose;

  const _ProductCard({
    required this.product,
    this.distanceKm,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // product image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              product.imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 70,
                height: 70,
                color: Colors.grey[200],
                child: const Icon(Icons.image, size: 30, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F1F1F),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.price,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6A5A00),
                  ),
                ),
                if (distanceKm != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Color(0xFF9A9A9A)),
                      const SizedBox(width: 4),
                      Text(
                        '${distanceKm!.toStringAsFixed(1)} km away',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          color: Color(0xFF9A9A9A),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // close button
          GestureDetector(
            onTap: onClose,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 18, color: Color(0xFF9A9A9A)),
            ),
          ),
        ],
      ),
    );
  }
}
