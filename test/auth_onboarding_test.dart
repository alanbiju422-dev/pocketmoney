import 'package:flutter_test/flutter_test.dart';
import 'package:pocketmoney/providers/auth_provider.dart';
import 'package:pocketmoney/repositories/local_auth_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('First-Time Welcome & Privacy Notice Flow Tests', () {
    late LocalAuthRepository authRepository;
    late AuthProvider authProvider;

    setUp(() {
      LocalAuthRepository.resetForTesting();
      authRepository = LocalAuthRepository();
      authProvider = AuthProvider(repository: authRepository);
    });

    test('Initial unauthenticated state', () {
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.needsDisplayName, isFalse);
      expect(authProvider.needsWelcomeNotice, isFalse);
      expect(authProvider.isReadyForApp, isFalse);
    });

    test('First-time user sign-in -> display name -> welcome notice -> home', () async {
      // 1. User taps Continue with Google (first time, no display name)
      await authProvider.signInWithGoogle(email: 'newuser@gmail.com');

      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.email, equals('newuser@gmail.com'));
      // Step 4: Needs display name
      expect(authProvider.needsDisplayName, isTrue);
      expect(authProvider.needsWelcomeNotice, isFalse);
      expect(authProvider.isReadyForApp, isFalse);

      // Step 5: Save display name
      await authProvider.saveDisplayName('John Doe');
      expect(authProvider.currentUser?.displayName, equals('John Doe'));
      expect(authProvider.needsDisplayName, isFalse);
      // Now needs Welcome & Privacy notice
      expect(authProvider.needsWelcomeNotice, isTrue);
      expect(authProvider.isReadyForApp, isFalse);

      // Step 6: User acknowledges "I Understand & Start"
      await authProvider.completeWelcomeNotice();
      expect(authProvider.needsWelcomeNotice, isFalse);
      // Step 7: Ready for Home screen
      expect(authProvider.isReadyForApp, isTrue);
      expect(authProvider.currentUser?.hasCompletedWelcome, isTrue);
    });

    test('Returning user does NOT repeat onboarding', () async {
      // Sign in and complete onboarding
      await authProvider.signInWithGoogle(email: 'returning@gmail.com');
      await authProvider.saveDisplayName('Alice Smith');
      await authProvider.completeWelcomeNotice();
      expect(authProvider.isReadyForApp, isTrue);

      // Sign out
      await authProvider.signOut();
      expect(authProvider.isAuthenticated, isFalse);

      // Returning user signs in again
      await authProvider.signInWithGoogle(email: 'returning@gmail.com');
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.needsDisplayName, isFalse);
      expect(authProvider.needsWelcomeNotice, isFalse);
      expect(authProvider.isReadyForApp, isTrue);
    });

    test('Multiple accounts on same device: onboarding is tracked per user account', () async {
      // User 1 completes onboarding
      await authProvider.signInWithGoogle(email: 'user1@gmail.com');
      await authProvider.saveDisplayName('User One');
      await authProvider.completeWelcomeNotice();
      expect(authProvider.isReadyForApp, isTrue);

      await authProvider.signOut();

      // User 2 signs in on the same device (has not onboarded yet)
      await authProvider.signInWithGoogle(email: 'user2@gmail.com');
      expect(authProvider.needsDisplayName, isTrue);
      expect(authProvider.isReadyForApp, isFalse);

      // User 2 completes display name
      await authProvider.saveDisplayName('User Two');
      expect(authProvider.needsWelcomeNotice, isTrue);

      // User 2 completes notice
      await authProvider.completeWelcomeNotice();
      expect(authProvider.isReadyForApp, isTrue);

      await authProvider.signOut();

      // User 1 signs back in -> still onboarded!
      await authProvider.signInWithGoogle(email: 'user1@gmail.com');
      expect(authProvider.isReadyForApp, isTrue);
      expect(authProvider.needsWelcomeNotice, isFalse);

      await authProvider.signOut();

      // User 2 signs back in -> still onboarded!
      await authProvider.signInWithGoogle(email: 'user2@gmail.com');
      expect(authProvider.isReadyForApp, isTrue);
      expect(authProvider.needsWelcomeNotice, isFalse);
    });

    test('Display name validation prevents empty input', () async {
      await authProvider.signInWithGoogle(email: 'test@gmail.com');

      expect(
        () => authProvider.saveDisplayName('   '),
        throwsA(isA<Exception>()),
      );
    });
  });
}
