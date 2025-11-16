import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../services/api_service.dart';
import '../../services/prayer_service.dart';
import '../../services/zakat_service.dart';

class OfflineHandler {
  static Future<void> handleOffline({
    required prayerTimes,
    required fasting,
    required nisab,
    required dateReadable,
    required hijri,
    required gregorian,
    required qibla,
    required qiblaDegrees,
    required prohibitedTimes,
    required lastUpdated,
    required lastApiRaw,
    required isOfflineCached,
  }) async {
    final cachedPrayer = await ApiService.getCachedWithMeta('cache_prayer');

    if (cachedPrayer == null) {
      Get.snackbar('Warning', 'Internet not detected and no cached data found');
      prayerTimes.clear();
      fasting.value = 'Unavailable';
      nisab.value = 'Unavailable';
      return;
    }

    isOfflineCached.value = true;

    final cachedBody = cachedPrayer['body'];
    lastApiRaw.value = json.encode(cachedBody);

    final parsed = PrayerService.parseApiTimings(cachedBody);

    final fmt = DateFormat.jm();
    prayerTimes.clear();
    parsed?.forEach((k, v) {
      prayerTimes[k] = fmt.format(v.toLocal());
    });

    final data = cachedBody['data'];

    dateReadable.value = data['date']?['readable'] ?? '';
    hijri.value =
        '${data['date']?['hijri']?['day']} ${data['date']?['hijri']?['month']?['en']} ${data['date']?['hijri']?['year']}';
    gregorian.value = data['date']?['gregorian']?['date'] ?? '';

    final qb = data['qibla'];
    if (qb != null) {
      qibla.value =
          '${qb['direction']?['degrees']}° — ${qb['distance']?['value']}';
      qiblaDegrees.value =
          (qb['direction']?['degrees'] as num?)?.toDouble() ?? 0.0;
    }

    prohibitedTimes.clear();
    final prob = data['prohibited_times'];
    prob?.forEach((k, v) {
      prohibitedTimes[k] = '${v['start']} - ${v['end']}';
    });

    final cachedFasting = await ApiService.getCachedWithMeta('cache_fasting');
    if (cachedFasting != null) {
      fasting.value = json.encode(cachedFasting['body']);
    }

    final cachedZakat = await ApiService.getCachedWithMeta('cache_zakat_nisab');
    if (cachedZakat != null) {
      nisab.value =
          ZakatService.parseFromApiMap(cachedZakat['body']) ?? 'Unavailable';
    }
  }
}
