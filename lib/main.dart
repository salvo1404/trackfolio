import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/portfolio_service.dart';
import 'services/currency_service.dart';
import 'services/theme_service.dart';
import 'services/firestore_service.dart';
import 'screens/landing/landing_page.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';
import 'screens/app/tabbed_dashboard_page.dart';
import 'screens/app/portfolio_page.dart';
import 'screens/app/budget_page.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

  // SharedPreferences only for theme (local device preference)
  final prefs = await SharedPreferences.getInstance();

  runApp(TrackfolioApp(prefs: prefs));
}

class TrackfolioApp extends StatelessWidget {
  final SharedPreferences prefs;

  const TrackfolioApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) => CurrencyService(),
        ),
        Provider(
          create: (_) => FirestoreService(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeService(prefs),
        ),
        ChangeNotifierProxyProvider<AuthService, PortfolioService>(
          create: (context) => PortfolioService(
            context.read<FirestoreService>(),
            context.read<CurrencyService>(),
            context.read<AuthService>(),
          ),
          update: (context, authService, previous) {
            if (previous == null) {
              return PortfolioService(
                context.read<FirestoreService>(),
                context.read<CurrencyService>(),
                authService,
              );
            }
            return previous..onAuthChanged(authService);
          },
        ),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) {
          return MaterialApp(
            title: 'Trackfolio',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode,
            debugShowCheckedModeBanner: false,
            home: const _AuthGate(),
            routes: {
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

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    if (authService.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authService.isLoggedIn) {
      return const TabbedDashboardPage();
    }

    return const LandingPage();
  }
}

class _ProtectedRoute extends StatefulWidget {
  final Widget child;

  const _ProtectedRoute({required this.child});

  @override
  State<_ProtectedRoute> createState() => _ProtectedRouteState();
}

class _ProtectedRouteState extends State<_ProtectedRoute> {
  @override
  void initState() {
    super.initState();
    // Load portfolio data once this widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PortfolioService>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    // Wait for Firebase Auth to resolve before deciding
    if (authService.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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

    return widget.child;
  }
}
