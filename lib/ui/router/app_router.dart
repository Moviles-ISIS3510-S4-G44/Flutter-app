import 'package:go_router/go_router.dart';
import 'package:marketplace_flutter_application/ui/create_listing/create_listing_view.dart';
import 'package:marketplace_flutter_application/ui/favorite_listings/favorite_listings_view.dart';
import 'package:marketplace_flutter_application/ui/profile/widgets/help_view.dart';
import 'package:marketplace_flutter_application/ui/listing-detail/listing_detail_view.dart';
import 'package:marketplace_flutter_application/ui/map_listing/map_listing_view.dart';
import 'package:marketplace_flutter_application/ui/my_listings/my_listings_view.dart';
import 'package:marketplace_flutter_application/ui/profile/widgets/personal_info_view.dart';
import 'package:marketplace_flutter_application/ui/profile/profile_view.dart';
import 'package:marketplace_flutter_application/ui/messages/messages_view.dart';

import '../home/home_view.dart';
import '../login/login_view.dart';
import '../signup/signup_view.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => SignUpPage(),
      ),
      GoRoute(
        path: '/Home',
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: '/Sell',
        builder: (context, state) => const CreateListingView(),
      ),
      GoRoute(
        path: '/messages',
        builder: (context, state) => const MessagesView(),
      ),
      GoRoute(
        path: '/listing/:listingId',
        builder: (context, state) {
          final listingId = state.pathParameters['listingId']!;
          return ListingDetailView(listingId: listingId);
        },
      ),
      GoRoute(
        path: '/listing-map/:listingId',
        builder: (context, state) {
          final listingId = state.pathParameters['listingId']!;
          return MapListingView(listingId: listingId);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileView(),
      ),
      GoRoute(
        path: '/favorite-listings',
        builder: (context, state) => const FavoritesView(),
      ),
      GoRoute(
        path: '/personal-information',
        builder: (context, state) => const PersonalInformationView(),
      ),
      GoRoute(
        path: '/my-listings',
        builder: (context, state) => const MyListingsView(),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpView(),
      ),
    ],
  );
}