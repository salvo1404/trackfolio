import 'dart:convert';
import 'package:http/http.dart' as http;

class StockApiService {
  // Pass via: flutter run --dart-define=ALPHA_VANTAGE_KEY=your_key
  // Get a free API key at: https://www.alphavantage.co/support/#api-key
  static const String _apiKey = String.fromEnvironment('ALPHA_VANTAGE_KEY', defaultValue: '');
  static const String _baseUrl = 'https://www.alphavantage.co/query';

  /// Lookup stock/ETF by symbol and get current price.
  /// Supports international symbols like VUAA.LON, DHER.DEX, etc.
  /// Returns a map with 'symbol', 'name', and 'price' if successful.
  /// Returns null if the symbol is not found or there's an error.
  Future<Map<String, dynamic>?> lookupStock(String symbol) async {
    try {
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
            return null;
          }

          final price = quote['05. price'];
          final symbolName = quote['01. symbol'];

          if (price != null && symbolName != null) {
            return {
              'symbol': symbolName,
              'price': double.tryParse(price.toString()) ?? 0.0,
              'name': symbolName,
            };
          }
        }

        if (data.containsKey('Note') || data.containsKey('Error Message')) {
          throw Exception(data['Note'] ?? data['Error Message']);
        }
      }

      return null;
    } catch (e) {
      print('Error fetching stock data: $e');
      return null;
    }
  }

  /// Search for stock/ETF symbols by keyword.
  /// Returns matches with symbol, name, type, region, and currency.
  /// Supports ETFs, equities, and international exchanges.
  Future<List<Map<String, String>>> searchSymbols(String keyword) async {
    try {
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
      print('Error searching symbols: $e');
      return [];
    }
  }
}
