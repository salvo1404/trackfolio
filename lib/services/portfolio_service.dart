import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/portfolio_item.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import '../models/goal.dart';
import '../models/share_transaction.dart';
import 'firestore_service.dart';
import 'currency_service.dart';
import 'auth_service.dart';

class PortfolioService extends ChangeNotifier {
  final FirestoreService _firestore;
  final CurrencyService _currencyService;
  String? _uid;
  List<PortfolioItem> _portfolioItems = [];
  List<Budget> _budgets = [];
  List<Transaction> _transactions = [];
  List<Goal> _goals = [];
  List<ShareTransaction> _shareTransactions = [];

  PortfolioService(this._firestore, this._currencyService, AuthService authService) {
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
    if (uid == null) return;
    _uid = uid;
    _portfolioItems = await _firestore.getPortfolioItems(uid);
    _budgets = await _firestore.getBudgets(uid);
    _transactions = await _firestore.getTransactions(uid);
    _goals = await _firestore.getGoals(uid);
    _shareTransactions = await _firestore.getShareTransactions(uid);
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
