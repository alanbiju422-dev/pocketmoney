import '../models/user_model.dart';

/// Contract for Google Authentication and User Profile lifecycle.
abstract class AuthRepository {
  /// Get current signed in user, if any.
  Future<UserModel?> getCurrentUser();

  /// Stream of authentication state changes.
  Stream<UserModel?> watchCurrentUser();

  /// Authenticate with Google.
  Future<UserModel> signInWithGoogle({
    String? email,
    String? initialDisplayName,
  });

  /// Update the user's custom display name.
  Future<void> updateDisplayName({
    required String userId,
    required String displayName,
  });

  /// Mark the Welcome & Privacy notice as completed for the specific user account.
  Future<void> setWelcomeNoticeCompleted({required String userId});

  /// Check whether the specific user account has completed the Welcome & Privacy notice.
  Future<bool> hasCompletedWelcomeNotice({required String userId});

  /// Sign out current user.
  Future<void> signOut();

  /// Dispose resources.
  void dispose();
}
