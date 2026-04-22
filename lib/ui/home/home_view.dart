import 'package:flutter/material.dart';
import 'package:marketplace_flutter_application/ui/connectivity/connectivity_model.dart';
import 'package:marketplace_flutter_application/ui/connectivity/connectivity_view.dart';
import 'package:go_router/go_router.dart';
import 'package:marketplace_flutter_application/ui/home/home_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/home/widgets/categories_bar.dart';
import 'package:marketplace_flutter_application/ui/home/widgets/featured_section.dart';
import 'package:marketplace_flutter_application/ui/home/widgets/recent_listings_section.dart';
import 'package:marketplace_flutter_application/ui/home/widgets/top_interactions_section.dart';
import 'package:marketplace_flutter_application/ui/shared/widgets/app_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/Home');
        break;
      case 2:
        context.go('/Sell');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivityModel = context.watch<ConnectivityModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      appBar: const _HomeAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            if (!connectivityModel.isOnline) const ConnectivityView(),
            _SearchBar(isOnline: connectivityModel.isOnline),
            const SizedBox(height: 8),
            const CategoriesBar(),
            const SizedBox(height: 28),
            const Expanded(child: _HomeBody()),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 0,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }
}

// App bar 

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

// Search bar 

class _SearchBar extends StatelessWidget {
  final bool isOnline;
  const _SearchBar({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<HomeViewModel>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        enabled: isOnline,
        onChanged: viewModel.updateSearchQuery,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1F1F1F)),
        decoration: InputDecoration(
          hintText:
              isOnline ? 'Search for items...' : 'Search unavailable offline',
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

// Body 

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Estado de error con pull-to-refresh para reintentar
    if (viewModel.errorMessage != null) {
      return RefreshIndicator(
        onRefresh: viewModel.loadListings,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      size: 56,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No se pudieron cargar los listings',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Desliza hacia abajo para reintentar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final isSearching = viewModel.searchQuery.isNotEmpty;

    // Cuerpo normal con pull-to-refresh
    return RefreshIndicator(
      onRefresh: viewModel.loadListings,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isSearching) ...[
              TopInteractionsSection(
                listings: viewModel.topInteractionListings,
                distances: viewModel.distances,
              ),
              if (viewModel.topInteractionListings.isNotEmpty)
                const SizedBox(height: 24),
              FeaturedSection(
                listings: viewModel.featuredListings,
                distances: viewModel.distances,
              ),
              const SizedBox(height: 24),
            ],

            // Empty state de búsqueda
            if (isSearching && viewModel.filteredListings.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 52,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Sin resultados para\n"${viewModel.searchQuery}"',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Intenta con otras palabras',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              RecentListingsSection(
                listings: viewModel.filteredListings,
                distances: viewModel.distances,
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}