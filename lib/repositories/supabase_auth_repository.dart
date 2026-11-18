import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

/// Supabase Authentication repository implementation of [AuthRepository].
///
/// Connects the application to real Google Sign-In using Supabase OAuth,
/// managing real-time auth state streams, user profile metadata, and
/// onboarding completion status.
class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client;
  final StreamController<UserModel?> _controller =
      StreamController<UserModel?>.broadcast();
  StreamSubscription<AuthState>? _authSubscription;
  UserModel? _cachedUser;

  static const String redirectUrl = 'io.supabase.pocketmoney://login-callback/';

  SupabaseAuthRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client {
    _init();
  }

  void _init() {
    // Check initial current user from existing Supabase session
    final current = _client.auth.currentUser;
    if (current != null) {
      _cachedUser = _mapSupabaseUserToUserModel(current);
      _controller.add(_cachedUser);
    } else {
      _cachedUser = null;
    }

    // Listen to real-time Supabase auth state changes
    _authSubscription = _client.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user ?? _client.auth.currentUser;
      if (user != null) {
        _cachedUser = _mapSupabaseUserToUserModel(user);
        _controller.add(_cachedUser);
      } else {
        _cachedUser = null;
        _controller.add(null);
      }
    });
  }

  /// Map Supabase [User] entity to the application's domain [UserModel].
  UserModel _mapSupabaseUserToUserModel(User user) {
    final metadata = user.userMetadata ?? {};
    final customDisplayName = metadata['display_name'] as String?;
    final oauthName = (metadata['full_name'] ?? metadata['name']) as String?;
    final hasCompletedWelcome = metadata['has_completed_welcome'] == true;
    final photo = (metadata['avatar_url'] ?? metadata['picture']) as String?;

    DateTime createdDate;
    try {
      createdDate = DateTime.parse(user.createdAt);
    } catch (_) {
      createdDate = DateTime.now();
    }

    final cleanCustomName = (customDisplayName != null && customDisplayName.trim().isNotEmpty)
        ? customDisplayName.trim()
        : null;
    final cleanOAuthName = (oauthName != null && oauthName.trim().isNotEmpty)
        ? oauthName.trim()
        : null;

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      displayName: cleanCustomName ?? cleanOAuthName,
      googleName: cleanOAuthName,
      photoUrl: photo,
      hasCompletedWelcome: hasCompletedWelcome,
      createdAt: createdDate,
    );
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final current = _client.auth.currentUser;
    if (current != null) {
      _cachedUser = _mapSupabaseUserToUserModel(current);
      return _cachedUser;
    }
    return null;
  }

  @override
  Stream<UserModel?> watchCurrentUser() {
    return _controller.stream;
  }

  @override
  Future<UserModel> signInWithGoogle({
    String? email,
    String? initialDisplayName,
  }) async {
    // If already signed in, return current user
    final existingUser = _client.auth.currentUser;
    if (existingUser != null) {
      final userModel = _mapSupabaseUserToUserModel(existingUser);
      _cachedUser = userModel;
      _controller.add(userModel);
      return userModel;
    }

    final completer = Completer<UserModel>();
    late final StreamSubscription<AuthState> tempSub;

    tempSub = _client.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user;
      if (user != null && !completer.isCompleted) {
        final model = _mapSupabaseUserToUserModel(user);
        _cachedUser = model;
        completer.complete(model);
        tempSub.cancel();
      }
    });

    try {
      final launched = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
      );

      if (!launched) {
        tempSub.cancel();
        throw const AuthException('Could not launch Google Sign-In browser.');
      }

      // Await OAuth callback completion or timeout
      return await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          tempSub.cancel();
          throw const AuthException('Google Sign-In was cancelled or timed out.');
        },
      );
    } catch (e) {
      tempSub.cancel();
      rethrow;
    }
  }

  @override
  Future<void> updateDisplayName({
    required String userId,
    required String displayName,
  }) async {
    final clean = displayName.trim();
    final response = await _client.auth.updateUser(
      UserAttributes(
        data: {
          'display_name': clean,
        },
      ),
    );

    final updatedUser = response.user ?? _client.auth.currentUser;
    if (updatedUser != null) {
      _cachedUser = _mapSupabaseUserToUserModel(updatedUser);
      _controller.add(_cachedUser);
    }
  }

  @override
  Future<void> setWelcomeNoticeCompleted({required String userId}) async {
    final response = await _client.auth.updateUser(
      UserAttributes(
        data: {
          'has_completed_welcome': true,
        },
      ),
    );

    final updatedUser = response.user ?? _client.auth.currentUser;
    if (updatedUser != null) {
      _cachedUser = _mapSupabaseUserToUserModel(updatedUser);
      _controller.add(_cachedUser);
    }
  }

  @override
  Future<bool> hasCompletedWelcomeNotice({required String userId}) async {
    final user = _client.auth.currentUser;
    if (user != null && user.id == userId) {
      return user.userMetadata?['has_completed_welcome'] == true;
    }
    return false;
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
    _cachedUser = null;
    _controller.add(null);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _controller.close();
  }
}
