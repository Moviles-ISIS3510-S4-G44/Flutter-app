import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marketplace_flutter_application/data/repositories/chat_repository.dart';
import 'package:provider/provider.dart';

import 'package:marketplace_flutter_application/data/repositories/auth_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/favorite_listings_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/interaction_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/listing_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/location_repository.dart';
import 'package:marketplace_flutter_application/data/services/connectivity_service.dart';
import 'package:marketplace_flutter_application/ui/connectivity/connectivity_model.dart';
import 'package:marketplace_flutter_application/ui/connectivity/connectivity_view.dart';
import 'package:marketplace_flutter_application/ui/favorite_listings/favorite_listings_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/listing-detail/listing_detail_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/listing-detail/widgets/listing_detail_body.dart';

class ListingDetailView extends StatefulWidget {
  final String listingId;

  const ListingDetailView({super.key, required this.listingId});

  @override
  State<ListingDetailView> createState() => _ListingDetailViewState();
}

class _ListingDetailViewState extends State<ListingDetailView> {
  late final ListingDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ListingDetailViewModel(
      listingRepository: context.read<ListingRepository>(),
      interactionRepository: context.read<InteractionRepository>(),
      connectivityService: context.read<ConnectivityService>(),
      authRepository: context.read<AuthRepository>(),
      locationRepository: context.read<LocationRepository>(),
      favoritesRepository: context.read<FavoritesRepository>(),
    );
    _viewModel.loadListing(widget.listingId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectivityModel = context.watch<ConnectivityModel>();

    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: const Text('Product Details'),
            actions: [
              if (_viewModel.listing != null)
                IconButton(
                  tooltip: _viewModel.isFavorite
                      ? 'Remove from favorites'
                      : 'Add to favorites',
                  icon: Icon(
                    _viewModel.isFavorite ? Icons.star : Icons.star_border,
                    color: _viewModel.isFavorite
                        ? const Color(0xFFFFD700)
                        : null,
                  ),
                  onPressed: () async {
                    await _viewModel.toggleFavorite();
                    // Sincroniza el VM global de favoritos
                    if (context.mounted) {
                      context.read<FavoritesViewModel>().loadFavorites();
                    }
                  },
                ),
            ],
          ),
          body: Column(
            children: [
              if (!connectivityModel.isOnline) const ConnectivityView(),
              Expanded(child: _buildBody(context, connectivityModel.isOnline)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, bool isOnline) {
    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_viewModel.errorMessage != null) {
      return _ErrorState(
        message: _viewModel.errorMessage!,
        onRetry: () => _viewModel.retry(),
      );
    }

    final listing = _viewModel.listing;
    if (listing == null) {
      return const Center(child: Text('Listing not found'));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          ListingDetailBody(
            listing: listing,
            sellerName: _viewModel.seller?.name,
            sellerEmail: _viewModel.seller?.email,
            isLoadingSeller: _viewModel.isLoadingSeller,
            distanceKm: _viewModel.distanceKm,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isOnline
                        ? () => context.push('/listing-map/${listing.id}')
                        : null,
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Ver en mapa'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isOnline
                        ? () async {
                            final authRepository = context
                                .read<AuthRepository>();
                            final chatRepository = context
                                .read<ChatRepository>();

                            final token = await authRepository.getAccessToken();

                            if (!context.mounted) return;

                            if (token == null || token.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'You must be logged in to contact the seller',
                                  ),
                                ),
                              );
                              return;
                            }

                            try {
                              final conversation = await chatRepository
                                  .createConversation(
                                    accessToken: token,
                                    listingId: listing.id,
                                  );

                              if (!context.mounted) return;

                              context.push('/messages/${conversation.id}');
                            } catch (error) {
                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Could not start conversation: $error',
                                  ),
                                ),
                              );
                            }
                          }
                        : null,
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Contact'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
