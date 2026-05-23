import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:marketplace_flutter_application/config/app_config.dart';
import 'package:marketplace_flutter_application/models/cart/cart_item.dart';
import 'package:marketplace_flutter_application/models/listings/listing_detail.dart';

class CheckoutResult {
  final List<Map<String, dynamic>> succeeded;
  final List<CheckoutError> failed;

  CheckoutResult({required this.succeeded, required this.failed});

  bool get hasSuccesses => succeeded.isNotEmpty;
  bool get hasFailures => failed.isNotEmpty;
}

class CheckoutError {
  final String listingTitle;
  final String reason;

  CheckoutError({required this.listingTitle, required this.reason});
}

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

  Future<CheckoutResult> checkout(String token) async {
    final succeeded = <Map<String, dynamic>>[];
    final failed = <CheckoutError>[];
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
        ).timeout(const Duration(seconds: 10));

        debugPrint('checkout [${item.listing.title}] → ${response.statusCode}: ${response.body}');

        if (response.statusCode == 201) {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          // body expected to include fields from ER: id, listing_id, buyer_id, price_at_purchase, purchased_at, seller_id
          succeeded.add({
            'purchaseId': body['id'],
            'listingId': body['listing_id'] ?? item.listing.id,
            'listingTitle': item.listing.title,
            'sellerId': body['seller_id'],
            'sellerName': body['seller_name'] ?? 'Vendedor',
            'priceAtPurchase': body['price_at_purchase'] ?? item.listing.price,
            'purchasedAt': body['purchased_at'],
          });
        } else {
          // Extraer mensaje del backend si existe
          String reason;
          try {
            final body = jsonDecode(response.body) as Map<String, dynamic>;
            reason = body['detail'] as String? ?? _reasonFromStatus(response.statusCode);
          } catch (_) {
            reason = _reasonFromStatus(response.statusCode);
          }
          failed.add(CheckoutError(
            listingTitle: item.listing.title,
            reason: reason,
          ));
        }
      } catch (e) {
        debugPrint('checkout error for ${item.listing.id}: $e');
        failed.add(CheckoutError(
          listingTitle: item.listing.title,
          reason: 'Error de conexión. Verifica tu red.',
        ));
      }
    }

    // Solo limpia los que sí se compraron (listingId puede ser dinámico)
    for (final s in succeeded) {
      final id = s['listingId']?.toString();
      if (id != null) remove(id);
    }

    return CheckoutResult(succeeded: succeeded, failed: failed);
  }

  String _reasonFromStatus(int status) {
    switch (status) {
      case 401: return 'Sesión expirada. Vuelve a iniciar sesión.';
      case 403: return 'No puedes comprar tu propio producto.';
      case 404: return 'Producto no encontrado.';
      case 409: return 'Este producto ya fue comprado por alguien más.';
      default:  return 'Error del servidor ($status).';
    }
  }
}