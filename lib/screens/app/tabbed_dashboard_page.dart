import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/portfolio_service.dart';
import '../../widgets/portfolio_tab.dart';
import '../../widgets/goals_tab.dart';
import '../../widgets/share_tracker_tab.dart';
import '../../widgets/budgets_tab.dart';
import 'profile_settings_page.dart';

class TabbedDashboardPage extends StatelessWidget {
  const TabbedDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return DefaultTabController(
      length: 4,
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
            child: const Text('Trackfolio'),
          ),
          automaticallyImplyLeading: false,
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ),
          ],
          bottom: const TabBar(
            isScrollable: false,
            tabs: [
              Tab(
                icon: Icon(Icons.account_balance_wallet),
                text: 'Portfolio',
              ),
              Tab(
                icon: Icon(Icons.show_chart),
                text: 'Tracker',
              ),
              Tab(
                icon: Icon(Icons.flag),
                text: 'Goals',
              ),
              Tab(
                icon: Icon(Icons.account_balance),
                text: 'Budgets',
              ),
            ],
          ),
        ),
        endDrawer: _ProfileDrawer(),
        body: const TabBarView(
          children: [
            PortfolioTab(),
            ShareTrackerTab(),
            GoalsTab(),
            BudgetsTab(),
          ],
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
              user?.fullName ?? user?.username ?? 'User',
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
                    fillColor: Colors.grey[50],
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
                    fillColor: Colors.grey[50],
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
