import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';

class MapViewModel extends ChangeNotifier {
  final dynamic _productRepo;
  final dynamic _analytics;

  MapViewModel(this._productRepo, this._analytics);

  List<ListingSummary> products = [];
  Set<Marker> markers = {};
  bool isLoading = false;
  String? error;
  // default to bogota since its uniandes
  LatLng currentLocation = const LatLng(4.6018, -74.0656);

  // the product the user tapped on the map
  ListingSummary? selectedProduct;
  double? selectedDistance;

  Future<void> loadMap() async {
    isLoading = true;
    notifyListeners();

    try {
      await _analytics.logViewMap();
      await _getCurrentLocation();
      await _loadProductMarkers();
    } catch (e) {
      error = e.toString();
      print('map error: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // chekc permissions first
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return;
      }

      final pos = await Geolocator.getCurrentPosition();
      currentLocation = LatLng(pos.latitude, pos.longitude);
    } catch (e) {
      // location failed, just use default bogota
      print('couldnt get location: $e');
    }
  }

  Future<void> _loadProductMarkers() async {
    products = await _productRepo.getWithLocation();

    markers = products.where((p) => p.latitude != null && p.longitude != null).map((p) {
      return Marker(
        markerId: MarkerId(p.id),
        position: LatLng(p.latitude!, p.longitude!),
        infoWindow: InfoWindow(
          title: p.title,
          snippet: p.price,
        ),
        onTap: () {
          selectProduct(p);
          _analytics.logViewMapProduct(p.id, p.latitude!, p.longitude!);
        },
      );
    }).toSet();
  }

  void selectProduct(ListingSummary product) {
    selectedProduct = product;
    if (product.latitude != null && product.longitude != null) {
      selectedDistance = _calculateDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        product.latitude!,
        product.longitude!,
      );
    }
    notifyListeners();
  }

  void clearSelection() {
    selectedProduct = null;
    selectedDistance = null;
    notifyListeners();
  }

  // haversine formula to get distance in km
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // earth radius in km
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRad(double deg) => deg * pi / 180;
}
