import 'package:flutter/material.dart';
import 'package:marketplace_flutter_application/ui/home/home_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/home/widgets/categories_bar.dart';
import 'package:marketplace_flutter_application/ui/home/widgets/featured_section.dart';
import 'package:marketplace_flutter_application/ui/home/widgets/recent_listings_section.dart';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          children: const [
            _SearchBar(),
            SizedBox(height: 8),
            CategoriesBar(),
            SizedBox(height: 28),
            Expanded(child: _HomeBody()),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavBar(),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for items...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
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
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Sell'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Messages'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
