class CurrencyService {
  // Exchange rates relative to USD (1 USD = X currency)
  static const Map<String, double> _exchangeRates = {
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

  /// Convert amount from USD to target currency
  double convert(double amountInUSD, String targetCurrency) {
    final rate = _exchangeRates[targetCurrency] ?? 1.0;
    return amountInUSD * rate;
  }

  /// Convert amount from source currency to target currency
  double convertBetween(double amount, String fromCurrency, String toCurrency) {
    // First convert to USD
    final rateFrom = _exchangeRates[fromCurrency] ?? 1.0;
    final amountInUSD = amount / rateFrom;

    // Then convert to target currency
    return convert(amountInUSD, toCurrency);
  }

  /// Get currency symbol for a currency code
  String getSymbol(String currencyCode) {
    return _currencySymbols[currencyCode] ?? '\$';
  }

  /// Get exchange rate for a currency (relative to USD)
  double getRate(String currencyCode) {
    return _exchangeRates[currencyCode] ?? 1.0;
  }
}
