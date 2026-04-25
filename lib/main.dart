import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:marketplace_flutter_application/data/repositories/chat_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/favorite_listings_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/image_upload_repository.dart';
import 'package:marketplace_flutter_application/data/services/chat_service.dart';
import 'package:marketplace_flutter_application/ui/favorite_listings/favorite_listings_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/messages/messages_view_model.dart';
import 'package:marketplace_flutter_application/ui/my_listings/my_listings_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/profile/profile_viewmodel.dart';
import 'package:provider/provider.dart';

import 'package:marketplace_flutter_application/data/repositories/auth_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/category_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/interaction_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/listing_repository.dart';

import 'package:marketplace_flutter_application/data/services/auth_service.dart';
import 'package:marketplace_flutter_application/data/services/category_api_service.dart';
import 'package:marketplace_flutter_application/data/services/connectivity_service.dart';
import 'package:marketplace_flutter_application/data/services/interaction_service.dart';
import 'package:marketplace_flutter_application/data/services/location_service.dart';
import 'package:marketplace_flutter_application/data/repositories/location_repository.dart';
import 'package:marketplace_flutter_application/data/storage/listing_cache_storage.dart';

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
        Provider<ConnectivityService>(create: (_) => ConnectivityService()),

        ChangeNotifierProvider<ConnectivityModel>(
          create: (context) =>
              ConnectivityModel(context.read<ConnectivityService>()),
        ),

        Provider<AuthService>(create: (_) => AuthService()),

        Provider<TokenStorage>(
          create: (_) => TokenStorage(const FlutterSecureStorage()),
        ),

        Provider<AuthRepository>(
          create: (context) => AuthRepository(
            authService: context.read<AuthService>(),
            tokenStorage: context.read<TokenStorage>(),
          ),
        ),

        ChangeNotifierProvider<ProfileViewModel>(
          create: (context) =>
              ProfileViewModel(repository: context.read<AuthRepository>()),
        ),

        Provider<InteractionService>(create: (_) => InteractionService()),

        Provider<InteractionRepository>(
          create: (context) => InteractionRepository(
            interactionService: context.read<InteractionService>(),
            authRepository: context.read<AuthRepository>(),
          ),
        ),

        Provider<ListingCacheStorage>(create: (_) => ListingCacheStorage()),

        Provider<ListingRepository>(
          create: (context) => ListingRepository(
            cacheStorage: context.read<ListingCacheStorage>(),
          ),
        ),

        Provider<CategoryApiService>(create: (_) => CategoryApiService()),

        Provider<LocationService>(create: (_) => LocationService()),

        Provider<LocationRepository>(
          create: (context) => LocationRepository(
            locationService: context.read<LocationService>(),
          ),
        ),

        Provider<FavoritesRepository>(create: (_) => FavoritesRepository()),

        ChangeNotifierProvider<FavoritesViewModel>(
          create: (context) => FavoritesViewModel(
            repository: context.read<FavoritesRepository>(),
          )..loadFavorites(),
        ),

        ChangeNotifierProvider<MyListingsViewModel>(
          create: (context) => MyListingsViewModel(
            listingRepository: context.read<ListingRepository>(),
            authRepository: context.read<AuthRepository>(),
          ),
        ),

        ChangeNotifierProvider<LoginViewModel>(
          create: (context) => LoginViewModel(
            connectivityService: context.read<ConnectivityService>(),
            repository: context.read<AuthRepository>(),
          ),
        ),

        ChangeNotifierProvider<SignUpViewModel>(
          create: (context) => SignUpViewModel(context.read<AuthRepository>()),
        ),

        ChangeNotifierProvider<HomeViewModel>(
          create: (context) => HomeViewModel(
            connectivityService: context.read<ConnectivityService>(),
            listingRepository: context.read<ListingRepository>(),
            interactionRepository: context.read<InteractionRepository>(),
            categoryApiService: context.read<CategoryApiService>(),
            locationRepository: context.read<LocationRepository>(),
          ),
        ),

        Provider<CategoryRepository>(create: (_) => CategoryRepository()),
        Provider<ImageUploadRepository>(create: (_) => ImageUploadRepository()),
        Provider<ChatService>(
          create: (_) => ChatService(baseUrl: dotenv.env['API_BASE_URL']!),
        ),

        Provider<ChatRepository>(
          create: (context) =>
              ChatRepository(chatService: context.read<ChatService>()),
        ),

        ChangeNotifierProvider<MessagesViewModel>(
          create: (context) =>
              MessagesViewModel(chatRepository: context.read<ChatRepository>()),
        ),
        ChangeNotifierProvider<CreateListingViewModel>(
          create: (context) => CreateListingViewModel(
            connectivityService: context.read<ConnectivityService>(),
            categoryRepository: context.read<CategoryRepository>(),
            listingRepository: context.read<ListingRepository>(),
            authRepository: context.read<AuthRepository>(),
            imageUploadRepository: context.read<ImageUploadRepository>(),
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
