import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/theme_service.dart';
import '../../services/portfolio_service.dart';
import '../../widgets/portfolio_tab.dart';
import '../../widgets/goals_tab.dart';
import '../../widgets/share_tracker_tab.dart';
import '../../widgets/budgets_tab.dart';
import '../../widgets/add_asset_tab.dart';
import 'profile_settings_page.dart';

class TabbedDashboardPage extends StatelessWidget {
  const TabbedDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          title: GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.trending_up,
                  color: Colors.green[600],
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  'Trackfolio',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.account_circle),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ),
          ],
        ),
        endDrawer: _ProfileDrawer(),
        body: const TabBarView(
          children: [
            PortfolioTab(),
            ShareTrackerTab(),
            AddAssetTab(),
            GoalsTab(),
            BudgetsTab(),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
            child: TabBar(
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorSize: TabBarIndicatorSize.tab,
              labelPadding: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              indicator: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 3,
                  ),
                ),
              ),
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  height: 60,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.account_balance_wallet, size: 26),
                        SizedBox(height: 4),
                        Text('Portfolio', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                ),
                Tab(
                  height: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.show_chart, size: 26),
                      SizedBox(height: 4),
                      Text('Tracker', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
                Tab(
                  height: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_circle, size: 30),
                      SizedBox(height: 4),
                      Text('Add', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
                Tab(
                  height: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.flag, size: 26),
                      SizedBox(height: 4),
                      Text('Goals', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
                Tab(
                  height: 60,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.account_balance, size: 26),
                        SizedBox(height: 4),
                        Text('Budgets', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileDrawer extends StatefulWidget {
  @override
  State<_ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<_ProfileDrawer> {
  final List<String> _countries = [
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
    'Germany',
    'France',
    'Italy',
    'Spain',
    'Japan',
    'China',
    'India',
    'Brazil',
    'Mexico',
    'South Africa',
    'United Arab Emirates',
  ];

  final List<String> _currencies = [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'CNY',
    'INR',
    'AUD',
    'CAD',
    'CHF',
    'BRL',
    'ZAR',
    'MXN',
    'AED',
  ];

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: user?.photoUrl != null
                  ? NetworkImage(user!.photoUrl!)
                  : null,
              child: user?.photoUrl == null
                  ? Icon(
                      Icons.person,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
            ),
            accountName: Text(
              user?.fullName ?? user?.displayName ?? 'User',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            accountEmail: Text(user?.email ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('My Profile'),
            subtitle: const Text('View and edit your profile'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileSettingsPage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: const Text('Account Details'),
            subtitle: Text(user?.email ?? ''),
          ),
          const Divider(),

          // Country Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      color: Colors.grey[700],
                      size: 20,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Country',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: user?.country,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  hint: const Text('Select country'),
                  items: _countries
                      .map((country) => DropdownMenuItem(
                            value: country,
                            child: Text(country),
                          ))
                      .toList(),
                  onChanged: (value) async {
                    if (value != null) {
                      await authService.updateProfile(country: value);
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Currency Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      color: Colors.grey[700],
                      size: 20,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Default Currency',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: user?.currency ?? 'USD',
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  items: _currencies
                      .map((currency) => DropdownMenuItem(
                            value: currency,
                            child: Text(currency),
                          ))
                      .toList(),
                  onChanged: (value) async {
                    if (value != null) {
                      await authService.updateProfile(currency: value);
                    }
                  },
                ),
              ],
            ),
          ),

          const Divider(),
          Builder(
            builder: (context) {
              final themeService = context.watch<ThemeService>();
              return SwitchListTile(
                secondary: Icon(
                  themeService.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
                title: const Text('Dark Mode'),
                value: themeService.isDarkMode,
                onChanged: (_) => themeService.toggleTheme(),
              );
            },
          ),
          const Divider(),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await authService.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/');
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
