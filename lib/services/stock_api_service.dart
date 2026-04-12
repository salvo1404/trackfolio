import 'dart:convert';
import 'package:http/http.dart' as http;

class StockApiService {
  // Alpha Vantage API key - IMPORTANT: Replace with your own key
  // Get a free API key at: https://www.alphavantage.co/support/#api-key
  static const String _apiKey = 'FXHX7WL780IL2WWG'; // Replace with your actual API key
  static const String _baseUrl = 'https://www.alphavantage.co/query';

  /// Lookup stock by symbol and get current price
  /// Returns a map with 'symbol', 'name', and 'price' if successful
  /// Returns null if the symbol is not found or there's an error
  Future<Map<String, dynamic>?> lookupStock(String symbol) async {
    try {
      // Alpha Vantage GLOBAL_QUOTE endpoint
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

        // Check if we got valid data
        if (data.containsKey('Global Quote')) {
          final quote = data['Global Quote'] as Map<String, dynamic>;

          // Alpha Vantage returns empty object if symbol not found
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

        // Check for API error messages
        if (data.containsKey('Note') || data.containsKey('Error Message')) {
          throw Exception(data['Note'] ?? data['Error Message']);
        }
      }

      return null;
    } catch (e) {
      // Log error but don't crash the app
      print('Error fetching stock data: $e');
      return null;
    }
  }

  /// Search for stock symbols by keyword
  /// This can be used for autocomplete functionality
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
              'region': match['4. region']?.toString() ?? '',
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
