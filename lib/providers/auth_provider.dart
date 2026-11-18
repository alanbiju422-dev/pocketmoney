import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;
  StreamSubscription<UserModel?>? _subscription;

  UserModel? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  AuthProvider({required this.repository}) {
    _init();
  }

  void _init() {
    _subscription = repository.watchCurrentUser().listen((user) {
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
    });
    _loadInitialUser();
  }

  Future<void> _loadInitialUser() async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await repository.getCurrentUser();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _currentUser != null;

  /// Whether user needs to enter their initial display name
  bool get needsDisplayName =>
      isAuthenticated && (_currentUser!.displayName == null || _currentUser!.displayName!.trim().isEmpty);

  /// Whether user needs to read and acknowledge the Welcome & Privacy notice
  bool get needsWelcomeNotice =>
      isAuthenticated && !needsDisplayName && !_currentUser!.hasCompletedWelcome;

  /// User is fully onboarded and ready for the main home dashboard
  bool get isReadyForApp =>
      isAuthenticated && !needsDisplayName && _currentUser!.hasCompletedWelcome;

  Future<void> signInWithGoogle({
    String? email,
    String? initialDisplayName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await repository.signInWithGoogle(
        email: email,
        initialDisplayName: initialDisplayName,
      );
    } catch (e) {
      _errorMessage = 'Google authentication failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveDisplayName(String displayName) async {
    if (_currentUser == null) return;
    final clean = displayName.trim();
    if (clean.isEmpty) {
      _errorMessage = 'Display name cannot be empty.';
      notifyListeners();
      throw Exception(_errorMessage);
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.updateDisplayName(
        userId: _currentUser!.id,
        displayName: clean,
      );
      _currentUser = _currentUser!.copyWith(displayName: clean);
    } catch (e) {
      _errorMessage = 'Failed to update display name: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeWelcomeNotice() async {
    if (_currentUser == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.setWelcomeNoticeCompleted(userId: _currentUser!.id);
      _currentUser = _currentUser!.copyWith(hasCompletedWelcome: true);
    } catch (e) {
      _errorMessage = 'Failed to save notice completion: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await repository.signOut();
      _currentUser = null;
    } catch (e) {
      _errorMessage = 'Sign out error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    repository.dispose();
    super.dispose();
  }
}
