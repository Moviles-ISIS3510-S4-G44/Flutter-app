import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marketplace_flutter_application/ui/connectivity/connectivity_model.dart';
import 'package:marketplace_flutter_application/ui/connectivity/connectivity_view.dart';
import 'package:marketplace_flutter_application/ui/map_listing/map_listing_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/map_listing/widgets/map_listing_preview_card.dart';
import 'package:provider/provider.dart';

class MapListingView extends StatefulWidget {
  final String listingId;

  const MapListingView({
    super.key,
    required this.listingId,
  });

  @override
  State<MapListingView> createState() => _MapListingViewState();
}

class _MapListingViewState extends State<MapListingView> {
  late final MapListingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MapListingViewModel();
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
            title: const Text('Listing Location'),
          ),
          body: Column(
            children: [
              if (!connectivityModel.isOnline)
                const ConnectivityView(),

              Expanded(
                child: _buildBody(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_viewModel.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _viewModel.errorMessage!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (!_viewModel.hasListing || !_viewModel.hasValidCoordinates) {
      return const Center(
        child: Text('Listing location not available'),
      );
    }

    final listing = _viewModel.listing!;
    final position = LatLng(_viewModel.latitude!, _viewModel.longitude!);

    return Stack(
      children: [
        Positioned.fill(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: position,
              zoom: 16,
            ),
            markers: {
              Marker(
                markerId: MarkerId(listing.id),
                position: position,
                infoWindow: InfoWindow(
                  title: listing.title,
                  snippet: '\$${listing.price}',
                ),
              ),
            },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: MapListingPreviewCard(
            listing: listing,
            onTap: () {
              context.push('/listing/${listing.id}');
            },
          ),
        ),
      ],
    );
  }
}