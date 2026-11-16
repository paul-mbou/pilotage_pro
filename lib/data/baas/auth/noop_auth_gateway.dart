import 'package:pilotage_pro/data/baas/auth/auth_gateway.dart';
import 'package:pilotage_pro/data/baas/auth/auth_user.dart';

class NoopAuthGateway implements AuthGateway {
  @override
  Future<AuthUser?> getCurrentUser() async => null;

  @override
  Future<AuthUser?> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async =>
      null;

  @override
  Future<AuthUser?> signInWithApple() async => null;

  @override
  Future<AuthUser?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async =>
      null;

  @override
  Future<AuthUser?> signInWithGoogle() async => null;

  @override
  Future<void> signOut() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}
}
