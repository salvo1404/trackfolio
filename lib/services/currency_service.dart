import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService extends ChangeNotifier {
  static const _cacheKey = 'exchange_rates';
  static const _cacheTimestampKey = 'exchange_rates_timestamp';
  static const _cacheDuration = Duration(hours: 24);

  static const Map<String, double> _fallbackRates = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.79,
    'JPY': 149.50,
    'CNY': 7.24,
    'INR': 83.12,
    'AUD': 1.52,
    'CAD': 1.36,
    'CHF': 0.88,
    'BRL': 4.97,
    'ZAR': 18.65,
    'MXN': 17.15,
    'AED': 3.67,
  };

  static const Map<String, String> _currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'CNY': '¥',
    'INR': '₹',
    'AUD': 'A\$',
    'CAD': 'C\$',
    'CHF': 'CHF',
    'BRL': 'R\$',
    'ZAR': 'R',
    'MXN': 'MX\$',
    'AED': 'د.إ',
  };

  final SharedPreferences _prefs;
  Map<String, double> _rates = Map.of(_fallbackRates);
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  CurrencyService(this._prefs) {
    _loadCachedRates();
    _refreshIfStale();
  }

  void _loadCachedRates() {
    final cached = _prefs.getString(_cacheKey);
    if (cached != null) {
      try {
        final map = jsonDecode(cached) as Map<String, dynamic>;
        _rates = map.map((k, v) => MapEntry(k, (v as num).toDouble()));
      } catch (_) {}
    }
  }

  bool get _isCacheStale {
    final timestamp = _prefs.getInt(_cacheTimestampKey);
    if (timestamp == null) return true;
    final cached = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(cached) > _cacheDuration;
  }

  Future<void> _refreshIfStale() async {
    if (_isCacheStale) await refreshRates();
  }

  Future<void> refreshRates() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http
          .get(Uri.parse('https://open.er-api.com/v6/latest/USD'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final apiRates = data['rates'] as Map<String, dynamic>?;
        if (apiRates != null) {
          final newRates = <String, double>{};
          for (final code in _fallbackRates.keys) {
            final rate = apiRates[code];
            if (rate != null) {
              newRates[code] = (rate as num).toDouble();
            } else {
              newRates[code] = _fallbackRates[code]!;
            }
          }
          _rates = newRates;
          await _prefs.setString(_cacheKey, jsonEncode(_rates));
          await _prefs.setInt(
            _cacheTimestampKey,
            DateTime.now().millisecondsSinceEpoch,
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch exchange rates: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double convert(double amountInUSD, String targetCurrency) {
    final rate = _rates[targetCurrency] ?? 1.0;
    return amountInUSD * rate;
  }

  double convertBetween(double amount, String fromCurrency, String toCurrency) {
    final rateFrom = _rates[fromCurrency] ?? 1.0;
    final amountInUSD = amount / rateFrom;
    return convert(amountInUSD, toCurrency);
  }

  String getSymbol(String currencyCode) {
    return _currencySymbols[currencyCode] ?? '\$';
  }

  double getRate(String currencyCode) {
    return _rates[currencyCode] ?? 1.0;
  }
}
