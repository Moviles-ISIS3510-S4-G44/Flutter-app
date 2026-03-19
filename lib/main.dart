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
import 'ui/router/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginModel()),
        ChangeNotifierProvider(create: (_) => SignUpModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel(null, null)),
        ChangeNotifierProvider(create: (_) => SearchViewModel(null, null)),
        ChangeNotifierProvider(create: (_) => ProductViewModel(null, null)),
        ChangeNotifierProvider(create: (_) => CreateListingViewModel(null, null, null)),
        ChangeNotifierProvider(create: (_) => DraftsViewModel()),
        ChangeNotifierProvider(create: (_) => MapViewModel(null, null)),
        ChangeNotifierProvider(create: (_) => ProfileViewModel(null, null)),
      ],
      child: MaterialApp.router(
        title: 'Uniandes Marketplace',
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
