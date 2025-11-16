import '../../services/zakat_service.dart';

class ZakatParser {
  static Future<void> parseNisab(loc, nisab) async {
    nisab.value = await ZakatService.getNisab(
      latitude: loc.latitude,
      longitude: loc.longitude,
    );
  }
}
