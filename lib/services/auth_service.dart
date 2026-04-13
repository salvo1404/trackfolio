import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'storage_service.dart';
import 'demo_data_service.dart';

class AuthService extends ChangeNotifier {
  final StorageService _storage;
  User? _currentUser;
  bool _isLoggedIn = false;

  AuthService(this._storage) {
    _checkLoginStatus();
  }

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> _checkLoginStatus() async {
    _isLoggedIn = _storage.getBool(AppConstants.isLoggedInKey) ?? false;
    if (_isLoggedIn) {
      final username = _storage.getString(AppConstants.currentUserKey);
      if (username != null) {
        _currentUser = await _storage.getUser(username);
      }
    }
    notifyListeners();
  }

  Future<AuthResult> register({
    required String username,
    required String email,
    required String password,
  }) async {
    // Validate inputs
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      return AuthResult(
        success: false,
        message: 'All fields are required',
      );
    }

    if (password.length < 6) {
      return AuthResult(
        success: false,
        message: 'Password must be at least 6 characters',
      );
    }

    // Check if user already exists
    final existingUser = await _storage.getUser(username);
    if (existingUser != null) {
      return AuthResult(
        success: false,
        message: 'Username already exists',
      );
    }

    // Create new user
    final user = User(
      username: username,
      email: email,
      password: password,
      createdAt: DateTime.now(),
    );

    await _storage.saveUser(user);

    return AuthResult(
      success: true,
      message: 'Registration successful',
    );
  }

  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    // Validate inputs
    if (username.isEmpty || password.isEmpty) {
      return AuthResult(
        success: false,
        message: 'Username and password are required',
      );
    }

    // Get user
    final user = await _storage.getUser(username);
    if (user == null) {
      return AuthResult(
        success: false,
        message: 'User not found',
      );
    }

    // Check password
    if (user.password != password) {
      return AuthResult(
        success: false,
        message: 'Incorrect password',
      );
    }

    // Set logged in state
    _currentUser = user;
    _isLoggedIn = true;
    await _storage.setBool(AppConstants.isLoggedInKey, true);
    await _storage.setString(AppConstants.currentUserKey, username);

    notifyListeners();

    return AuthResult(
      success: true,
      message: 'Login successful',
    );
  }

  Future<AuthResult> loginDemo() async {
    // Check if demo user exists
    var demoUser = await _storage.getUser(DemoDataService.demoUsername);

    if (demoUser == null) {
      // Create demo user
      demoUser = DemoDataService.createDemoUser();
      await _storage.saveUser(demoUser);

      // Populate demo data
      await _storage.savePortfolioItems(DemoDataService.createDemoPortfolioItems());
      await _storage.saveGoals(DemoDataService.createDemoGoals());
      await _storage.saveBudgets(DemoDataService.createDemoBudgets());
      await _storage.saveShareTransactions(DemoDataService.createDemoShareTransactions());
    }

    // Log in as demo user
    _currentUser = demoUser;
    _isLoggedIn = true;
    await _storage.setBool(AppConstants.isLoggedInKey, true);
    await _storage.setString(AppConstants.currentUserKey, DemoDataService.demoUsername);

    notifyListeners();

    return AuthResult(
      success: true,
      message: 'Demo account loaded successfully',
    );
  }

  Future<void> logout() async {
    _currentUser = null;
    _isLoggedIn = false;
    await _storage.setBool(AppConstants.isLoggedInKey, false);
    await _storage.remove(AppConstants.currentUserKey);
    notifyListeners();
  }

  Future<AuthResult> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? photoUrl,
    String? country,
    String? currency,
  }) async {
    if (_currentUser == null) {
      return AuthResult(
        success: false,
        message: 'No user logged in',
      );
    }

    final updatedUser = _currentUser!.copyWith(
      fullName: fullName ?? _currentUser!.fullName,
      phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
      photoUrl: photoUrl ?? _currentUser!.photoUrl,
      country: country ?? _currentUser!.country,
      currency: currency ?? _currentUser!.currency,
    );

    await _storage.saveUser(updatedUser);

    // Reload user from storage to ensure consistency
    _currentUser = await _storage.getUser(updatedUser.username);

    notifyListeners();

    return AuthResult(
      success: true,
      message: 'Profile updated successfully',
    );
  }

  Future<void> refreshCurrentUser() async {
    if (_currentUser != null) {
      _currentUser = await _storage.getUser(_currentUser!.username);
      notifyListeners();
    }
  }
}

class AuthResult {
  final bool success;
  final String message;

  AuthResult({
    required this.success,
    required this.message,
  });
}
