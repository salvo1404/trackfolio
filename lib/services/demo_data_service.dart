import '../models/user.dart';
import '../models/portfolio_item.dart';
import '../models/goal.dart';
import '../models/budget.dart';
import '../models/share_transaction.dart';
import '../utils/constants.dart';

class DemoDataService {
  static const String demoUsername = 'demo';
  static const String demoPassword = 'demo123';

  static User createDemoUser() {
    return User(
      username: demoUsername,
      email: 'demo@trackfolio.com',
      password: demoPassword,
      fullName: 'Demo User',
      country: 'United States',
      currency: 'USD',
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
    );
  }

  static List<PortfolioItem> createDemoPortfolioItems() {
    final now = DateTime.now();
    return [
      // Stocks & ETFs
      PortfolioItem(
        id: 'demo-1',
        type: AppConstants.typeStocksAndETFs,
        name: 'Apple Inc.',
        quantity: 50,
        purchasePrice: 150.0,
        currentValue: 178.5,
        purchaseDate: now.subtract(const Duration(days: 120)),
        lastUpdated: now,
        currency: 'USD',
        fees: 9.99,
      ),
      PortfolioItem(
        id: 'demo-2',
        type: AppConstants.typeStocksAndETFs,
        name: 'Vanguard S&P 500 ETF',
        quantity: 20,
        purchasePrice: 420.0,
        currentValue: 465.30,
        purchaseDate: now.subtract(const Duration(days: 200)),
        lastUpdated: now,
        currency: 'USD',
        fees: 4.95,
      ),
      // Real Estate
      PortfolioItem(
        id: 'demo-3',
        type: AppConstants.typeRealEstate,
        name: 'Downtown Apartment',
        quantity: 1,
        purchasePrice: 250000.0,
        currentValue: 285000.0,
        purchaseDate: now.subtract(const Duration(days: 365)),
        lastUpdated: now,
        currency: 'USD',
      ),
      // Cash
      PortfolioItem(
        id: 'demo-4',
        type: AppConstants.typeCash,
        name: 'Savings Account',
        quantity: 1,
        purchasePrice: 15000.0,
        currentValue: 15000.0,
        purchaseDate: now.subtract(const Duration(days: 180)),
        lastUpdated: now,
        currency: 'USD',
      ),
      // Watches
      PortfolioItem(
        id: 'demo-5',
        type: AppConstants.typeWatches,
        name: 'Rolex Submariner',
        quantity: 1,
        purchasePrice: 9500.0,
        currentValue: 13200.0,
        purchaseDate: now.subtract(const Duration(days: 730)),
        lastUpdated: now,
        currency: 'USD',
      ),
      PortfolioItem(
        id: 'demo-6',
        type: AppConstants.typeWatches,
        name: 'Omega Speedmaster',
        quantity: 1,
        purchasePrice: 6300.0,
        currentValue: 7100.0,
        purchaseDate: now.subtract(const Duration(days: 400)),
        lastUpdated: now,
        currency: 'USD',
      ),
    ];
  }

  static List<Goal> createDemoGoals() {
    final now = DateTime.now();
    return [
      Goal(
        id: 'goal-1',
        title: 'Emergency Fund',
        description: 'Build a 6-month emergency fund for financial security',
        targetAmount: 30000.0,
        currentAmount: 22500.0,
        targetDate: now.add(const Duration(days: 120)),
        category: 'Savings',
        createdAt: now.subtract(const Duration(days: 90)),
      ),
      Goal(
        id: 'goal-2',
        title: 'Vacation to Japan',
        description: 'Save for a 2-week trip to Japan including flights and accommodation',
        targetAmount: 8000.0,
        currentAmount: 5200.0,
        targetDate: now.add(const Duration(days: 180)),
        category: 'Travel',
        createdAt: now.subtract(const Duration(days: 60)),
      ),
      Goal(
        id: 'goal-3',
        title: 'New Car',
        description: 'Save for down payment on a new electric vehicle',
        targetAmount: 15000.0,
        currentAmount: 6500.0,
        targetDate: now.add(const Duration(days: 365)),
        category: 'Auto',
        createdAt: now.subtract(const Duration(days: 120)),
      ),
      Goal(
        id: 'goal-4',
        title: 'Home Renovation',
        description: 'Kitchen and bathroom remodeling project',
        targetAmount: 25000.0,
        currentAmount: 18750.0,
        targetDate: now.add(const Duration(days: 90)),
        category: 'Home',
        createdAt: now.subtract(const Duration(days: 150)),
      ),
    ];
  }

  static List<Budget> createDemoBudgets() {
    final now = DateTime.now();
    return [
      Budget(
        id: 'budget-1',
        category: 'Groceries',
        amount: 800.0,
        period: 'monthly',
        spent: 650.0,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Budget(
        id: 'budget-2',
        category: 'Dining Out',
        amount: 300.0,
        period: 'monthly',
        spent: 280.0,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Budget(
        id: 'budget-3',
        category: 'Entertainment',
        amount: 200.0,
        period: 'monthly',
        spent: 175.0,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Budget(
        id: 'budget-4',
        category: 'Transportation',
        amount: 400.0,
        period: 'monthly',
        spent: 420.0,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Budget(
        id: 'budget-5',
        category: 'Shopping',
        amount: 500.0,
        period: 'monthly',
        spent: 385.0,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
    ];
  }

  static List<ShareTransaction> createDemoShareTransactions() {
    final now = DateTime.now();
    return [
      ShareTransaction(
        id: 'trans-1',
        shareName: 'Apple Inc.',
        symbol: 'AAPL',
        type: 'buy',
        quantity: 50,
        pricePerShare: 150.0,
        transactionDate: now.subtract(const Duration(days: 120)),
        notes: 'Initial tech portfolio investment',
        createdAt: now.subtract(const Duration(days: 120)),
      ),
      ShareTransaction(
        id: 'trans-2',
        shareName: 'Microsoft Corporation',
        symbol: 'MSFT',
        type: 'buy',
        quantity: 30,
        pricePerShare: 280.0,
        transactionDate: now.subtract(const Duration(days: 90)),
        notes: 'Diversifying tech holdings',
        createdAt: now.subtract(const Duration(days: 90)),
      ),
      ShareTransaction(
        id: 'trans-3',
        shareName: 'Tesla Inc.',
        symbol: 'TSLA',
        type: 'buy',
        quantity: 25,
        pricePerShare: 220.0,
        transactionDate: now.subtract(const Duration(days: 60)),
        notes: 'Long-term EV growth bet',
        createdAt: now.subtract(const Duration(days: 60)),
      ),
      ShareTransaction(
        id: 'trans-4',
        shareName: 'Amazon.com Inc.',
        symbol: 'AMZN',
        type: 'buy',
        quantity: 15,
        pricePerShare: 140.0,
        transactionDate: now.subtract(const Duration(days: 45)),
        notes: 'Cloud and e-commerce exposure',
        createdAt: now.subtract(const Duration(days: 45)),
      ),
      ShareTransaction(
        id: 'trans-5',
        shareName: 'Amazon.com Inc.',
        symbol: 'AMZN',
        type: 'sell',
        quantity: 5,
        pricePerShare: 155.0,
        transactionDate: now.subtract(const Duration(days: 15)),
        notes: 'Taking profits after good run',
        createdAt: now.subtract(const Duration(days: 15)),
      ),
    ];
  }
}
