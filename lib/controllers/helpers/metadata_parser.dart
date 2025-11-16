class MetaDataParser {
  static void parseMetadata(
    Map<String, dynamic> apiRaw,
    dateReadable,
    hijri,
    gregorian,
    qibla,
    qiblaDegrees,
    prohibitedTimes,
  ) {
    if (!apiRaw.containsKey('data')) return;

    final data = apiRaw['data'];

    try {
      dateReadable.value = data['date']?['readable'] ?? '';

      final h = data['date']?['hijri'];
      if (h != null) {
        hijri.value = '${h['day']} ${h['month']?['en']} ${h['year']}';
      }

      final g = data['date']?['gregorian'];
      if (g != null) gregorian.value = g['date'];

      final qb = data['qibla'];
      if (qb != null) {
        final dir = qb['direction']?['degrees'];
        final dist = qb['distance']?['value'];
        final unit = qb['distance']?['unit'];

        if (dir != null) {
          qibla.value = '$dir° — $dist $unit';
          qiblaDegrees.value = (dir as num).toDouble();
        }
      }

      final prob = data['prohibited_times'];
      if (prob != null) {
        prohibitedTimes.clear();
        prob.forEach((key, value) {
          final start = value['start'];
          final end = value['end'];
          prohibitedTimes[key] = '$start - $end';
        });
      }
    } catch (_) {}
  }
}
