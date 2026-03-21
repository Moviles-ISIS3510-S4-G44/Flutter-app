import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import 'package:marketplace_flutter_application/data/repositories/auth_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/category_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/interaction_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/listing_repository.dart';

import 'package:marketplace_flutter_application/data/services/auth_service.dart';
import 'package:marketplace_flutter_application/data/services/connectivity_service.dart';
import 'package:marketplace_flutter_application/data/services/interaction_service.dart';

import 'package:marketplace_flutter_application/data/storage/auth_token_storage.dart';

import 'package:marketplace_flutter_application/ui/connectivity/connectivity_model.dart';
import 'package:marketplace_flutter_application/ui/create_listing/create_listing_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/home/home_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/login/login_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/signup/signup_viewmodel.dart';

import 'ui/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ConnectivityService>(
          create: (_) => ConnectivityService(),
        ),

        ChangeNotifierProvider<ConnectivityModel>(
          create: (context) => ConnectivityModel(
            context.read<ConnectivityService>(),
          ),
        ),

        Provider<AuthService>(
          create: (_) => AuthService(),
        ),

        Provider<TokenStorage>(
          create: (_) => TokenStorage(
            const FlutterSecureStorage(),
          ),
        ),

        Provider<AuthRepository>(
          create: (context) => AuthRepository(
            authService: context.read<AuthService>(),
            tokenStorage: context.read<TokenStorage>(),
          ),
        ),

        Provider<InteractionService>(
          create: (_) => InteractionService(),
        ),

        Provider<InteractionRepository>(
          create: (context) => InteractionRepository(
            interactionService: context.read<InteractionService>(),
            authRepository: context.read<AuthRepository>(),
          ),
        ),

        Provider<ListingRepository>(
          create: (_) => ListingRepository(),
        ),

        ChangeNotifierProvider<LoginViewModel>(
          create: (context) => LoginViewModel(
            connectivityService: context.read<ConnectivityService>(),
            repository: context.read<AuthRepository>(),
          ),
        ),

        ChangeNotifierProvider<SignUpViewModel>(
          create: (context) => SignUpViewModel(
            context.read<AuthRepository>(),
          ),
        ),

        ChangeNotifierProvider<HomeViewModel>(
          create: (context) => HomeViewModel(
            connectivityService: context.read<ConnectivityService>(),
            listingRepository: context.read<ListingRepository>(),
          ),
        ),

        ChangeNotifierProvider<CreateListingViewModel>(
          create: (context) => CreateListingViewModel(
            categoryRepository: CategoryRepository(),
            authRepository: context.read<AuthRepository>(),
          ),
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