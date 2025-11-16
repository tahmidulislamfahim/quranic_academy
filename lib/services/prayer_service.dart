import 'dart:async';
import 'package:intl/intl.dart';
import 'api_service.dart';

/// PrayerService queries the remote API for prayer times and falls back
/// to static values if the API fails.
class PrayerService {
  /// Returns prayer times map with keys: fajr, sunrise, dhuhr, asr, maghrib, isha
  static Future<Map<String, DateTime>> getPrayerTimes({
    required DateTime date,
    required double latitude,
    required double longitude,
  }) async {
    final api = await ApiService.fetchPrayer(
      latitude,
      longitude,
      method: 3,
      school: 1,
    );
    if (api != null) {
      final parsed = parseApiTimings(api);
      if (parsed != null && parsed.isNotEmpty) return parsed;
    }

    // Fallback static times (Bangladesh-appropriate defaults)
    final local = DateTime.now().toLocal();
    final baseDate = DateTime(local.year, local.month, local.day);

    DateTime at(int hour, int minute) =>
        DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);

    return {
      'fajr': at(5, 0),
      'sunrise': at(6, 20),
      'dhuhr': at(12, 30),
      'asr': at(15, 45),
      'maghrib': at(18, 10),
      'isha': at(19, 30),
    };
  }

  /// Parse API response map and return prayer times map or null if cannot parse
  static Map<String, DateTime>? parseApiTimings(Map<String, dynamic> api) {
    // Try to extract timings from common shapes (support 'times', 'timings', 'time')
    Map<String, dynamic>? timings;
    if (api.containsKey('data') && api['data'] is Map) {
      final data = api['data'] as Map<String, dynamic>;
      if (data.containsKey('times'))
        timings = data['times'] as Map<String, dynamic>;
      else if (data.containsKey('timings'))
        timings = data['timings'] as Map<String, dynamic>;
      else if (data.containsKey('time'))
        timings = data['time'] as Map<String, dynamic>;
      else if (data.keys.any(
        (k) => k.toString().toLowerCase().contains('fajr'),
      ))
        timings = data;
    } else if (api.containsKey('times')) {
      timings = api['times'] as Map<String, dynamic>;
    } else if (api.containsKey('timings')) {
      timings = api['timings'] as Map<String, dynamic>;
    } else if (api.containsKey('time')) {
      timings = api['time'] as Map<String, dynamic>;
    }

    if (timings != null) {
      final result = <String, DateTime>{};
      final fmt24 = DateFormat('HH:mm');
      final fmt12 = DateFormat.jm();
      final today = DateTime.now();

      timings.forEach((k, v) {
        try {
          final s = v.toString();
          DateTime dt;
          // Try 24-hour first
          try {
            final parsed = fmt24.parseStrict(s);
            dt = DateTime(
              today.year,
              today.month,
              today.day,
              parsed.hour,
              parsed.minute,
            );
          } catch (_) {
            final parsed = fmt12.parse(s);
            dt = DateTime(
              today.year,
              today.month,
              today.day,
              parsed.hour,
              parsed.minute,
            );
          }
          // store as local DateTime so formatting in UI is straightforward
          result[k.toLowerCase()] = dt;
        } catch (_) {}
      });

      if (result.isNotEmpty) return result;
    }

    return null;
  }
}
