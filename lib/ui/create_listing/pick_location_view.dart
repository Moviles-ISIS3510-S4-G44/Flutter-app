import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

// lets the user tap on the map to pick a location for their listing
class PickLocationView extends StatefulWidget {
  const PickLocationView({super.key});

  @override
  State<PickLocationView> createState() => _PickLocationViewState();
}

class _PickLocationViewState extends State<PickLocationView> {
  // default bogota / uniandes
  LatLng _selected = const LatLng(4.6018, -74.0656);
  bool _hasPicked = false;

  @override
  void initState() {
    super.initState();
    _tryGetCurrentPos();
  }

  Future<void> _tryGetCurrentPos() async {
    try {
      final ok = await Geolocator.isLocationServiceEnabled();
      if (!ok) return;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      setState(() {
        _selected = LatLng(pos.latitude, pos.longitude);
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          TextButton(
            onPressed: _hasPicked
                ? () => Navigator.pop(context, _selected)
                : null,
            child: Text(
              'DONE',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: _hasPicked ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selected,
              zoom: 15,
            ),
            markers: {
              if (_hasPicked)
                Marker(
                  markerId: const MarkerId('picked'),
                  position: _selected,
                ),
            },
            onTap: (pos) {
              setState(() {
                _selected = pos;
                _hasPicked = true;
              });
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          // hint text at top
          if (!_hasPicked)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Text(
                  'Tap on the map to set your listing location',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
