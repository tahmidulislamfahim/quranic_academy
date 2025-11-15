import 'dart:convert';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/prayer_service.dart';
import '../services/zakat_service.dart';
import '../services/api_service.dart';

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
      // Quick internet check — if offline, show snackbar and use placeholder data.
      final online = await ApiService.hasInternet();
      if (!online) {
        // Try to load cached API responses first
        final cachedPrayer = await ApiService.getCachedWithMeta('cache_prayer');
        final cachedFasting = await ApiService.getCachedWithMeta(
          'cache_fasting',
        );
        final cachedZakat = await ApiService.getCachedWithMeta(
          'cache_zakat_nisab',
        );

        const cacheExpiry = Duration(hours: 6);

        // If we have a cached prayer payload, prefer that as it contains most metadata
        if (cachedPrayer != null && cachedPrayer['body'] != null) {
          try {
            final ts = cachedPrayer['ts']?.toString();
            if (ts != null) {
              final dt = DateTime.parse(ts);
              lastUpdated.value = dt;
              final age = DateTime.now().difference(dt);
              if (age > cacheExpiry) {
                Get.snackbar(
                  'Offline',
                  'Cached data is older than ${cacheExpiry.inHours}h and may be stale',
                );
              }
            }
          } catch (_) {}

          isOfflineCached.value = true;
          Get.snackbar('Offline', 'No internet — showing last cached data');

          final cachedBody = cachedPrayer['body'] as Map<String, dynamic>;
          try {
            lastApiRaw.value = json.encode(cachedBody);
          } catch (_) {}

          // parse prayer timings
          try {
            final parsed = PrayerService.parseApiTimings(cachedBody);
            prayerTimes.clear();
            final fmt = DateFormat.jm();
            if (parsed != null) {
              parsed.forEach((k, v) {
                prayerTimes[k] = fmt.format(v.toLocal());
              });
            }

            // metadata (date, hijri, gregorian, qibla, prohibited_times)
            if (cachedBody.containsKey('data') && cachedBody['data'] is Map) {
              final data = cachedBody['data'] as Map<String, dynamic>;
              dateReadable.value =
                  data['date']?['readable']?.toString() ??
                  DateFormat.yMMMMd().format(DateTime.now());

              final hij = data['date']?['hijri'];
              if (hij is Map) {
                final hijDate = hij['date'] ?? '';
                final hijReadable = hij['day'] != null && hij['month'] != null
                    ? '${hij['day']} ${hij['month']?['en'] ?? ''} ${hij['year'] ?? ''}'
                    : hijDate;
                hijri.value = hijReadable.toString();
              }

              final gro = data['date']?['gregorian'];
              if (gro is Map) {
                final gDate = gro['date'] ?? '';
                gregorian.value = gDate.toString();
              }

              final qb = data['qibla'];
              if (qb is Map) {
                final dir = qb['direction']?['degrees'];
                final dist = qb['distance']?['value'];
                final unit = qb['distance']?['unit'];
                if (dir != null) {
                  qibla.value =
                      '${dir.toString()}° — ${dist?.toString() ?? 'N/A'} ${unit ?? ''}';
                  try {
                    qiblaDegrees.value = (dir as num).toDouble();
                  } catch (_) {}
                }
              }

              final prob = data['prohibited_times'];
              if (prob is Map) {
                prohibitedTimes.clear();
                prob.forEach((k, v) {
                  try {
                    if (v is Map) {
                      final start = v['start']?.toString() ?? '';
                      final end = v['end']?.toString() ?? '';
                      prohibitedTimes[k] = '$start - $end';
                    }
                  } catch (_) {}
                });
              }
            }
          } catch (_) {}

          // fasting from cached fasting if present
          if (cachedFasting != null && cachedFasting['body'] != null) {
            try {
              final fastingBody = cachedFasting['body'] as Map<String, dynamic>;
              Map<String, dynamic>? data;
              if (fastingBody.containsKey('data') &&
                  fastingBody['data'] is Map) {
                data = fastingBody['data'] as Map<String, dynamic>;
              } else if (fastingBody['timings'] is Map) {
                data = fastingBody['timings'] as Map<String, dynamic>;
              } else {
                data = Map<String, dynamic>.from(fastingBody);
              }

              String? start;
              String? end;
              for (final key in [
                'imsak',
                'fajr',
                'start',
                'from',
                'start_time',
                'imsak_time',
              ]) {
                if (data.containsKey(key) && data[key] != null) {
                  start = data[key].toString();
                  break;
                }
              }
              for (final key in [
                'maghrib',
                'iftar',
                'end',
                'to',
                'end_time',
                'iftar_time',
              ]) {
                if (data.containsKey(key) && data[key] != null) {
                  end = data[key].toString();
                  break;
                }
              }

              if (start != null && end != null) {
                DateTime? parseTime(String s) {
                  try {
                    return DateFormat('HH:mm').parseStrict(s);
                  } catch (_) {
                    try {
                      return DateFormat.jm().parse(s);
                    } catch (_) {
                      return null;
                    }
                  }
                }

                final sdt = parseTime(start);
                final edt = parseTime(end);
                if (sdt != null && edt != null) {
                  final now = DateTime.now();
                  final from = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    sdt.hour,
                    sdt.minute,
                  );
                  final to = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    edt.hour,
                    edt.minute,
                  );
                  final dur = to.difference(from);
                  final fmt = DateFormat.jm();
                  fasting.value =
                      '${fmt.format(from)} → ${fmt.format(to)} (${dur.inHours}h ${dur.inMinutes.remainder(60)}m)';
                }
              }
            } catch (_) {}
          }

          // nisab from cached zakat if present
          if (cachedZakat != null && cachedZakat['body'] != null) {
            final parsedNisab = ZakatService.parseFromApiMap(
              cachedZakat['body'] as Map<String, dynamic>?,
            );
            if (parsedNisab != null) nisab.value = parsedNisab;
          }

          _loading.value = false;
          return;
        }

        // If no usable cache available, fallback to 'unavailable' states
        Get.snackbar(
          'Network',
          'Internet not detected and no cached data available',
          snackPosition: SnackPosition.BOTTOM,
        );

        prayerTimes.clear();
        fasting.value = 'Unavailable';
        nisab.value = 'Unavailable';
        dateReadable.value = '';
        gregorian.value = '';
        hijri.value = '';
        qibla.value = '';
        qiblaDegrees.value = 0.0;
        prohibitedTimes.clear();

        _loading.value = false;
        return;
      }
      // Request/check location permission before attempting to obtain location.
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        // Permission permanently denied — prompt user to open app settings.
        await Get.defaultDialog(
          title: 'Location permission',
          middleText:
              'Location permission is permanently denied. Open app settings to enable location for accurate prayer times.',
          textConfirm: 'Open Settings',
          textCancel: 'Continue (fallback)',
          onConfirm: () async {
            await Geolocator.openAppSettings();
            Get.back();
          },
        );
      }

      final loc = await LocationService.getLocation();
      // If permission was denied (or deniedForever) and we're using the Dhaka fallback,
      // notify the user so they know times may be inaccurate.
      if ((permission == LocationPermission.denied ||
              permission == LocationPermission.deniedForever) &&
          (loc.latitude == 23.8103 && loc.longitude == 90.4125)) {
        Get.snackbar(
          'Location',
          'Using Dhaka fallback — enable location for accurate times',
        );
      }
      final date = DateTime.now().toUtc();

      // Fetch raw API data to extract date, qibla and prohibited times
      final apiRaw = await ApiService.fetchPrayer(loc.latitude, loc.longitude);
      try {
        lastApiRaw.value = apiRaw != null ? json.encode(apiRaw) : '';
      } catch (_) {
        lastApiRaw.value = '';
      }

      final times = await PrayerService.getPrayerTimes(
        date: date,
        latitude: loc.latitude,
        longitude: loc.longitude,
      );

      // parse metadata from apiRaw if present
      if (apiRaw != null &&
          apiRaw.containsKey('data') &&
          apiRaw['data'] is Map) {
        final data = apiRaw['data'] as Map<String, dynamic>;
        try {
          dateReadable.value = data['date']?['readable']?.toString() ?? '';

          final hij = data['date']?['hijri'];
          if (hij is Map) {
            final hijDate = hij['date'] ?? '';
            final hijReadable = hij['day'] != null && hij['month'] != null
                ? '${hij['day']} ${hij['month']?['en'] ?? ''} ${hij['year'] ?? ''}'
                : hijDate;
            hijri.value = hijReadable.toString();
          }

          final gro = data['date']?['gregorian'];
          if (gro is Map) {
            final gDate = gro['date'] ?? '';
            gregorian.value = gDate.toString();
          }

          final qb = data['qibla'];
          if (qb is Map) {
            final dir = qb['direction']?['degrees'];
            final dist = qb['distance']?['value'];
            final unit = qb['distance']?['unit'];
            if (dir != null && dist != null) {
              qibla.value =
                  '${dir.toString()}° — ${dist.toString()} ${unit ?? ''}';
              try {
                qiblaDegrees.value = (dir as num).toDouble();
              } catch (_) {}
            }
          }

          final prob = data['prohibited_times'];
          if (prob is Map) {
            prohibitedTimes.clear();
            prob.forEach((k, v) {
              try {
                if (v is Map) {
                  final start = v['start']?.toString() ?? '';
                  final end = v['end']?.toString() ?? '';
                  prohibitedTimes[k] = '$start - $end';
                }
              } catch (_) {}
            });
          }
        } catch (_) {}
      }

      prayerTimes.clear();
      final fmt = DateFormat.jm();
      times.forEach((k, v) {
        prayerTimes[k] = fmt.format(v.toLocal());
      });

      // fasting: from Fajr (imsak) to Maghrib
      // Try to fetch fasting info from API first
      final fastingApi = await ApiService.fetchFasting(
        loc.latitude,
        loc.longitude,
      );
      bool fastingSet = false;
      if (fastingApi != null) {
        try {
          Map<String, dynamic>? data;
          if (fastingApi.containsKey('data') && fastingApi['data'] is Map) {
            data = fastingApi['data'] as Map<String, dynamic>;
          } else if (fastingApi['timings'] is Map) {
            data = fastingApi['timings'] as Map<String, dynamic>;
          } else {
            data = Map<String, dynamic>.from(fastingApi);
          }

          String? start;
          String? end;
          // common keys
          for (final key in [
            'imsak',
            'fajr',
            'start',
            'from',
            'start_time',
            'imsak_time',
          ]) {
            if (data.containsKey(key) && data[key] != null) {
              start = data[key].toString();
              break;
            }
          }
          for (final key in [
            'maghrib',
            'iftar',
            'end',
            'to',
            'end_time',
            'iftar_time',
          ]) {
            if (data.containsKey(key) && data[key] != null) {
              end = data[key].toString();
              break;
            }
          }

          if (start != null && end != null) {
            DateTime? parseTime(String s) {
              try {
                return DateFormat('HH:mm').parseStrict(s);
              } catch (_) {
                try {
                  return DateFormat.jm().parse(s);
                } catch (_) {
                  return null;
                }
              }
            }

            final sdt = parseTime(start);
            final edt = parseTime(end);
            if (sdt != null && edt != null) {
              final now = DateTime.now();
              final from = DateTime(
                now.year,
                now.month,
                now.day,
                sdt.hour,
                sdt.minute,
              );
              final to = DateTime(
                now.year,
                now.month,
                now.day,
                edt.hour,
                edt.minute,
              );
              final dur = to.difference(from);
              fasting.value =
                  '${fmt.format(from)} → ${fmt.format(to)} (${dur.inHours}h ${dur.inMinutes.remainder(60)}m)';
              fastingSet = true;
            }
          }
        } catch (_) {}
      }

      if (!fastingSet) {
        if (times.containsKey('fajr') && times.containsKey('maghrib')) {
          final from = times['fajr']!;
          final to = times['maghrib']!;
          final dur = to.difference(from);
          fasting.value =
              '${fmt.format(from.toLocal())} → ${fmt.format(to.toLocal())} (${dur.inHours}h ${dur.inMinutes.remainder(60)}m)';
        }
      }

      final nisabVal = await ZakatService.getNisab(
        latitude: loc.latitude,
        longitude: loc.longitude,
      );
      nisab.value = nisabVal;
    } catch (e) {
      try {
        lastApiRaw.value = 'Error: ${e.toString()}';
      } catch (_) {}
      prayerTimes.clear();
      fasting.value = 'Error loading data';
      nisab.value = 'Error';
    } finally {
      _loading.value = false;
    }
  }
}
