import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
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
  bool _hasLocationPermission = false;

  @override
  void initState() {
    super.initState();
    _viewModel = MapListingViewModel();
    _viewModel.loadListing(widget.listingId);
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    try {
      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (!mounted) return;

      setState(() {
        _hasLocationPermission =
            permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _hasLocationPermission = false;
      });
    }
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
              if (!connectivityModel.isOnline) const ConnectivityView(),
              Expanded(
                child: _buildBody(context, connectivityModel.isOnline),
              ),
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
      return const Center(child: Text('Listing location not available'));
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
            myLocationEnabled: _hasLocationPermission,
            myLocationButtonEnabled: _hasLocationPermission,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            scrollGesturesEnabled: isOnline,
            zoomGesturesEnabled: isOnline,
            rotateGesturesEnabled: isOnline,
            tiltGesturesEnabled: isOnline,
          ),
        ),
        if (!isOnline)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                color: Colors.black.withOpacity(0.35),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white, size: 48),
                      SizedBox(height: 14),
                      Text(
                        'Sin conexión',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'El mapa no está disponible offline',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (isOnline)
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: MapListingPreviewCard(
              listing: listing,
              onTap: () => context.push('/listing/${listing.id}'),
            ),
          ),
      ],
    );
  }
}