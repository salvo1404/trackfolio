import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';
import 'firestore_service.dart';
import 'demo_data_service.dart';

class AuthService extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  User? _currentUser;
  bool _isLoggedIn = false;
  bool _isLoading = true;
  StreamSubscription? _authSub;

  static const _demoEmail = 'demo@trackfolio.app';
  static const _demoPassword = 'demo123456';

  AuthService() {
    _authSub =
        firebase_auth.FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
  }

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  String? get uid => firebase_auth.FirebaseAuth.instance.currentUser?.uid;

  Future<void> _onAuthChanged(firebase_auth.User? firebaseUser) async {
    if (firebaseUser != null) {
      final profileData = await _firestore.getUserProfile(firebaseUser.uid);
      if (profileData != null) {
        _currentUser = User.fromJson(profileData);
      } else {
        _currentUser = User(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          createdAt: DateTime.now(),
        );
      }
      _isLoggedIn = true;
    } else {
      _currentUser = null;
      _isLoggedIn = false;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<AuthResult> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return AuthResult(
        success: false,
        message: 'Email and password are required',
      );
    }

    if (password.length < 6) {
      return AuthResult(
        success: false,
        message: 'Password must be at least 6 characters',
      );
    }

    try {
      final credential = await firebase_auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = User(
        uid: credential.user!.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      await _firestore.saveUserProfile(credential.user!.uid, user.toJson());

      return AuthResult(
        success: true,
        message: 'Registration successful',
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _mapAuthError(e.code),
      );
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return AuthResult(
        success: false,
        message: 'Email and password are required',
      );
    }

    try {
      final credential = await firebase_auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Set auth state immediately so navigation works before _onAuthChanged fires
      final profileData =
          await _firestore.getUserProfile(credential.user!.uid);
      if (profileData != null) {
        _currentUser = User.fromJson(profileData);
      } else {
        _currentUser = User(
          uid: credential.user!.uid,
          email: email,
          createdAt: DateTime.now(),
        );
      }
      _isLoggedIn = true;
      notifyListeners();

      return AuthResult(
        success: true,
        message: 'Login successful',
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _mapAuthError(e.code),
      );
    }
  }

  Future<AuthResult> loginDemo() async {
    try {
      // Try signing in to existing demo account
      firebase_auth.UserCredential credential;
      try {
        credential = await firebase_auth.FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: _demoEmail, password: _demoPassword);
      } on firebase_auth.FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          // Demo account doesn't exist yet — create it once
          credential = await firebase_auth.FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: _demoEmail, password: _demoPassword);
        } else {
          rethrow;
        }
      }

      final demoUid = credential.user!.uid;
      final demoUser = DemoDataService.createDemoUser(demoUid);

      // Seed demo data (overwrites each time so it's always fresh)
      await _firestore.seedDemoData(
        demoUid,
        userProfile: demoUser.toJson(),
        portfolioItems: DemoDataService.createDemoPortfolioItems(),
        budgets: DemoDataService.createDemoBudgets(),
        goals: DemoDataService.createDemoGoals(),
        shareTransactions: DemoDataService.createDemoShareTransactions(),
      );

      _currentUser = demoUser;
      _isLoggedIn = true;
      notifyListeners();

      return AuthResult(
        success: true,
        message: 'Demo account loaded successfully',
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _mapAuthError(e.code),
      );
    }
  }

  Future<void> logout() async {
    await firebase_auth.FirebaseAuth.instance.signOut();
  }

  Future<AuthResult> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? photoUrl,
    String? country,
    String? currency,
  }) async {
    if (_currentUser == null || uid == null) {
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

    await _firestore.saveUserProfile(uid!, updatedUser.toJson());
    _currentUser = updatedUser;
    notifyListeners();

    return AuthResult(
      success: true,
      message: 'Profile updated successfully',
    );
  }

  Future<void> refreshCurrentUser() async {
    if (uid != null) {
      final profileData = await _firestore.getUserProfile(uid!);
      if (profileData != null) {
        _currentUser = User.fromJson(profileData);
        notifyListeners();
      }
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      default:
        return 'Authentication error: $code';
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
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
