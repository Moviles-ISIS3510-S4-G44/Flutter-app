import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:marketplace_flutter_application/data/services/firebase_service.dart';
import 'package:marketplace_flutter_application/data/services/analytics_service.dart';
import 'package:marketplace_flutter_application/data/repositories/user_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/product_repository.dart';

import 'package:marketplace_flutter_application/ui/home/home_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/login/login_model.dart';
import 'package:marketplace_flutter_application/ui/signup/signup_model.dart';
import 'package:marketplace_flutter_application/ui/search/search_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/product/product_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/create_listing/create_listing_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/drafts/drafts_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/map/map_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/profile/profile_viewmodel.dart';

import 'ui/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();
    final analyticsService = AnalyticsService();
    final userRepo = UserRepository(firebaseService);
    final productRepo = ProductRepository(firebaseService);

    final loginModel = LoginModel()..init(userRepo, analyticsService);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => loginModel),
        ChangeNotifierProvider(create: (_) => SignUpModel()),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(productRepo, analyticsService),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchViewModel(productRepo, analyticsService),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductViewModel(productRepo, analyticsService),
        ),
        ChangeNotifierProvider(
          create: (_) => CreateListingViewModel(productRepo, userRepo, analyticsService),
        ),
        ChangeNotifierProvider(
          create: (_) => DraftsViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => MapViewModel(productRepo, analyticsService),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(userRepo, analyticsService),
        ),
      ],
      child: MaterialApp.router(
        title: 'Uniandes Marketplace',
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
