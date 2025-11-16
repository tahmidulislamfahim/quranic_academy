import 'package:geolocator/geolocator.dart';

class LocationResult {
  final Position position;
  final String label;

  LocationResult({required this.position, required this.label});
}
