import 'package:flutter/material.dart';

import 'package:marketplace_flutter_application/ui/connectivity/connectivity_model.dart';
import 'package:marketplace_flutter_application/ui/connectivity/connectivity_view.dart';

import 'package:marketplace_flutter_application/ui/home/home_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/home/widgets/categories_bar.dart';
import 'package:marketplace_flutter_application/ui/home/widgets/featured_section.dart';
import 'package:marketplace_flutter_application/ui/home/widgets/recent_listings_section.dart';
import 'package:marketplace_flutter_application/ui/shared/widgets/app_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivityModel = context.watch<ConnectivityModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      appBar: const _HomeAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            if (!connectivityModel.isOnline)
              const ConnectivityView(),

            _SearchBar(isOnline: connectivityModel.isOnline),
            const SizedBox(height: 8),
            const CategoriesBar(),
            const SizedBox(height: 28),
            const Expanded(child: _HomeBody()),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(selectedIndex: 0),
    );
  }
}

class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _HomeAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFEEF2F7),
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      title: const Text(
        'University Marketplace',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1F1F1F),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final bool isOnline;

  const _SearchBar({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        enabled: isOnline,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF1F1F1F),
        ),
        decoration: InputDecoration(
          hintText: isOnline
              ? 'Search for items...'
              : 'Search unavailable offline',
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Color.fromARGB(255, 174, 183, 194),
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(
            Icons.search,
            size: 20,
            color: Color.fromARGB(255, 174, 183, 194),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FeaturedSection(listings: viewModel.featuredListings),
          const SizedBox(height: 24),
          RecentListingsSection(listings: viewModel.recentListings),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}