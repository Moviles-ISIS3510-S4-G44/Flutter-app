import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marketplace_flutter_application/ui/connectivity/connectivity_model.dart';
import 'package:marketplace_flutter_application/ui/create_listing/create_listing_viewmodel.dart';
import 'package:provider/provider.dart';

class ListingLocationSection extends StatelessWidget {
  const ListingLocationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreateListingViewModel>();

    final LatLng? savedLocation =
        (viewModel.locationLat != null && viewModel.locationLng != null)
            ? LatLng(viewModel.locationLat!, viewModel.locationLng!)
            : null;

    final hasError = viewModel.locationError != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ubicación',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F1F1F),
              ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _openLocationPicker(context, savedLocation),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: hasError ? const Color(0xFFFFEBEE) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasError
                    ? const Color(0xFFD32F2F)
                    : const Color(0xFFD1D5DB),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: hasError
                      ? const Color(0xFFD32F2F)
                      : const Color(0xFF374151),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    savedLocation != null
                        ? 'Ubicación seleccionada ✓'
                        : 'Seleccionar ubicación',
                    style: TextStyle(
                      fontSize: 15,
                      color: savedLocation != null
                          ? const Color(0xFF1F1F1F)
                          : const Color(0xFF9AA4B2),
                      fontWeight: savedLocation != null
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 14,
                  color: Color(0xFFD32F2F),
                ),
                const SizedBox(width: 4),
                Text(
                  viewModel.locationError!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFD32F2F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _openLocationPicker(
    BuildContext context,
    LatLng? currentLocation,
  ) async {
    const defaultLocation = LatLng(4.60271, -74.06470);

    final LatLng? result = await showDialog<LatLng>(
      context: context,
      builder: (_) => LocationPickerDialog(
        initialLocation: currentLocation ?? defaultLocation,
      ),
    );

    if (result != null && context.mounted) {
      context.read<CreateListingViewModel>().updateLocationFromCoordinates(
            result.latitude,
            result.longitude,
          );
    }
  }
}

class LocationPickerDialog extends StatefulWidget {
  final LatLng initialLocation;

  const LocationPickerDialog({
    super.key,
    required this.initialLocation,
  });

  @override
  State<LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  GoogleMapController? _mapController;
  late LatLng _pickedLocation;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
    } catch (_) {
      // Falla silenciosamente si no se puede pedir permiso
    }
  }

  void _centerOnPickedLocation() {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _pickedLocation, zoom: 16),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectivityModel>().isOnline;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: double.infinity,
        height: 500,
        child: Column(
          children: [
            if (!isOnline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD700),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.wifi_off, size: 16, color: Colors.black87),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sin conexión. El mapa puede no cargar correctamente.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Selecciona la ubicación',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F1F1F),
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: widget.initialLocation,
                          zoom: 15,
                        ),
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                        onTap: (position) {
                          setState(() => _pickedLocation = position);
                        },
                        markers: {
                          Marker(
                            markerId: const MarkerId('selected_location'),
                            position: _pickedLocation,
                          ),
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        scrollGesturesEnabled: true,
                        zoomGesturesEnabled: true,
                        rotateGesturesEnabled: true,
                        tiltGesturesEnabled: true,
                        compassEnabled: true,
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          elevation: 3,
                          child: InkWell(
                            onTap: _centerOnPickedLocation,
                            borderRadius: BorderRadius.circular(12),
                            child: const SizedBox(
                              width: 46,
                              height: 46,
                              child: Icon(
                                Icons.my_location,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, _pickedLocation),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF111827),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text('Confirmar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}