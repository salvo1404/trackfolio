class AppConstants {
  // App Info
  static const String appName = 'Trackfolio';
  static const String appTagline = 'Your Personal Finance Tracker';

  // Colors
  static const int primaryColorValue = 0xFF2E7D32;
  static const int secondaryColorValue = 0xFF1565C0;
  static const int accentColorValue = 0xFFFFA726;

  // Storage Keys
  static const String isLoggedInKey = 'is_logged_in';
  static const String currentUserKey = 'current_user';
  static const String usersKey = 'users';
  static const String portfolioKey = 'portfolio_items';
  static const String budgetsKey = 'budgets';
  static const String transactionsKey = 'transactions';
  static const String goalsKey = 'goals';
  static const String shareTransactionsKey = 'share_transactions';

  // Portfolio Types
  static const String typeShares = 'Shares';
  static const String typeCrypto = 'Crypto';
  static const String typeRealEstate = 'Real Estate';
  static const String typeWatches = 'Watches';
  static const String typeCash = 'Cash';
  static const String typeRetirementFund = 'Retirement Fund';

  static const List<String> portfolioTypes = [
    typeShares,
    typeCrypto,
    typeRealEstate,
    typeWatches,
    typeCash,
    typeRetirementFund,
  ];

  // Budget Categories
  static const List<String> budgetCategories = [
    'Housing',
    'Transportation',
    'Food & Dining',
    'Shopping',
    'Entertainment',
    'Healthcare',
    'Utilities',
    'Savings',
    'Investments',
    'Other',
  ];

  // Goal Categories
  static const List<String> goalCategories = [
    'Emergency Fund',
    'Retirement',
    'Home Purchase',
    'Education',
    'Vacation',
    'Investment',
    'Debt Payoff',
    'Other',
  ];
}
