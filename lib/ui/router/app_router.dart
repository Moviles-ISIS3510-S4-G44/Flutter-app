import 'package:go_router/go_router.dart';

import '../home/home_view.dart';
import '../login/login_view.dart';
import '../signup/signup_view.dart';
import '../search/search_view.dart';
import '../product/product_detail_view.dart';
import '../create_listing/create_listing_view.dart';
import '../drafts/drafts_view.dart';
import '../map/map_view.dart';
import '../profile/profile_view.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',

    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchView(),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailView(productId: id);
        },
      ),
      GoRoute(
        path: '/create',
        builder: (context, state) => const CreateListingView(),
      ),
      GoRoute(
        path: '/drafts',
        builder: (context, state) => const DraftsView(),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => const MapView(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileView(),
      ),
    ],
  );
}
