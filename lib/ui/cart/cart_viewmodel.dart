import 'package:flutter/foundation.dart';
import 'package:marketplace_flutter_application/data/repositories/auth_repository.dart';
import 'package:marketplace_flutter_application/data/services/listing_api_service.dart';
import 'package:marketplace_flutter_application/models/cart/cart_item.dart';
import 'package:marketplace_flutter_application/models/listings/listing_detail.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:marketplace_flutter_application/config/app_config.dart';

class CartViewModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get count => _items.length;
  bool get isEmpty => _items.isEmpty;

  bool isInCart(String listingId) =>
      _items.any((item) => item.listing.id == listingId);

  void add(ListingDetail listing) {
    if (isInCart(listing.id)) return;
    _items.add(CartItem(listing: listing));
    notifyListeners();
  }

  void remove(String listingId) {
    _items.removeWhere((item) => item.listing.id == listingId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  int get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.listing.price);

  /// Compra todos los items del carrito.
  /// Retorna lista de {listingId, purchaseId, sellerName} para la pantalla de rating.
  Future<List<Map<String, String>>> checkout(String token) async {
    final results = <Map<String, String>>[];
    final client = http.Client();

    for (final item in _items) {
      try {
        final response = await client.post(
          Uri.parse('${AppConfig.apiBaseUrl}/purchases'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'listing_id': item.listing.id}),
        );

        if (response.statusCode == 201) {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          results.add({
            'purchaseId': body['id'] as String,
            'listingId': item.listing.id,
            'listingTitle': item.listing.title,
            'sellerName': 'Vendedor',
          });
        }
      } catch (e) {
        debugPrint('checkout error for ${item.listing.id}: $e');
      }
    }

    clear();
    return results;
  }
}