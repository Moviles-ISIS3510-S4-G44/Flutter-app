import 'package:go_router/go_router.dart';

import '../home/home_view.dart';
import '../login/login_view.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',

    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeView(),
      ),
    ],
  );
}