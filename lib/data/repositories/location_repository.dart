import 'package:geolocator/geolocator.dart';
import 'package:marketplace_flutter_application/data/services/location_service.dart';

class LocationRepository {
  final LocationService _locationService;

  LocationRepository({LocationService? locationService})
      : _locationService = locationService ?? LocationService();

  /// Devuelve la posición actual o null
  Future<Position?> getCurrentPosition() {
    return _locationService.getCurrentPosition();
  }

  /// Calcula la distancia en km entre la posición del usuario y unas coordenadas.
  /// Retorna null si la posición del usuario no está disponible o las coordenadas del listing son inválidas.
  Future<double?> getDistanceTo(double? listingLat, double? listingLng) async {
    if (listingLat == null || listingLng == null) return null;

    final position = await _locationService.getCurrentPosition();
    if (position == null) return null;

    final distanceMeters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      listingLat,
      listingLng,
    );

    return distanceMeters / 1000.0; // convertir a km
  }

  /// Calcula distancias desde una posición ya conocida a múltiples coordenadas (para calcular todas las distancias del home en un solo llamado al GPS)
  Map<String, double> calculateDistances({
    required Position userPosition,
    required Map<String, ({double lat, double lng})> listingCoords,
  }) {
    final result = <String, double>{};

    for (final entry in listingCoords.entries) {
      final distanceMeters = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        entry.value.lat,
        entry.value.lng,
      );
      result[entry.key] = distanceMeters / 1000.0;
    }

    return result;
  }
}