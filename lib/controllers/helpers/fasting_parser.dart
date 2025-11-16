import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class FastingParser {
  static Future<void> parseFasting(loc, fasting, prayerTimes) async {
    final fmt = DateFormat.jm();

    final fastingApi = await ApiService.fetchFasting(
      loc.latitude,
      loc.longitude,
    );
    if (fastingApi == null) {
      fasting.value = 'No fasting data (network)';
      return;
    }

    try {
      final data = fastingApi['data'] ?? fastingApi['timings'];

      if (data == null) {
        fasting.value = 'No fasting data (response)';
        return;
      }

      // Newer API returns a structure like: data.fasting = [ { date, hijri, time: { sahur, iftar, duration } } ]
      String? start;
      String? end;
      String? durationStr;

      try {
        if (data is Map && data.containsKey('fasting')) {
          final list = data['fasting'];
          if (list is List && list.isNotEmpty) {
            final first = list.first;
            final timeMap = (first is Map)
                ? (first['time'] ?? first['timings'] ?? first)
                : null;
            if (timeMap is Map) {
              start =
                  timeMap['sahur'] ??
                  timeMap['fajr'] ??
                  timeMap['start'] ??
                  timeMap['imsak'];
              end = timeMap['iftar'] ?? timeMap['maghrib'] ?? timeMap['end'];
              durationStr = timeMap['duration'] ?? first['duration'];
            }
          }
        }
      } catch (_) {}

      // Fallback to legacy shape
      start ??= data['fajr'] ?? data['start'] ?? data['imsak'];
      end ??= data['maghrib'] ?? data['iftar'] ?? data['end'];

      if (start != null && end != null) {
        final now = DateTime.now();

        final s = DateFormat('HH:mm').parse(start);
        final e = DateFormat('HH:mm').parse(end);

        final from = DateTime(now.year, now.month, now.day, s.hour, s.minute);
        final to = DateTime(now.year, now.month, now.day, e.hour, e.minute);

        final dur = to.difference(from);

        final durText = durationStr?.toString().trim().isNotEmpty == true
            ? durationStr!
            : '${dur.inHours}h ${dur.inMinutes.remainder(60)}m';

        fasting.value = '${fmt.format(from)} → ${fmt.format(to)} ($durText)';
      } else {
        fasting.value = 'No fasting time found in API response';
      }
    } catch (e) {
      fasting.value = 'Error parsing fasting data';
    }
  }
}
