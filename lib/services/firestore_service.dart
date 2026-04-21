import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/portfolio_item.dart';
import '../models/budget.dart';
import '../models/transaction.dart' as model;
import '../models/goal.dart';
import '../models/share_transaction.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference _userDoc(String uid) => _db.collection('users').doc(uid);

  CollectionReference _collection(String uid, String name) =>
      _userDoc(uid).collection(name);

  // Profile
  Future<void> saveUserProfile(String uid, Map<String, dynamic> data) async {
    await _userDoc(uid).set(data, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _userDoc(uid).get();
    return doc.data() as Map<String, dynamic>?;
  }

  // Portfolio Items
  Future<void> setPortfolioItem(String uid, PortfolioItem item) async {
    await _collection(uid, 'portfolio_items').doc(item.id).set(item.toJson());
  }

  Future<void> deletePortfolioItem(String uid, String itemId) async {
    await _collection(uid, 'portfolio_items').doc(itemId).delete();
  }

  Future<List<PortfolioItem>> getPortfolioItems(String uid) async {
    final snapshot = await _collection(uid, 'portfolio_items').get();
    return snapshot.docs
        .map((doc) => PortfolioItem.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Budgets
  Future<void> setBudget(String uid, Budget budget) async {
    await _collection(uid, 'budgets').doc(budget.id).set(budget.toJson());
  }

  Future<void> deleteBudget(String uid, String budgetId) async {
    await _collection(uid, 'budgets').doc(budgetId).delete();
  }

  Future<List<Budget>> getBudgets(String uid) async {
    final snapshot = await _collection(uid, 'budgets').get();
    return snapshot.docs
        .map((doc) => Budget.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Transactions
  Future<void> setTransaction(String uid, model.Transaction transaction) async {
    await _collection(uid, 'transactions')
        .doc(transaction.id)
        .set(transaction.toJson());
  }

  Future<List<model.Transaction>> getTransactions(String uid) async {
    final snapshot = await _collection(uid, 'transactions').get();
    return snapshot.docs
        .map((doc) => model.Transaction.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Goals
  Future<void> setGoal(String uid, Goal goal) async {
    await _collection(uid, 'goals').doc(goal.id).set(goal.toJson());
  }

  Future<void> deleteGoal(String uid, String goalId) async {
    await _collection(uid, 'goals').doc(goalId).delete();
  }

  Future<List<Goal>> getGoals(String uid) async {
    final snapshot = await _collection(uid, 'goals').get();
    return snapshot.docs
        .map((doc) => Goal.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Share Transactions
  Future<void> setShareTransaction(
      String uid, ShareTransaction transaction) async {
    await _collection(uid, 'share_transactions')
        .doc(transaction.id)
        .set(transaction.toJson());
  }

  Future<void> deleteShareTransaction(String uid, String transactionId) async {
    await _collection(uid, 'share_transactions').doc(transactionId).delete();
  }

  Future<List<ShareTransaction>> getShareTransactions(String uid) async {
    final snapshot = await _collection(uid, 'share_transactions').get();
    return snapshot.docs
        .map((doc) =>
            ShareTransaction.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Seed demo data in a single batch
  Future<void> seedDemoData(
    String uid, {
    required Map<String, dynamic> userProfile,
    required List<PortfolioItem> portfolioItems,
    required List<Budget> budgets,
    required List<Goal> goals,
    required List<ShareTransaction> shareTransactions,
  }) async {
    final batch = _db.batch();

    batch.set(_userDoc(uid), userProfile, SetOptions(merge: true));

    for (final item in portfolioItems) {
      batch.set(
        _collection(uid, 'portfolio_items').doc(item.id),
        item.toJson(),
      );
    }

    for (final budget in budgets) {
      batch.set(
        _collection(uid, 'budgets').doc(budget.id),
        budget.toJson(),
      );
    }

    for (final goal in goals) {
      batch.set(
        _collection(uid, 'goals').doc(goal.id),
        goal.toJson(),
      );
    }

    for (final transaction in shareTransactions) {
      batch.set(
        _collection(uid, 'share_transactions').doc(transaction.id),
        transaction.toJson(),
      );
    }

    await batch.commit();
  }
}
