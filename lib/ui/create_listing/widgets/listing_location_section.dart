import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marketplace_flutter_application/ui/create_listing/create_listing_viewmodel.dart';
import 'package:provider/provider.dart';

class ListingLocationSection extends StatefulWidget {
  const ListingLocationSection({super.key});

  @override
  State<ListingLocationSection> createState() => _ListingLocationSectionState();
}

class _ListingLocationSectionState extends State<ListingLocationSection> {
  LatLng? _selectedLocation;

  Future<void> _openLocationPicker() async {
    final LatLng? result = await showDialog<LatLng>(
      context: context,
      builder: (_) => LocationPickerDialog(
        initialLocation: _selectedLocation ?? const LatLng(4.60971, -74.08175),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
      });

      context.read<CreateListingViewModel>().updateLocationFromCoordinates(
        result.latitude,
        result.longitude,
      );
    }
  }

  String _buildLocationText(String? location) {
    if (location == null || location.isEmpty) {
      return 'Select location';
    }
    return 'Location selected';
  }

  @override
  Widget build(BuildContext context) {
    final String? location = context.watch<CreateListingViewModel>().location;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F1F1F),
              ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _openLocationPicker,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD1D5DB)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFF374151),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _buildLocationText(location),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF1F1F1F),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
  }

  void _centerOnPickedLocation() {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _pickedLocation,
          zoom: 16,
        ),
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
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 500,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select location',
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
                          zoom: 14,
                        ),
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                        onTap: (position) {
                          setState(() {
                            _pickedLocation = position;
                          });
                        },
                        markers: {
                          Marker(
                            markerId: const MarkerId('selected_location'),
                            position: _pickedLocation,
                          ),
                        },
                        zoomControlsEnabled: false,
                        myLocationButtonEnabled: false,
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
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Cancel'),
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
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('OK'),
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