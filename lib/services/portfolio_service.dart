import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/portfolio_item.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import '../models/goal.dart';
import '../models/share_transaction.dart';
import '../utils/constants.dart';
import 'firestore_service.dart';
import 'currency_service.dart';
import 'auth_service.dart';
import 'stock_api_service.dart';

class PortfolioService extends ChangeNotifier {
  final FirestoreService _firestore;
  final CurrencyService _currencyService;
  final StockApiService _stockApi;
  String? _uid;
  List<PortfolioItem> _portfolioItems = [];
  List<Budget> _budgets = [];
  List<Transaction> _transactions = [];
  List<Goal> _goals = [];
  List<ShareTransaction> _shareTransactions = [];
  bool _isRefreshingPrices = false;
  bool _isLoadingData = false;
  String? _priceRefreshStatus;

  bool get isRefreshingPrices => _isRefreshingPrices;
  String? get priceRefreshStatus => _priceRefreshStatus;

  PortfolioService(this._firestore, this._currencyService, this._stockApi, AuthService authService) {
    _uid = authService.uid;
    if (_uid != null) loadData();
  }

  List<PortfolioItem> get portfolioItems => _portfolioItems;
  List<Budget> get budgets => _budgets;
  List<Transaction> get transactions => _transactions;
  List<Goal> get goals => _goals;
  List<ShareTransaction> get shareTransactions => _shareTransactions;

  double get totalPortfolioValue {
    return _portfolioItems.fold(0, (sum, item) {
      final valueInUSD = _currencyService.convertBetween(
        item.totalValue,
        item.currency,
        'USD',
      );
      return sum + valueInUSD;
    });
  }

  double get totalPortfolioCost {
    return _portfolioItems.fold(0, (sum, item) {
      final costInUSD = _currencyService.convertBetween(
        item.totalCost,
        item.currency,
        'USD',
      );
      return sum + costInUSD;
    });
  }

  double get totalGainLoss => totalPortfolioValue - totalPortfolioCost;

  Map<String, double> get portfolioByType {
    final Map<String, double> result = {};
    for (final item in _portfolioItems) {
      final valueInUSD = _currencyService.convertBetween(
        item.totalValue,
        item.currency,
        'USD',
      );
      result[item.type] = (result[item.type] ?? 0) + valueInUSD;
    }
    return result;
  }

  void onAuthChanged(AuthService authService) {
    final newUid = authService.uid;
    if (newUid == null && _uid != null) {
      _uid = null;
      _clearData();
    } else if (newUid != null) {
      _uid = newUid;
      loadData();
    }
  }

  void _clearData() {
    _portfolioItems = [];
    _budgets = [];
    _transactions = [];
    _goals = [];
    _shareTransactions = [];
    notifyListeners();
  }

  Future<void> loadData() async {
    final uid = _uid ?? firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _isLoadingData) return;
    _uid = uid;
    _isLoadingData = true;

    final results = await Future.wait([
      _firestore.getPortfolioItems(uid),
      _firestore.getBudgets(uid),
      _firestore.getTransactions(uid),
      _firestore.getGoals(uid),
      _firestore.getShareTransactions(uid),
    ]);

    _portfolioItems = results[0] as List<PortfolioItem>;
    _budgets = results[1] as List<Budget>;
    _transactions = results[2] as List<Transaction>;
    _goals = results[3] as List<Goal>;
    _shareTransactions = results[4] as List<ShareTransaction>;
    _isLoadingData = false;
    notifyListeners();

    refreshPrices();
  }

  Future<void> refreshPrices() async {
    final uid = _uid;
    if (uid == null || _isRefreshingPrices) return;

    final priceable = _portfolioItems.where((item) =>
      item.symbol != null &&
      item.symbol!.isNotEmpty &&
      item.dateSold == null &&
      (item.type == AppConstants.typeStocksAndETFs || item.type == AppConstants.typeCrypto),
    ).toList();

    if (priceable.isEmpty) return;

    _isRefreshingPrices = true;
    _priceRefreshStatus = 'Updating values...';
    notifyListeners();

    int updated = 0;

    // Batch crypto lookups (CoinGecko supports multi-ID queries)
    final cryptoItems = priceable.where((i) => i.type == AppConstants.typeCrypto).toList();
    if (cryptoItems.isNotEmpty) {
      final symbols = cryptoItems.map((i) => i.symbol!).toList();
      final prices = await _stockApi.lookupCryptoPrices(symbols);
      for (final item in cryptoItems) {
        final price = prices[item.symbol!];
        if (price != null && price != item.currentValue) {
          final updatedItem = item.copyWith(
            currentValue: price,
            lastUpdated: DateTime.now(),
          );
          final index = _portfolioItems.indexWhere((i) => i.id == item.id);
          if (index != -1) {
            _portfolioItems[index] = updatedItem;
            await _firestore.setPortfolioItem(uid, updatedItem);
            updated++;
          }
        }
      }
    }

    // Fetch stock/ETF prices — one API call per unique symbol
    final stockItems = priceable.where((i) => i.type == AppConstants.typeStocksAndETFs).toList();
    final uniqueSymbols = stockItems.map((i) => i.symbol!).toSet();
    final Map<String, double> stockPrices = {};
    for (final symbol in uniqueSymbols) {
      try {
        final result = await _stockApi.lookupStock(symbol);
        if (result != null && result['price'] != null) {
          final price = (result['price'] as num).toDouble();
          if (price > 0) stockPrices[symbol] = price;
        }
      } catch (_) {}
    }
    for (final item in stockItems) {
      final price = stockPrices[item.symbol!];
      if (price != null && price != item.currentValue) {
        final updatedItem = item.copyWith(
          currentValue: price,
          lastUpdated: DateTime.now(),
        );
        final index = _portfolioItems.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          _portfolioItems[index] = updatedItem;
          await _firestore.setPortfolioItem(uid, updatedItem);
          updated++;
        }
      }
    }

    _isRefreshingPrices = false;
    _priceRefreshStatus = updated > 0
        ? '$updated price${updated == 1 ? '' : 's'} updated'
        : 'values are up to date';
    notifyListeners();

    // Clear the status message after a few seconds
    await Future.delayed(const Duration(seconds: 4));
    _priceRefreshStatus = null;
    notifyListeners();
  }

  // Portfolio Item methods
  Future<void> addPortfolioItem(PortfolioItem item) async {
    _portfolioItems.add(item);
    if (_uid != null) await _firestore.setPortfolioItem(_uid!, item);
    notifyListeners();
  }

  Future<void> updatePortfolioItem(PortfolioItem item) async {
    final index = _portfolioItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _portfolioItems[index] = item;
      if (_uid != null) await _firestore.setPortfolioItem(_uid!, item);
      notifyListeners();
    }
  }

  Future<void> deletePortfolioItem(String id) async {
    _portfolioItems.removeWhere((item) => item.id == id);
    if (_uid != null) await _firestore.deletePortfolioItem(_uid!, id);
    notifyListeners();
  }

  // Budget methods
  Future<void> addBudget(Budget budget) async {
    _budgets.add(budget);
    if (_uid != null) await _firestore.setBudget(_uid!, budget);
    notifyListeners();
  }

  Future<void> updateBudget(Budget budget) async {
    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      _budgets[index] = budget;
      if (_uid != null) await _firestore.setBudget(_uid!, budget);
      notifyListeners();
    }
  }

  Future<void> deleteBudget(String id) async {
    _budgets.removeWhere((budget) => budget.id == id);
    if (_uid != null) await _firestore.deleteBudget(_uid!, id);
    notifyListeners();
  }

  // Transaction methods
  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    if (_uid != null) await _firestore.setTransaction(_uid!, transaction);
    notifyListeners();
  }

  List<Transaction> getRecentTransactions({int limit = 5}) {
    final sorted = List<Transaction>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }

  // Goal methods
  Future<void> addGoal(Goal goal) async {
    _goals.add(goal);
    if (_uid != null) await _firestore.setGoal(_uid!, goal);
    notifyListeners();
  }

  Future<void> updateGoal(Goal goal) async {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
      if (_uid != null) await _firestore.setGoal(_uid!, goal);
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((goal) => goal.id == id);
    if (_uid != null) await _firestore.deleteGoal(_uid!, id);
    notifyListeners();
  }

  // Share Transaction methods
  Future<void> addShareTransaction(ShareTransaction transaction) async {
    _shareTransactions.add(transaction);
    if (_uid != null) await _firestore.setShareTransaction(_uid!, transaction);
    notifyListeners();
  }

  Future<void> updateShareTransaction(ShareTransaction transaction) async {
    final index = _shareTransactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _shareTransactions[index] = transaction;
      if (_uid != null) await _firestore.setShareTransaction(_uid!, transaction);
      notifyListeners();
    }
  }

  Future<void> deleteShareTransaction(String id) async {
    _shareTransactions.removeWhere((transaction) => transaction.id == id);
    if (_uid != null) await _firestore.deleteShareTransaction(_uid!, id);
    notifyListeners();
  }

  List<ShareTransaction> getRecentShareTransactions({int limit = 10}) {
    final sorted = List<ShareTransaction>.from(_shareTransactions)
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    return sorted.take(limit).toList();
  }
}
