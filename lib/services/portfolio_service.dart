import 'package:flutter/foundation.dart';
import '../models/portfolio_item.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import '../models/goal.dart';
import '../models/share_transaction.dart';
import 'storage_service.dart';
import 'currency_service.dart';

class PortfolioService extends ChangeNotifier {
  final StorageService _storage;
  final CurrencyService _currencyService;
  List<PortfolioItem> _portfolioItems = [];
  List<Budget> _budgets = [];
  List<Transaction> _transactions = [];
  List<Goal> _goals = [];
  List<ShareTransaction> _shareTransactions = [];

  PortfolioService(this._storage, this._currencyService) {
    _loadData();
  }

  List<PortfolioItem> get portfolioItems => _portfolioItems;
  List<Budget> get budgets => _budgets;
  List<Transaction> get transactions => _transactions;
  List<Goal> get goals => _goals;
  List<ShareTransaction> get shareTransactions => _shareTransactions;

  double get totalPortfolioValue {
    return _portfolioItems.fold(0, (sum, item) {
      // Convert item's value from its currency to USD
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
      // Convert item's cost from its currency to USD
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
      // Convert item's value from its currency to USD
      final valueInUSD = _currencyService.convertBetween(
        item.totalValue,
        item.currency,
        'USD',
      );
      result[item.type] = (result[item.type] ?? 0) + valueInUSD;
    }
    return result;
  }

  Future<void> _loadData() async {
    _portfolioItems = await _storage.getPortfolioItems();
    _budgets = await _storage.getBudgets();
    _transactions = await _storage.getTransactions();
    _goals = await _storage.getGoals();
    _shareTransactions = await _storage.getShareTransactions();
    notifyListeners();
  }

  // Portfolio Item methods
  Future<void> addPortfolioItem(PortfolioItem item) async {
    _portfolioItems.add(item);
    await _storage.savePortfolioItems(_portfolioItems);
    notifyListeners();
  }

  Future<void> updatePortfolioItem(PortfolioItem item) async {
    final index = _portfolioItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _portfolioItems[index] = item;
      await _storage.savePortfolioItems(_portfolioItems);
      notifyListeners();
    }
  }

  Future<void> deletePortfolioItem(String id) async {
    _portfolioItems.removeWhere((item) => item.id == id);
    await _storage.savePortfolioItems(_portfolioItems);
    notifyListeners();
  }

  // Budget methods
  Future<void> addBudget(Budget budget) async {
    _budgets.add(budget);
    await _storage.saveBudgets(_budgets);
    notifyListeners();
  }

  Future<void> updateBudget(Budget budget) async {
    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      _budgets[index] = budget;
      await _storage.saveBudgets(_budgets);
      notifyListeners();
    }
  }

  Future<void> deleteBudget(String id) async {
    _budgets.removeWhere((budget) => budget.id == id);
    await _storage.saveBudgets(_budgets);
    notifyListeners();
  }

  // Transaction methods
  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    await _storage.saveTransactions(_transactions);
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
    await _storage.saveGoals(_goals);
    notifyListeners();
  }

  Future<void> updateGoal(Goal goal) async {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
      await _storage.saveGoals(_goals);
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((goal) => goal.id == id);
    await _storage.saveGoals(_goals);
    notifyListeners();
  }

  // Share Transaction methods
  Future<void> addShareTransaction(ShareTransaction transaction) async {
    _shareTransactions.add(transaction);
    await _storage.saveShareTransactions(_shareTransactions);
    notifyListeners();
  }

  Future<void> updateShareTransaction(ShareTransaction transaction) async {
    final index = _shareTransactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _shareTransactions[index] = transaction;
      await _storage.saveShareTransactions(_shareTransactions);
      notifyListeners();
    }
  }

  Future<void> deleteShareTransaction(String id) async {
    _shareTransactions.removeWhere((transaction) => transaction.id == id);
    await _storage.saveShareTransactions(_shareTransactions);
    notifyListeners();
  }

  List<ShareTransaction> getRecentShareTransactions({int limit = 10}) {
    final sorted = List<ShareTransaction>.from(_shareTransactions)
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    return sorted.take(limit).toList();
  }

}
