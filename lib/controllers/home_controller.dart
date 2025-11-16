import 'package:get/get.dart';
import 'dart:convert';
import 'package:quranic_academy/controllers/helpers/fasting_parser.dart';
import 'package:quranic_academy/controllers/helpers/offline_handler.dart';
import 'package:quranic_academy/controllers/helpers/prayer_parser.dart';
import 'package:quranic_academy/controllers/helpers/zakat_parser.dart';
import 'package:quranic_academy/controllers/location/location_handler.dart';
import 'package:quranic_academy/services/api_service.dart';
import 'package:quranic_academy/services/prayer_service.dart';
import 'helpers/metadata_parser.dart';

class HomeController extends GetxController {
  final _loading = false.obs;

  final prayerTimes = <String, String>{}.obs;
  final fasting = ''.obs;
  final nisab = ''.obs;

  final dateReadable = ''.obs;
  final hijri = ''.obs;
  final gregorian = ''.obs;

  final qibla = ''.obs;
  final qiblaDegrees = 0.0.obs;

  final prohibitedTimes = <String, String>{}.obs;

  final lastUpdated = Rxn<DateTime>();
  final lastApiRaw = ''.obs;
  final locationLabel = ''.obs;
  final isOfflineCached = false.obs;

  bool get loading => _loading.value;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    _loading.value = true;

    try {
      // INTERNET CHECK
      final online = await ApiService.hasInternet();

      if (!online) {
        await OfflineHandler.handleOffline(
          prayerTimes: prayerTimes,
          fasting: fasting,
          nisab: nisab,
          dateReadable: dateReadable,
          hijri: hijri,
          gregorian: gregorian,
          qibla: qibla,
          qiblaDegrees: qiblaDegrees,
          prohibitedTimes: prohibitedTimes,
          lastUpdated: lastUpdated,
          lastApiRaw: lastApiRaw,
          isOfflineCached: isOfflineCached,
        );

        _loading.value = false;
        return;
      }

      // LOCATION
      final loc = await LocationHandler.getUserLocation(locationLabel);

      // Fetch API
      final apiRaw = await ApiService.fetchPrayer(loc.latitude, loc.longitude);

      if (apiRaw != null) {
        MetaDataParser.parseMetadata(
          apiRaw,
          dateReadable,
          hijri,
          gregorian,
          qibla,
          qiblaDegrees,
          prohibitedTimes,
        );

        lastApiRaw.value = json.encode(apiRaw);
      }

      // Parse Prayer Times
      final times = await PrayerService.getPrayerTimes(
        date: DateTime.now().toUtc(),
        latitude: loc.latitude,
        longitude: loc.longitude,
      );

      PrayerParser.parsePrayerTimes(times, prayerTimes);

      // Fasting
      await FastingParser.parseFasting(loc, fasting, prayerTimes);

      // Zakat
      await ZakatParser.parseNisab(loc, nisab);
    } catch (e) {
      lastApiRaw.value = 'Error: ${e.toString()}';
      fasting.value = 'Error loading data';
      nisab.value = 'Error';
      prayerTimes.clear();
    } finally {
      _loading.value = false;
    }
  }
}
