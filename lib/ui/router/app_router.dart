import 'package:go_router/go_router.dart';
import 'package:marketplace_flutter_application/ui/create_listing/create_listing_view.dart';

import '../home/home_view.dart';
import '../login/login_view.dart';
import '../signup/signup_view.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/Home',

    routes: [
      GoRoute(path: '/login', builder: (context, state) => LoginPage()),
      GoRoute(path: '/signup', builder: (context, state) => SignUpPage()),
      GoRoute(path: '/Home', builder: (context, state) => const HomeView()),
      GoRoute(
        path: '/Sell',
        builder: (context, state) => const CreateListingView(),
      ),
    ],
  );
}
