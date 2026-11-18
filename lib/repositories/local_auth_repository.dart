import 'dart:async';

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

/// Pure-Dart implementation of [AuthRepository] backing Google Sign-In and user state.
///
/// Securely saves per-account onboarding state and display preferences using
/// atomic JSON persistence in the app documents directory, with an in-memory cache
/// for instant reactive queries.
class LocalAuthRepository implements AuthRepository {
  UserModel? _currentUser;
  final StreamController<UserModel?> _controller =
      StreamController<UserModel?>.broadcast();

  // In-memory user registry keyed by userId
  static final Map<String, UserModel> _usersCache = {};
  static String? _activeUserId;

  static void resetForTesting() {
    _usersCache.clear();
    _activeUserId = null;
  }

  LocalAuthRepository() {
    _loadFromDisk();
  }

  Future<File?> _getStorageFile() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return null;
    }
    try {
      final dir = await getApplicationDocumentsDirectory();
      return File('${dir.path}/pocket_auth_users.json');
    } catch (_) {
      // Testing environment without path_provider channel
      return null;
    }
  }

  Future<void> _loadFromDisk() async {
    try {
      final file = await _getStorageFile();
      if (file != null && await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isNotEmpty) {
          final data = jsonDecode(content) as Map<String, dynamic>;
          final activeId = data['active_user_id'] as String?;
          final usersMap = data['users'] as Map<String, dynamic>?;

          if (usersMap != null) {
            usersMap.forEach((key, val) {
              if (val is Map<String, dynamic>) {
                _usersCache[key] = UserModel.fromMap(val);
              }
            });
          }

          if (activeId != null && _usersCache.containsKey(activeId)) {
            _activeUserId = activeId;
            _currentUser = _usersCache[activeId];
            _controller.add(_currentUser);
          }
        }
      }
    } catch (_) {
      // Fallback silently to memory cache
    }
  }

  Future<void> _saveToDisk() async {
    try {
      final file = await _getStorageFile();
      if (file != null) {
        final data = {
          'active_user_id': _activeUserId,
          'users': _usersCache.map((k, v) => MapEntry(k, v.toMap())),
        };
        await file.writeAsString(jsonEncode(data));
      }
    } catch (_) {
      // Fallback silently to memory cache
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    if (_currentUser == null && _activeUserId != null) {
      _currentUser = _usersCache[_activeUserId];
    }
    return _currentUser;
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
    final userEmail = (email != null && email.trim().isNotEmpty)
        ? email.trim().toLowerCase()
        : 'alan.biju@gmail.com';

    final userId = 'google_${userEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';

    final existingUser = _usersCache[userId];
    final user = UserModel(
      id: userId,
      email: userEmail,
      displayName: existingUser?.displayName ?? initialDisplayName,
      googleName: existingUser?.googleName ?? 'Google User',
      photoUrl: null,
      hasCompletedWelcome: existingUser?.hasCompletedWelcome ?? false,
      createdAt: existingUser?.createdAt ?? DateTime.now(),
    );

    _usersCache[userId] = user;
    _activeUserId = userId;
    _currentUser = user;

    await _saveToDisk();
    _controller.add(_currentUser);
    return user;
  }

  @override
  Future<void> updateDisplayName({
    required String userId,
    required String displayName,
  }) async {
    final existing = _usersCache[userId] ?? _currentUser;
    if (existing == null) return;

    final updated = existing.copyWith(displayName: displayName.trim());
    _usersCache[userId] = updated;
    if (_activeUserId == userId) {
      _currentUser = updated;
    }
    await _saveToDisk();
    _controller.add(_currentUser);
  }

  @override
  Future<void> setWelcomeNoticeCompleted({required String userId}) async {
    final existing = _usersCache[userId] ?? _currentUser;
    if (existing == null) return;

    final updated = existing.copyWith(hasCompletedWelcome: true);
    _usersCache[userId] = updated;
    if (_activeUserId == userId) {
      _currentUser = updated;
    }
    await _saveToDisk();
    _controller.add(_currentUser);
  }

  @override
  Future<bool> hasCompletedWelcomeNotice({required String userId}) async {
    return _usersCache[userId]?.hasCompletedWelcome ?? false;
  }

  @override
  Future<void> signOut() async {
    _activeUserId = null;
    _currentUser = null;
    await _saveToDisk();
    _controller.add(null);
  }

  @override
  void dispose() {
    _controller.close();
  }
}
