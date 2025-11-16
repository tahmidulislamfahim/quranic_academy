import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../services/location_service.dart';

class LocationHandler {
  static Future<Position> getUserLocation(locationLabel) async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    final loc = await LocationService.getLocation();

    try {
      final places = await placemarkFromCoordinates(
        loc.latitude,
        loc.longitude,
      );

      if (places.isNotEmpty) {
        final p = places.first;
        final parts = <String>[];

        if (p.locality?.isNotEmpty ?? false) parts.add(p.locality!);
        if (p.administrativeArea?.isNotEmpty ?? false)
          parts.add(p.administrativeArea!);
        if (p.country?.isNotEmpty ?? false) parts.add(p.country!);

        locationLabel.value = parts.join(', ');
      }
    } catch (_) {
      locationLabel.value = '';
    }

    return loc;
  }
}
