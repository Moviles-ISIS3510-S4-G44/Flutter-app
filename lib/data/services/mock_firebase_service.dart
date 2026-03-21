import 'dart:io';
import 'package:marketplace_flutter_application/models/app_user.dart';
import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';

// mock firebase for testing without real firebase
// delete this when firebase is set up properly
class MockFirebaseService {
  // fake logged in user
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  // pretend to sign in
  Future<AppUser> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = AppUser(
      id: 'demo_user_001',
      email: email.isEmpty ? 'demo@uniandes.edu.co' : email,
      firstName: 'Demo',
      lastName: 'Student',
    );
    return _currentUser!;
  }

  Future<AppUser> signUp(String email, String password, String name) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final parts = name.trim().split(' ');
    _currentUser = AppUser(
      id: 'demo_user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      firstName: parts.first,
      lastName: parts.length > 1 ? parts.sublist(1).join(' ') : '',
    );
    return _currentUser!;
  }

  Future<void> signOut() async {
    _currentUser = null;
  }

  Future<AppUser?> getUser(String uid) async {
    return _currentUser;
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        name: data['name'] as String?,
        photoUrl: data['photoUrl'] as String?,
      );
    }
  }

  // fake product data - mutable so we can add new ones
  final List<ListingSummary> _listings = List.from(_defaultListings);

  Future<List<ListingSummary>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _listings;
  }

  Future<List<ListingSummary>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final q = query.toLowerCase();
    return _listings.where((l) => l.title.toLowerCase().contains(q)).toList();
  }

  // fake image upload
  Future<String> uploadProfilePhoto(File file, String uid) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'https://picsum.photos/200';
  }

  Future<String> uploadProductImage(File file, String productId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'https://picsum.photos/400/300';
  }

  Future<String> createProduct(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final id = 'mock_${DateTime.now().millisecondsSinceEpoch}';
    // actually add it to the list so it shows up on the dashboard
    _listings.insert(0, ListingSummary(
      id: id,
      title: data['title'] ?? 'Untitled',
      price: '\$${data['price'] ?? 0}',
      category: data['category_id'] ?? 'Other',
      imageUrl: 'https://picsum.photos/400/300?random=$id',
      averageRating: 0.0,
    ));
    return id;
  }

  static const List<ListingSummary> _defaultListings = [
    ListingSummary(
      id: '1',
      title: 'Calculus Textbook',
      price: '\$45',
      category: 'Books',
      imageUrl: 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?auto=format&fit=crop&w=800&q=80',
      averageRating: 4.8,
    ),
    ListingSummary(
      id: '2',
      title: 'MacBook Pro',
      price: '\$850',
      category: 'Electronics',
      imageUrl: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=800&q=80',
      averageRating: 4.9,
    ),
    ListingSummary(
      id: '3',
      title: 'Desk Lamp',
      price: '\$15',
      category: 'Furniture',
      imageUrl: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=800&q=80',
      averageRating: 4.6,
    ),
    ListingSummary(
      id: '4',
      title: 'Calculator',
      price: '\$40',
      category: 'Electronics',
      imageUrl: 'https://images.unsplash.com/photo-1587145820266-a5951ee6f620?auto=format&fit=crop&w=800&q=80',
      averageRating: 4.7,
    ),
    ListingSummary(
      id: '5',
      title: 'Notebook Set',
      price: '\$8',
      category: 'Books',
      imageUrl: 'https://images.unsplash.com/photo-1531346878377-a5be20888e57?auto=format&fit=crop&w=800&q=80',
      averageRating: 4.5,
    ),
    ListingSummary(
      id: '6',
      title: 'Standing Desk',
      price: '\$180',
      category: 'Furniture',
      imageUrl: 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?auto=format&fit=crop&w=800&q=80',
      averageRating: 4.3,
      latitude: 4.6030,
      longitude: -74.0650,
    ),
    ListingSummary(
      id: '7',
      title: 'Physics Lab Kit',
      price: '\$55',
      category: 'Books',
      imageUrl: 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?auto=format&fit=crop&w=800&q=80',
      averageRating: 4.4,
      latitude: 4.6025,
      longitude: -74.0660,
    ),
  ];
}
