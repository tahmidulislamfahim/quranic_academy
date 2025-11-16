import 'api_service.dart';
import 'package:intl/intl.dart';

class ZakatService {
  /// Returns a display string for nisab. Attempts to fetch from the
  /// `zakat-nisab` endpoint then falls back to a legacy `zakat` endpoint
  /// (which may accept lat/lon), and finally to grams if nothing available.
  static Future<String> getNisab({double? latitude, double? longitude}) async {
    const goldNisabGrams = 85.0;
    const silverNisabGrams = 595.0;

    // Preferred endpoint: zakat-nisab with currency BDT and grams unit
    final nisabApi = await ApiService.fetchZakatNisab(
      currency: 'bdt',
      unit: 'g',
    );
    if (nisabApi != null) {
      try {
        if (nisabApi.containsKey('data') && nisabApi['data'] is Map) {
          final data = nisabApi['data'] as Map<String, dynamic>;
          // New API shape includes nisab_thresholds -> gold / silver
          if (data.containsKey('nisab_thresholds') &&
              data['nisab_thresholds'] is Map) {
            final thresholds = data['nisab_thresholds'] as Map<String, dynamic>;
            final nf = NumberFormat('#,##0.##');
            String? goldStr;
            String? silverStr;

            if (thresholds.containsKey('gold') && thresholds['gold'] is Map) {
              final g = thresholds['gold'] as Map<String, dynamic>;
              final weight = g['weight'] ?? g['grams'] ?? g['weight_in_grams'];
              final nisabAmt =
                  g['nisab_amount'] ?? g['nisab_value'] ?? g['nisab'];
              if (weight != null && nisabAmt != null) {
                goldStr =
                    'Gold: ${weight.toString()} g ≈ ${nf.format((nisabAmt as num).toDouble())} BDT';
              }
            }

            if (thresholds.containsKey('silver') &&
                thresholds['silver'] is Map) {
              final s = thresholds['silver'] as Map<String, dynamic>;
              final weight = s['weight'] ?? s['grams'] ?? s['weight_in_grams'];
              final nisabAmt =
                  s['nisab_amount'] ?? s['nisab_value'] ?? s['nisab'];
              if (weight != null && nisabAmt != null) {
                silverStr =
                    'Silver: ${weight.toString()} g ≈ ${nf.format((nisabAmt as num).toDouble())} BDT';
              }
            }

            final parts = <String>[];
            if (goldStr != null) parts.add(goldStr);
            if (silverStr != null) parts.add(silverStr);
            if (parts.isNotEmpty) {
              final out = parts.join(' • ');
              try {
                // ignore: avoid_print
                print('ZakatService: returning nisab => $out');
              } catch (_) {}
              return out;
            }
          }

          if (data.containsKey('nisab')) return data['nisab'].toString();
          if (data.containsKey('nisab_value'))
            return data['nisab_value'].toString();
          if (data.containsKey('gold_price') && data['gold_price'] is Map) {
            final gp = data['gold_price'] as Map<String, dynamic>;
            if (gp.containsKey('per_gram') && gp['per_gram'] != null) {
              final gold = (gp['per_gram'] as num).toDouble();
              final nisabValue = goldNisabGrams * gold;
              return 'Nisab (gold): ${goldNisabGrams.toStringAsFixed(0)} g ≈ ${nisabValue.toStringAsFixed(2)} BDT';
            }
          }
        }
      } catch (_) {}
    }

    // Fallback: try legacy zakat endpoint if we have location
    if (latitude != null && longitude != null) {
      final api = await ApiService.fetchZakat(latitude, longitude);
      if (api != null) {
        try {
          if (api.containsKey('data') && api['data'] is Map) {
            final data = api['data'] as Map<String, dynamic>;
            if (data.containsKey('nisab')) return data['nisab'].toString();
            if (data.containsKey('gold_price_per_gram')) {
              final gold = (data['gold_price_per_gram'] as num).toDouble();
              final nisabValue = goldNisabGrams * gold;
              return 'Nisab (gold): ${goldNisabGrams.toStringAsFixed(0)} g ≈ ${nisabValue.toStringAsFixed(2)} (local currency)';
            }
          }
        } catch (_) {}
      }
    }

    // Last resort: present nisab in grams
    return 'Nisab: $goldNisabGrams g gold (or $silverNisabGrams g silver)';
  }

  /// Parse a cached API response map and return a display string if possible.
  static String? parseFromApiMap(Map<String, dynamic>? nisabApi) {
    if (nisabApi == null) return null;
    try {
      if (nisabApi.containsKey('data') && nisabApi['data'] is Map) {
        final data = nisabApi['data'] as Map<String, dynamic>;
        if (data.containsKey('nisab_thresholds') &&
            data['nisab_thresholds'] is Map) {
          final thresholds = data['nisab_thresholds'] as Map<String, dynamic>;
          final nf = NumberFormat('#,##0.##');
          String? goldStr;
          String? silverStr;

          if (thresholds.containsKey('gold') && thresholds['gold'] is Map) {
            final g = thresholds['gold'] as Map<String, dynamic>;
            final weight = g['weight'] ?? g['grams'] ?? g['weight_in_grams'];
            final nisabAmt =
                g['nisab_amount'] ?? g['nisab_value'] ?? g['nisab'];
            if (weight != null && nisabAmt != null) {
              goldStr =
                  'Gold: ${weight.toString()} g ≈ ${nf.format((nisabAmt as num).toDouble())} BDT';
            }
          }

          if (thresholds.containsKey('silver') && thresholds['silver'] is Map) {
            final s = thresholds['silver'] as Map<String, dynamic>;
            final weight = s['weight'] ?? s['grams'] ?? s['weight_in_grams'];
            final nisabAmt =
                s['nisab_amount'] ?? s['nisab_value'] ?? s['nisab'];
            if (weight != null && nisabAmt != null) {
              silverStr =
                  'Silver: ${weight.toString()} g ≈ ${nf.format((nisabAmt as num).toDouble())} BDT';
            }
          }

          final parts = <String>[];
          if (goldStr != null) parts.add(goldStr);
          if (silverStr != null) parts.add(silverStr);
          if (parts.isNotEmpty) return parts.join(' • ');
        }

        if (data.containsKey('nisab')) return data['nisab'].toString();
        if (data.containsKey('nisab_value'))
          return data['nisab_value'].toString();
      }
    } catch (_) {}
    return null;
  }
}
