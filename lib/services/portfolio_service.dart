import 'package:flutter/foundation.dart';
import '../models/portfolio_item.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import '../models/goal.dart';
import '../models/share_transaction.dart';
import 'storage_service.dart';

class PortfolioService extends ChangeNotifier {
  final StorageService _storage;
  List<PortfolioItem> _portfolioItems = [];
  List<Budget> _budgets = [];
  List<Transaction> _transactions = [];
  List<Goal> _goals = [];
  List<ShareTransaction> _shareTransactions = [];

  PortfolioService(this._storage) {
    _loadData();
  }

  List<PortfolioItem> get portfolioItems => _portfolioItems;
  List<Budget> get budgets => _budgets;
  List<Transaction> get transactions => _transactions;
  List<Goal> get goals => _goals;
  List<ShareTransaction> get shareTransactions => _shareTransactions;

  double get totalPortfolioValue {
    return _portfolioItems.fold(0, (sum, item) => sum + item.totalValue);
  }

  double get totalPortfolioCost {
    return _portfolioItems.fold(0, (sum, item) => sum + item.totalCost);
  }

  double get totalGainLoss => totalPortfolioValue - totalPortfolioCost;

  Map<String, double> get portfolioByType {
    final Map<String, double> result = {};
    for (final item in _portfolioItems) {
      result[item.type] = (result[item.type] ?? 0) + item.totalValue;
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

  // Initialize with sample data
  Future<void> initializeSampleData() async {
    if (_portfolioItems.isEmpty) {
      // Add sample portfolio items
      await addPortfolioItem(PortfolioItem(
        id: '1',
        type: 'Shares',
        name: 'AAPL - Apple Inc.',
        quantity: 10,
        purchasePrice: 150.0,
        currentValue: 175.0,
        purchaseDate: DateTime.now().subtract(const Duration(days: 90)),
        lastUpdated: DateTime.now(),
      ));

      await addPortfolioItem(PortfolioItem(
        id: '2',
        type: 'Crypto',
        name: 'Bitcoin',
        quantity: 0.5,
        purchasePrice: 45000.0,
        currentValue: 50000.0,
        purchaseDate: DateTime.now().subtract(const Duration(days: 60)),
        lastUpdated: DateTime.now(),
      ));

      await addPortfolioItem(PortfolioItem(
        id: '3',
        type: 'Cash',
        name: 'Savings Account',
        quantity: 1,
        purchasePrice: 10000.0,
        currentValue: 10000.0,
        purchaseDate: DateTime.now().subtract(const Duration(days: 365)),
        lastUpdated: DateTime.now(),
      ));
    }

    if (_budgets.isEmpty) {
      // Add sample budgets
      await addBudget(Budget(
        id: '1',
        category: 'Food & Dining',
        amount: 500.0,
        period: 'monthly',
        spent: 320.0,
        createdAt: DateTime.now(),
      ));

      await addBudget(Budget(
        id: '2',
        category: 'Transportation',
        amount: 300.0,
        period: 'monthly',
        spent: 180.0,
        createdAt: DateTime.now(),
      ));

      await addBudget(Budget(
        id: '3',
        category: 'Entertainment',
        amount: 200.0,
        period: 'monthly',
        spent: 150.0,
        createdAt: DateTime.now(),
      ));
    }

    if (_goals.isEmpty) {
      // Add sample goals
      await addGoal(Goal(
        id: '1',
        title: 'Emergency Fund',
        description: 'Build 6 months emergency fund',
        targetAmount: 30000.0,
        currentAmount: 12000.0,
        targetDate: DateTime.now().add(const Duration(days: 365)),
        category: 'Emergency Fund',
        createdAt: DateTime.now(),
      ));

      await addGoal(Goal(
        id: '2',
        title: 'Vacation Fund',
        description: 'Save for summer vacation',
        targetAmount: 5000.0,
        currentAmount: 2500.0,
        targetDate: DateTime.now().add(const Duration(days: 180)),
        category: 'Vacation',
        createdAt: DateTime.now(),
      ));
    }

    if (_shareTransactions.isEmpty) {
      // Add sample share transactions
      await addShareTransaction(ShareTransaction(
        id: '1',
        shareName: 'Apple Inc.',
        symbol: 'AAPL',
        type: 'buy',
        quantity: 10,
        pricePerShare: 150.0,
        transactionDate: DateTime.now().subtract(const Duration(days: 90)),
        notes: 'Initial purchase',
        createdAt: DateTime.now(),
      ));

      await addShareTransaction(ShareTransaction(
        id: '2',
        shareName: 'Microsoft Corporation',
        symbol: 'MSFT',
        type: 'buy',
        quantity: 5,
        pricePerShare: 320.0,
        transactionDate: DateTime.now().subtract(const Duration(days: 60)),
        notes: 'Tech portfolio diversification',
        createdAt: DateTime.now(),
      ));

      await addShareTransaction(ShareTransaction(
        id: '3',
        shareName: 'Tesla Inc.',
        symbol: 'TSLA',
        type: 'sell',
        quantity: 2,
        pricePerShare: 250.0,
        transactionDate: DateTime.now().subtract(const Duration(days: 15)),
        notes: 'Profit taking',
        createdAt: DateTime.now(),
      ));
    }
  }
}
