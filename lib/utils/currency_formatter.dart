import 'package:intl/intl.dart';
import '../services/currency_service.dart';
import '../models/user.dart';

class CurrencyFormatter {
  final CurrencyService _currencyService;
  final User? _user;

  CurrencyFormatter(this._currencyService, this._user);

  String format(double amountInUSD) {
    final userCurrency = _user?.currency ?? 'USD';
    final convertedAmount = _currencyService.convert(amountInUSD, userCurrency);
    final symbol = _currencyService.getSymbol(userCurrency);

    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: userCurrency == 'JPY' ? 0 : 2,
    );

    return formatter.format(convertedAmount);
  }

  String getCurrencyCode() {
    return _user?.currency ?? 'USD';
  }

  String getSymbol() {
    return _currencyService.getSymbol(_user?.currency ?? 'USD');
  }
}
