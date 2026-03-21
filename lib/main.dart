import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marketplace_flutter_application/ui/home/home_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/login/login_model.dart';
import 'package:marketplace_flutter_application/ui/signup/signup_model.dart';
import 'package:marketplace_flutter_application/ui/search/search_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/product/product_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/create_listing/create_listing_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/drafts/drafts_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/map/map_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/profile/profile_viewmodel.dart';
import 'package:marketplace_flutter_application/data/services/mock_firebase_service.dart';
import 'package:marketplace_flutter_application/data/services/mock_analytics_service.dart';
import 'package:marketplace_flutter_application/data/repositories/mock_product_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/mock_user_repository.dart';
import 'ui/router/app_router.dart';

// using mocks for now, swap to Api repos when backend is deployed
// TODO: switch to ApiUserRepository + ApiProductRepository when BE is ready
final _mockFirebase = MockFirebaseService();
final _userRepository = MockUserRepository(_mockFirebase);
final _productRepository = MockProductRepository(_mockFirebase);
final _analytics = MockAnalyticsService();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginModel(_userRepository)),
        ChangeNotifierProvider(create: (_) => SignUpModel(_userRepository)),
        ChangeNotifierProvider(create: (_) => HomeViewModel(_productRepository, _analytics)),
        ChangeNotifierProvider(create: (_) => SearchViewModel(_productRepository, _analytics)),
        ChangeNotifierProvider(create: (_) => ProductViewModel(_productRepository, _analytics)),
        ChangeNotifierProvider(create: (_) => CreateListingViewModel(_productRepository, _userRepository, _analytics)),
        ChangeNotifierProvider(create: (_) => DraftsViewModel()),
        ChangeNotifierProvider(create: (_) => MapViewModel(_productRepository, _analytics)),
        ChangeNotifierProvider(create: (_) => ProfileViewModel(_userRepository, _analytics)),
      ],
      child: MaterialApp.router(
        title: 'Uniandes Marketplace',
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}

