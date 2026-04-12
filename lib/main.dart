import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'services/auth_service.dart';
import 'services/portfolio_service.dart';
import 'services/currency_service.dart';
import 'screens/landing/landing_page.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';
import 'screens/app/tabbed_dashboard_page.dart';
import 'screens/app/portfolio_page.dart';
import 'screens/app/budget_page.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service
  final storage = await StorageService.getInstance();

  runApp(TrackfolioApp(storage: storage));
}

class TrackfolioApp extends StatelessWidget {
  final StorageService storage;

  const TrackfolioApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) => CurrencyService(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthService(storage),
        ),
        ChangeNotifierProvider(
          create: (context) => PortfolioService(
            storage,
            context.read<CurrencyService>(),
          ),
        ),
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
          return MaterialApp(
            title: 'Trackfolio',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            initialRoute: authService.isLoggedIn ? '/dashboard' : '/',
            routes: {
              '/': (context) => const LandingPage(),
              '/login': (context) => const LoginPage(),
              '/register': (context) => const RegisterPage(),
              '/dashboard': (context) => _ProtectedRoute(
                    child: const TabbedDashboardPage(),
                  ),
              '/portfolio': (context) => _ProtectedRoute(
                    child: const PortfolioPage(),
                  ),
              '/budget': (context) => _ProtectedRoute(
                    child: const BudgetPage(),
                  ),
            },
          );
        },
      ),
    );
  }
}

class _ProtectedRoute extends StatelessWidget {
  final Widget child;

  const _ProtectedRoute({required this.child});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    if (!authService.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return child;
  }
}
