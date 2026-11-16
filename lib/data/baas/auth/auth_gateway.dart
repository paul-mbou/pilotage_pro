import 'package:pilotage_pro/data/baas/auth/auth_user.dart';

abstract class AuthGateway {
  Future<AuthUser?> getCurrentUser();

  Future<AuthUser?> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  });

  Future<AuthUser?> signInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<AuthUser?> signInWithGoogle();

  Future<AuthUser?> signInWithApple();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();
}
