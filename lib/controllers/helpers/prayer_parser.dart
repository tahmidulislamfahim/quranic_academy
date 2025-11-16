import 'package:intl/intl.dart';

class PrayerParser {
  static void parsePrayerTimes(Map<String, DateTime> times, map) {
    final fmt = DateFormat.jm();
    map.clear();

    times.forEach((key, value) {
      map[key] = fmt.format(value.toLocal());
    });
  }
}
