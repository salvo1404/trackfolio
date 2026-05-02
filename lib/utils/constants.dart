class AppConstants {
  // App Info
  static const String appName = 'Trackfolio';
  static const String appTagline = 'Your Personal Finance Tracker';

  // Colors
  static const int primaryColorValue = 0xFF2E7D32;
  static const int secondaryColorValue = 0xFF1565C0;
  static const int accentColorValue = 0xFFFFA726;

  // Local Storage Keys
  static const String themeKey = 'is_dark_mode';

  // Portfolio Types
  static const String typeStocksAndETFs = 'Stocks & ETFs';
  static const String typeCrypto = 'Crypto';
  static const String typeRealEstate = 'Real Estate';
  static const String typeWatches = 'Watches';
  static const String typeCash = 'Cash';
  static const String typeRetirementFund = 'Retirement Fund';

  static const List<String> portfolioTypes = [
    typeStocksAndETFs,
    typeCrypto,
    typeRealEstate,
    typeWatches,
    typeCash,
    typeRetirementFund,
  ];

  // Budget Categories
  static const List<String> budgetCategories = [
    'Living',
    'Communication',
    'Health',
    'Transport',
    'Beauty',
    'Tech',
    'Fitness',
    'Finance',
    'Groceries',
    'Fun',
    'Subscription',
  ];
}
