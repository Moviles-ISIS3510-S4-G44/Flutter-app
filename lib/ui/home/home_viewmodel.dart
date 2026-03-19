import 'package:flutter/foundation.dart';
import '../../models/listing.dart';

class HomeViewModel extends ChangeNotifier {
  final List<Listing> featuredListings = [
    const Listing(
      id: '1',
      title: 'Calculus Textbook',
      price: '\$45',
      category: 'Books',
    ),
    const Listing(
      id: '2',
      title: 'MackBook Pro',
      price: '\$350',
      category: 'Electronics',
    ),
  ];

  final List<Listing> recentListings = [
    const Listing(
      id: '3',
      title: 'Desk Lamp',
      price: '\$15',
      category: 'Furniture',
    ),
    const Listing(
      id: '4',
      title: 'Calculator',
      price: '\$40',
      category: 'Electronics',
    ),
    const Listing(
      id: '5',
      title: 'Notebook Set',
      price: '\$8',
      category: 'Books',
    ),
  ];

  bool isLoading = false;
}