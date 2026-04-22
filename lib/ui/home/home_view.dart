import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marketplace_flutter_application/ui/connectivity/connectivity_model.dart';
import 'package:marketplace_flutter_application/ui/connectivity/connectivity_view.dart';
import 'package:go_router/go_router.dart';
import 'package:marketplace_flutter_application/ui/home/home_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/home/widgets/home_header.dart';
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
    case 1:
      context.go('/Sell');
      break;
    case 2:
      break; // carrito
    case 3:
      break; // messages
    case 4:
      context.go('/profile');
      break;
  }
  }

  @override
  Widget build(BuildContext context) {
    final connectivityModel = context.watch<ConnectivityModel>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFFFE600),
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFE600),
        body: Column(
          children: [
            Container(
              color: const Color(0xFFFFE600),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    if (!connectivityModel.isOnline) const ConnectivityView(),
                    HomeHeader(isOnline: connectivityModel.isOnline),
                  ],
                ),
              ),
            ),
            const Expanded(
              child: _HomeBody(),
            ),
          ],
        ),
        bottomNavigationBar: AppBottomNavBar(
          selectedIndex: 0,
          onTap: (index) => _onNavTap(context, index),
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
      return const ColoredBox(
        color: Color(0xFFF5F5F5),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.errorMessage != null) {
      return Container(
        color: const Color(0xFFF5F5F5),
        child: RefreshIndicator(
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
        ),
      );
    }

    final isSearching = viewModel.searchQuery.isNotEmpty;

    return Container(
      color: const Color(0xFFF5F5F5),
      child: RefreshIndicator(
        onRefresh: viewModel.loadListings,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isSearching) ...[
                TopInteractionsSection(
                  listings: viewModel.topInteractionListings,
                  distances: viewModel.distances,
              ),
                if (viewModel.topInteractionListings.isNotEmpty)
                  const SizedBox(height: 16),
                FeaturedSection(
                listings: viewModel.featuredListings,
                distances: viewModel.distances,
              ),
                const SizedBox(height: 16),
              ],
              if (isSearching && viewModel.filteredListings.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Sin resultados para\n"${viewModel.searchQuery}"',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                RecentListingsSection(
                  
                listings: viewModel.filteredListings,
                distances: viewModel.distances,
              ,
                ),
            ],
          ),
        ),
      ),
    );
  }
}