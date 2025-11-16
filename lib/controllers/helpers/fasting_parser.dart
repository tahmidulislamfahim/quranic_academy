import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class FastingParser {
  static Future<void> parseFasting(loc, fasting, prayerTimes) async {
    final fmt = DateFormat.jm();

    final fastingApi = await ApiService.fetchFasting(
      loc.latitude,
      loc.longitude,
    );

    if (fastingApi == null) return;

    try {
      final data = fastingApi['data'] ?? fastingApi['timings'];

      final start = data['fajr'] ?? data['start'] ?? data['imsak'];
      final end = data['maghrib'] ?? data['iftar'] ?? data['end'];

      if (start != null && end != null) {
        final now = DateTime.now();

        final s = DateFormat('HH:mm').parse(start);
        final e = DateFormat('HH:mm').parse(end);

        final from = DateTime(now.year, now.month, now.day, s.hour, s.minute);
        final to = DateTime(now.year, now.month, now.day, e.hour, e.minute);

        final dur = to.difference(from);

        fasting.value =
            '${fmt.format(from)} → ${fmt.format(to)} (${dur.inHours}h ${dur.inMinutes.remainder(60)}m)';
      }
    } catch (_) {}
  }
}
