import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/portfolio_item.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import '../models/goal.dart';
import '../models/share_transaction.dart';
import '../utils/constants.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Generic methods
  Future<void> setString(String key, String value) async {
    await _preferences?.setString(key, value);
  }

  String? getString(String key) {
    return _preferences?.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }

  bool? getBool(String key) {
    return _preferences?.getBool(key);
  }

  Future<void> remove(String key) async {
    await _preferences?.remove(key);
  }

  Future<void> clear() async {
    await _preferences?.clear();
  }

  // User methods
  Future<void> saveUser(User user) async {
    final users = await getUsers();
    users[user.username] = user;
    final usersJson = jsonEncode(
      users.map((key, value) => MapEntry(key, value.toJson())),
    );
    await setString(AppConstants.usersKey, usersJson);
  }

  Future<Map<String, User>> getUsers() async {
    final usersJson = getString(AppConstants.usersKey);
    if (usersJson == null) return {};

    final Map<String, dynamic> decoded = jsonDecode(usersJson);
    return decoded.map(
      (key, value) => MapEntry(key, User.fromJson(value)),
    );
  }

  Future<User?> getUser(String username) async {
    final users = await getUsers();
    return users[username];
  }

  // Portfolio methods
  Future<void> savePortfolioItems(List<PortfolioItem> items) async {
    final itemsJson = jsonEncode(items.map((e) => e.toJson()).toList());
    await setString(AppConstants.portfolioKey, itemsJson);
  }

  Future<List<PortfolioItem>> getPortfolioItems() async {
    final itemsJson = getString(AppConstants.portfolioKey);
    if (itemsJson == null) return [];

    final List<dynamic> decoded = jsonDecode(itemsJson);
    return decoded.map((e) => PortfolioItem.fromJson(e)).toList();
  }

  // Budget methods
  Future<void> saveBudgets(List<Budget> budgets) async {
    final budgetsJson = jsonEncode(budgets.map((e) => e.toJson()).toList());
    await setString(AppConstants.budgetsKey, budgetsJson);
  }

  Future<List<Budget>> getBudgets() async {
    final budgetsJson = getString(AppConstants.budgetsKey);
    if (budgetsJson == null) return [];

    final List<dynamic> decoded = jsonDecode(budgetsJson);
    return decoded.map((e) => Budget.fromJson(e)).toList();
  }

  // Transaction methods
  Future<void> saveTransactions(List<Transaction> transactions) async {
    final transactionsJson =
        jsonEncode(transactions.map((e) => e.toJson()).toList());
    await setString(AppConstants.transactionsKey, transactionsJson);
  }

  Future<List<Transaction>> getTransactions() async {
    final transactionsJson = getString(AppConstants.transactionsKey);
    if (transactionsJson == null) return [];

    final List<dynamic> decoded = jsonDecode(transactionsJson);
    return decoded.map((e) => Transaction.fromJson(e)).toList();
  }

  // Goal methods
  Future<void> saveGoals(List<Goal> goals) async {
    final goalsJson = jsonEncode(goals.map((e) => e.toJson()).toList());
    await setString(AppConstants.goalsKey, goalsJson);
  }

  Future<List<Goal>> getGoals() async {
    final goalsJson = getString(AppConstants.goalsKey);
    if (goalsJson == null) return [];

    final List<dynamic> decoded = jsonDecode(goalsJson);
    return decoded.map((e) => Goal.fromJson(e)).toList();
  }

  // Share Transaction methods
  Future<void> saveShareTransactions(List<ShareTransaction> transactions) async {
    final transactionsJson =
        jsonEncode(transactions.map((e) => e.toJson()).toList());
    await setString(AppConstants.shareTransactionsKey, transactionsJson);
  }

  Future<List<ShareTransaction>> getShareTransactions() async {
    final transactionsJson = getString(AppConstants.shareTransactionsKey);
    if (transactionsJson == null) return [];

    final List<dynamic> decoded = jsonDecode(transactionsJson);
    return decoded.map((e) => ShareTransaction.fromJson(e)).toList();
  }
}
