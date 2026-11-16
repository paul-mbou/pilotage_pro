import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pilotage_pro/data/baas/auth/auth_gateway.dart';
import 'package:pilotage_pro/data/baas/auth/auth_user.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class FirebaseAuthGateway implements AuthGateway {
  FirebaseAuthGateway({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Future<AuthUser?> getCurrentUser() async => _mapUser(_auth.currentUser);

  @override
  Future<AuthUser?> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (displayName != null && displayName.trim().isNotEmpty) {
        await credential.user?.updateDisplayName(displayName.trim());
      }
      return _mapUser(credential.user);
    } on FirebaseAuthException {
      return null;
    }
  }

  @override
  Future<AuthUser?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _mapUser(credential.user);
    } on FirebaseAuthException {
      return null;
    }
  }

  @override
  Future<AuthUser?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        final credential = await _auth.signInWithPopup(googleProvider);
        return _mapUser(credential.user);
      }

      final googleUser = await GoogleSignIn(scopes: <String>['email']).signIn();
      if (googleUser == null) {
        return null;
      }
      final googleAuth = await googleUser.authentication;
      final oauthCredential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      final credential = await _auth.signInWithCredential(oauthCredential);
      return _mapUser(credential.user);
    } on FirebaseAuthException {
      return null;
    }
  }

  @override
  Future<AuthUser?> signInWithApple() async {
    if (kIsWeb || (!Platform.isIOS && !Platform.isMacOS)) {
      return null;
    }
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: <AppleIDAuthorizationScopes>[
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      final credential = await _auth.signInWithCredential(oauthCredential);
      return _mapUser(credential.user);
    } on FirebaseAuthException {
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<void> signOut() => _auth.signOut();

  AuthUser? _mapUser(User? user) {
    if (user?.email == null) {
      return null;
    }
    return AuthUser(
      id: user!.uid,
      email: user.email!,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }
}
