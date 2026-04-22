import 'package:go_router/go_router.dart';
import 'package:marketplace_flutter_application/ui/create_listing/create_listing_view.dart';
import 'package:marketplace_flutter_application/ui/listing-detail/listing_detail_view.dart';
import 'package:marketplace_flutter_application/ui/map_listing/map_listing_view.dart';

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
    ],
  );
}