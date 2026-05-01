import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class _CacheEntry<T> {
  final T value;
  final DateTime timestamp;
  _CacheEntry(this.value) : timestamp = DateTime.now();
  bool get isExpired => DateTime.now().difference(timestamp).inMinutes >= 60;
}

class StockApiService {
  static const String _apiKey = String.fromEnvironment('ALPHA_VANTAGE_KEY', defaultValue: '');
  static const String _baseUrl = 'https://www.alphavantage.co/query';
  static const String _coingeckoUrl = 'https://api.coingecko.com/api/v3';

  final Map<String, _CacheEntry<Map<String, dynamic>?>> _stockCache = {};
  final Map<String, _CacheEntry<double>> _cryptoCache = {};
  DateTime? _lastAlphaVantageCall;

  void clearCache() {
    _stockCache.clear();
    _cryptoCache.clear();
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

  /// Lookup stock/ETF by symbol and get current price.
  /// Supports international symbols like VUAA.LON, DHER.DEX, etc.
  /// Returns a map with 'symbol', 'name', and 'price' if successful.
  /// Returns null if the symbol is not found or there's an error.
  Future<Map<String, dynamic>?> lookupStock(String symbol) async {
    final cached = _stockCache[symbol];
    if (cached != null && !cached.isExpired) {
      return cached.value;
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
            _stockCache[symbol] = _CacheEntry(null);
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
            _stockCache[symbol] = _CacheEntry(result);
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

  /// Search for stock/ETF symbols by keyword.
  /// Returns matches with symbol, name, type, region, and currency.
  /// Supports ETFs, equities, and international exchanges.
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

  /// Fetch current prices for multiple crypto assets in one request.
  /// [symbols] can be ticker symbols (BTC, ETH) or CoinGecko IDs (bitcoin).
  /// Returns a map of original symbol → price in USD.
  Future<Map<String, double>> lookupCryptoPrices(List<String> symbols) async {
    if (symbols.isEmpty) return {};

    final Map<String, double> result = {};
    final List<String> uncached = [];

    for (final symbol in symbols) {
      final cached = _cryptoCache[symbol];
      if (cached != null && !cached.isExpired) {
        result[symbol] = cached.value;
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
            _cryptoCache[uncached[i]] = _CacheEntry(price);
          }
        }
      }
      return result;
    } catch (e) {
      debugPrint('Error fetching crypto prices: $e');
      return result;
    }
  }
}
