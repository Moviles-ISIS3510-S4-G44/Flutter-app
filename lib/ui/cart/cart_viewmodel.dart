import 'package:flutter/foundation.dart';
import 'package:marketplace_flutter_application/models/cart/cart_item.dart';
import 'package:marketplace_flutter_application/models/listings/listing_detail.dart';

class CartViewModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get count => _items.length;

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
}