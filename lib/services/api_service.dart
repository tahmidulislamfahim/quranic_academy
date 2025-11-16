import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quranic_academy/secrets.dart';

class ApiService {
  static String? get apiKey {
    if (kIslamicApiKey.isNotEmpty) return kIslamicApiKey;
    return null;
  }

  static const String defaultBase = 'https://islamicapi.com/api/v1';

  static Future<Map<String, dynamic>?> fetchPrayer(
    double lat,
    double lon, {
    int method = 3,
    int school = 1,
  }) async {
    final uri = Uri.parse('$defaultBase/prayer-time/').replace(
      queryParameters: {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'method': method.toString(),
        'school': school.toString(),
        if (apiKey != null) 'api_key': apiKey!,
      },
    );

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final Map<String, dynamic> body =
            json.decode(res.body) as Map<String, dynamic>;
        // cache with timestamp
        try {
          final wrapper = json.encode({
            'ts': DateTime.now().toIso8601String(),
            'body': body,
          });
          SharedPreferences.getInstance().then((prefs) {
            prefs.setString('cache_prayer', wrapper);
          });
        } catch (_) {}
        return body;
      }
      // ignore: empty_catches
    } catch (e) {}
    return null;
  }

  static Future<Map<String, dynamic>?> fetchZakat(
    double lat,
    double lon,
  ) async {
    // legacy zakat endpoint; kept for compatibility.
    final uri = Uri.parse('$defaultBase/zakat/').replace(
      queryParameters: {
        'lat': lat.toString(),
        'lon': lon.toString(),
        if (apiKey != null) 'api_key': apiKey!,
      },
    );

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final Map<String, dynamic> body =
            json.decode(res.body) as Map<String, dynamic>;
        try {
          final wrapper = json.encode({
            'ts': DateTime.now().toIso8601String(),
            'body': body,
          });
          SharedPreferences.getInstance().then((prefs) {
            prefs.setString('cache_zakat', wrapper);
          });
        } catch (_) {}
        return body;
      }
    } catch (_) {}
    return null;
  }

  /// Fetch fasting info for a location
  static Future<Map<String, dynamic>?> fetchFasting(
    double lat,
    double lon,
  ) async {
    final uri = Uri.parse('$defaultBase/fasting/').replace(
      queryParameters: {
        'lat': lat.toString(),
        'lon': lon.toString(),
        if (apiKey != null) 'api_key': apiKey!,
      },
    );

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final Map<String, dynamic> body =
            json.decode(res.body) as Map<String, dynamic>;
        try {
          final wrapper = json.encode({
            'ts': DateTime.now().toIso8601String(),
            'body': body,
          });
          SharedPreferences.getInstance().then((prefs) {
            prefs.setString('cache_fasting', wrapper);
          });
        } catch (_) {}
        return body;
      }
    } catch (_) {}
    return null;
  }

  /// Fetch zakat nisab info. Defaults: classical standard, BDT currency, grams unit.
  static Future<Map<String, dynamic>?> fetchZakatNisab({
    String standard = 'classical',
    String currency = 'bdt',
    String unit = 'g',
  }) async {
    final uri = Uri.parse('$defaultBase/zakat-nisab/').replace(
      queryParameters: {
        'standard': standard,
        'currency': currency,
        'unit': unit,
        if (apiKey != null) 'api_key': apiKey!,
      },
    );

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final Map<String, dynamic> body =
            json.decode(res.body) as Map<String, dynamic>;
        try {
          final wrapper = json.encode({
            'ts': DateTime.now().toIso8601String(),
            'body': body,
          });
          SharedPreferences.getInstance().then((prefs) {
            prefs.setString('cache_zakat_nisab', wrapper);
          });
        } catch (_) {}
        return body;
      }
    } catch (_) {}
    return null;
  }

  /// Quick internet reachability check.
  /// Uses Google's generate_204 endpoint which returns 204 when online.
  static Future<bool> hasInternet({
    Duration timeout = const Duration(seconds: 4),
  }) async {
    try {
      final uri = Uri.parse('https://clients3.google.com/generate_204');
      final res = await http.get(uri).timeout(timeout);
      return res.statusCode == 204 || res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Retrieve a cached API response by key.
  static Future<Map<String, dynamic>?> getCached(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = prefs.getString(key);
      if (s == null) return null;
      // Stored wrapper: { ts: ISO8601, body: { ... } }
      final wrapper = json.decode(s) as Map<String, dynamic>;
      return wrapper;
    } catch (_) {
      return null;
    }
  }

  /// Retrieve cached body and timestamp (returns null if none).
  static Future<Map<String, dynamic>?> getCachedWithMeta(String key) async {
    final wrapper = await getCached(key);
    if (wrapper == null) return null;
    try {
      final ts = wrapper['ts']?.toString();
      final body = wrapper['body'];
      return {'ts': ts, 'body': body};
    } catch (_) {
      return null;
    }
  }
}
