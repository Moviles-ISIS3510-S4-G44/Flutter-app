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

  // Estado de checkout para la UI
  bool isCheckingOut = false;

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



    if (_items.isEmpty) return CheckoutResult(succeeded: succeeded, failed: failed);

    isCheckingOut = true;
    notifyListeners();

    // Configuracion: concurrencia maxima y reintentos
    const int maxConcurrency = 3;
    const int maxRetries = 2;

    // Helper que hace el POST con reintentos exponenciales simples
    Future<Map<String, dynamic>?> attemptPurchase(CartItem item) async {
      int attempt = 0;
      while (true) {
        try {
          final response = await client
              .post(
            Uri.parse('${AppConfig.apiBaseUrl}/purchases'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'listing_id': item.listing.id}),
          )
              .timeout(const Duration(seconds: 10));

          debugPrint('checkout [${item.listing.title}] → ${response.statusCode}');

          if (response.statusCode == 201) {
            final body = jsonDecode(response.body) as Map<String, dynamic>;
            return {
              'purchase': body,
              'listing': item.listing,
            };
          }

          // Non-201: return status+body so caller can add error with reason
          return {'status': response.statusCode, 'body': response.body};
        } catch (e) {
          if (attempt >= maxRetries) {
            debugPrint('checkout failed after retries for ${item.listing.id}: $e');
            return {'error': e.toString()};
          }
          attempt++;
          await Future.delayed(Duration(milliseconds: 300 * attempt));
        }
      }
    }

    // Process items in batches to limit concurrency
    final items = List<CartItem>.from(_items);
    for (var i = 0; i < items.length; i += maxConcurrency) {
      final batch = items.skip(i).take(maxConcurrency).toList();

      final futures = batch.map((item) => attemptPurchase(item)).toList();
      final results = await Future.wait(futures);

      for (var idx = 0; idx < batch.length; idx++) {
        final item = batch[idx];
        final res = results[idx];

        if (res == null) {
          failed.add(CheckoutError(listingTitle: item.listing.title, reason: 'Error desconocido'));
          continue;
        }

        if (res.containsKey('purchase')) {
          final body = res['purchase'] as Map<String, dynamic>;
          succeeded.add({
            'purchaseId': body['id'],
            'listingId': body['listing_id'] ?? item.listing.id,
            'listingTitle': item.listing.title,
            'sellerId': body['seller_id'],
            'sellerName': body['seller_name'] ?? 'Vendedor',
            'priceAtPurchase': body['price_at_purchase'] ?? item.listing.price,
            'purchasedAt': body['purchased_at'],
          });
        } else if (res.containsKey('status')) {
          final status = res['status'] as int?;
          String reason = 'Error del servidor';
          try {
            final body = jsonDecode(res['body'] as String) as Map<String, dynamic>;
            reason = body['detail'] as String? ?? _reasonFromStatus(status ?? 0);
          } catch (_) {
            reason = _reasonFromStatus(status ?? 0);
          }
          failed.add(CheckoutError(listingTitle: item.listing.title, reason: reason));
        } else if (res.containsKey('error')) {
          failed.add(CheckoutError(listingTitle: item.listing.title, reason: 'Error de conexión. Intenta de nuevo.'));
        } else {
          failed.add(CheckoutError(listingTitle: item.listing.title, reason: 'Error inesperado'));
        }
      }
    }

    // Cleanup: remove purchased items
    for (final s in succeeded) {
      final id = s['listingId']?.toString();
      if (id != null) remove(id);
    }

    client.close();
    isCheckingOut = false;
    notifyListeners();

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