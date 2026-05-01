import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StockApiService {
  static const String _apiKey = String.fromEnvironment('ALPHA_VANTAGE_KEY', defaultValue: '');
  static const String _baseUrl = 'https://www.alphavantage.co/query';
  static const String _coingeckoUrl = 'https://api.coingecko.com/api/v3';

  static const _stockCacheKey = 'stock_prices_cache';
  static const _stockTimestampKey = 'stock_prices_timestamp';
  static const _cryptoCacheKey = 'crypto_prices_cache';
  static const _cryptoTimestampKey = 'crypto_prices_timestamp';
  static const _cacheDuration = Duration(hours: 24);

  final SharedPreferences _prefs;
  final Map<String, Map<String, dynamic>?> _stockCache = {};
  final Map<String, double> _cryptoCache = {};
  DateTime? _lastAlphaVantageCall;

  StockApiService(this._prefs) {
    _loadCachedPrices();
  }

  void _loadCachedPrices() {
    final stockJson = _prefs.getString(_stockCacheKey);
    if (stockJson != null) {
      try {
        final map = jsonDecode(stockJson) as Map<String, dynamic>;
        for (final entry in map.entries) {
          if (entry.value == null) {
            _stockCache[entry.key] = null;
          } else {
            _stockCache[entry.key] = Map<String, dynamic>.from(entry.value as Map);
          }
        }
      } catch (_) {}
    }

    final cryptoJson = _prefs.getString(_cryptoCacheKey);
    if (cryptoJson != null) {
      try {
        final map = jsonDecode(cryptoJson) as Map<String, dynamic>;
        _cryptoCache.addAll(map.map((k, v) => MapEntry(k, (v as num).toDouble())));
      } catch (_) {}
    }
  }

  bool _isCacheStale(String timestampKey) {
    final timestamp = _prefs.getInt(timestampKey);
    if (timestamp == null) return true;
    final cached = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(cached) > _cacheDuration;
  }

  Future<void> _persistStockCache() async {
    await _prefs.setString(_stockCacheKey, jsonEncode(_stockCache));
    await _prefs.setInt(_stockTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _persistCryptoCache() async {
    await _prefs.setString(_cryptoCacheKey, jsonEncode(_cryptoCache));
    await _prefs.setInt(_cryptoTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  void clearCache() {
    _stockCache.clear();
    _cryptoCache.clear();
    _prefs.remove(_stockCacheKey);
    _prefs.remove(_stockTimestampKey);
    _prefs.remove(_cryptoCacheKey);
    _prefs.remove(_cryptoTimestampKey);
  }

  static const Map<String, String> _cryptoSymbolToId = {
    'BTC': 'bitcoin',
    'ETH': 'ethereum',
    'SOL': 'solana',
    'ADA': 'cardano',
    'DOT': 'polkadot',
    'DOGE': 'dogecoin',
    'XRP': 'ripple',
    'AVAX': 'avalanche-2',
    'MATIC': 'matic-network',
    'LINK': 'chainlink',
    'UNI': 'uniswap',
    'ATOM': 'cosmos',
    'LTC': 'litecoin',
    'BNB': 'binancecoin',
    'SHIB': 'shiba-inu',
    'ARB': 'arbitrum',
    'OP': 'optimism',
    'APT': 'aptos',
    'SUI': 'sui',
    'NEAR': 'near',
    'FIL': 'filecoin',
    'AAVE': 'aave',
    'MKR': 'maker',
    'CRO': 'crypto-com-chain',
    'ALGO': 'algorand',
    'XLM': 'stellar',
    'PEPE': 'pepe',
  };

  Future<Map<String, dynamic>?> lookupStock(String symbol) async {
    final cached = _stockCache[symbol];
    if (cached != null && !_isCacheStale(_stockTimestampKey)) {
      return cached;
    }

    try {
      await _throttleAlphaVantage();
      final uri = Uri.parse(
        '$_baseUrl?function=GLOBAL_QUOTE&symbol=$symbol&apikey=$_apiKey',
      );

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey('Global Quote')) {
          final quote = data['Global Quote'] as Map<String, dynamic>;

          if (quote.isEmpty) {
            _stockCache[symbol] = null;
            await _persistStockCache();
            return null;
          }

          final price = quote['05. price'];
          final symbolName = quote['01. symbol'];

          if (price != null && symbolName != null) {
            final result = {
              'symbol': symbolName,
              'price': double.tryParse(price.toString()) ?? 0.0,
              'name': symbolName,
            };
            _stockCache[symbol] = result;
            await _persistStockCache();
            return result;
          }
        }

        if (data.containsKey('Note') || data.containsKey('Error Message')) {
          throw Exception(data['Note'] ?? data['Error Message']);
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching stock data: $e');
      return null;
    }
  }

  Future<List<Map<String, String>>> searchSymbols(String keyword) async {
    try {
      await _throttleAlphaVantage();
      final uri = Uri.parse(
        '$_baseUrl?function=SYMBOL_SEARCH&keywords=$keyword&apikey=$_apiKey',
      );

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey('bestMatches')) {
          final matches = data['bestMatches'] as List;
          return matches.map((match) {
            return {
              'symbol': match['1. symbol']?.toString() ?? '',
              'name': match['2. name']?.toString() ?? '',
              'type': match['3. type']?.toString() ?? '',
              'region': match['4. region']?.toString() ?? '',
              'currency': match['8. currency']?.toString() ?? '',
            };
          }).toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error searching symbols: $e');
      return [];
    }
  }

  Future<void> _throttleAlphaVantage() async {
    if (_lastAlphaVantageCall != null) {
      final elapsed = DateTime.now().difference(_lastAlphaVantageCall!);
      if (elapsed < const Duration(seconds: 2)) {
        await Future.delayed(const Duration(seconds: 2) - elapsed);
      }
    }
    _lastAlphaVantageCall = DateTime.now();
  }

  String _resolveCryptoId(String symbol) {
    final upper = symbol.toUpperCase().trim();
    return _cryptoSymbolToId[upper] ?? symbol.toLowerCase().trim();
  }

  Future<Map<String, double>> lookupCryptoPrices(List<String> symbols) async {
    if (symbols.isEmpty) return {};

    final Map<String, double> result = {};
    final List<String> uncached = [];
    final bool stale = _isCacheStale(_cryptoTimestampKey);

    for (final symbol in symbols) {
      final cached = _cryptoCache[symbol];
      if (cached != null && !stale) {
        result[symbol] = cached;
      } else {
        uncached.add(symbol);
      }
    }

    if (uncached.isEmpty) return result;

    try {
      final ids = uncached.map(_resolveCryptoId).toList();
      final idsParam = ids.join(',');
      final uri = Uri.parse(
        '$_coingeckoUrl/simple/price?ids=$idsParam&vs_currencies=usd',
      );

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        for (int i = 0; i < uncached.length; i++) {
          final id = ids[i];
          if (data.containsKey(id) && data[id]['usd'] != null) {
            final price = (data[id]['usd'] as num).toDouble();
            result[uncached[i]] = price;
            _cryptoCache[uncached[i]] = price;
          }
        }
        await _persistCryptoCache();
      }
      return result;
    } catch (e) {
      debugPrint('Error fetching crypto prices: $e');
      return result;
    }
  }
}
