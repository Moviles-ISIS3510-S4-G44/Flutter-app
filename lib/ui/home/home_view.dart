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
      backgroundColor:  Color(0xFFEEF2F7),
      appBar: _HomeAppBar(),
      body: SafeArea(
        child: Column(
          children:  [
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
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF1F1F1F),
        ),
        decoration: InputDecoration(
          hintText: 'Search for items...',
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
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      color: const Color(0xFFFFF0B8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _NavItem(
            icon: Icons.home,
            label: 'Home',
            isSelected: true,
          ),
          _NavItem(
            icon: Icons.search,
            label: 'Search',
          ),
          _NavItem(
            icon: Icons.add,
            label: 'Sell',
          ),
          _NavItem(
            icon: Icons.chat_bubble_outline,
            label: 'Messages',
          ),
          _NavItem(
            icon: Icons.person_outline,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF3E39A) : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Icon(
            icon,
            size: 22,
            color: const Color(0xFF1F1F1F),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F1F1F),
          ),
        ),
      ],
    );
  }
}