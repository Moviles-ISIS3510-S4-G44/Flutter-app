import 'package:flutter/foundation.dart';
import '../../models/listings/listing_summary.dart';
import '../../data/services/connectivity_service.dart';

class HomeViewModel extends ChangeNotifier {
  final ConnectivityService connectivityService;

  HomeViewModel(this.connectivityService);

  bool isLoading = false;
  String? errorMessage;

  List<ListingSummary> featuredListings = [];
  List<ListingSummary> recentListings = [];

  Future<void> loadHomeData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final bool isOnline = await connectivityService.isOnline;

      if (!isOnline) {
        errorMessage = 'No internet connection. Unable to load listings.';
        featuredListings = [];
        recentListings = [];
        return;
      }

      featuredListings = [
        const ListingSummary(
          id: '1',
          title: 'Calculus Textbook',
          price: '\$45',
          category: 'Books',
          imageUrl:
              'https://images.unsplash.com/photo-1516979187457-637abb4f9353?auto=format&fit=crop&w=800&q=80',
          averageRating: 4.8,
        ),
        const ListingSummary(
          id: '2',
          title: 'MacBook Pro',
          price: '\$850',
          category: 'Electronics',
          imageUrl:
              'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=800&q=80',
          averageRating: 4.9,
        ),
      ];

      recentListings = [
        const ListingSummary(
          id: '3',
          title: 'Desk Lamp',
          price: '\$15',
          category: 'Furniture',
          imageUrl:
              'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=800&q=80',
          averageRating: 4.6,
        ),
        const ListingSummary(
          id: '4',
          title: 'Calculator',
          price: '\$40',
          category: 'Electronics',
          imageUrl:
              'https://images.unsplash.com/photo-1587145820266-a5951ee6f620?auto=format&fit=crop&w=800&q=80',
          averageRating: 4.7,
        ),
        const ListingSummary(
          id: '5',
          title: 'Notebook Set',
          price: '\$8',
          category: 'Books',
          imageUrl:
              'https://images.unsplash.com/photo-1531346878377-a5be20888e57?auto=format&fit=crop&w=800&q=80',
          averageRating: 4.5,
        ),
      ];
    } catch (e) {
      errorMessage = 'Error loading home data';
      featuredListings = [];
      recentListings = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}