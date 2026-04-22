import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/errors/app_exception.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ---------------------------------------------------------------------------
  // Streams & getters
  // ---------------------------------------------------------------------------

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // ---------------------------------------------------------------------------
  // Email / password
  // ---------------------------------------------------------------------------

  Future<UserCredential> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(displayName.trim());
      // Non-fatal: account is already created at this point.
      // If verification email fails (quota, App Check, etc.) the user
      // can resend it from the verify-email screen.
      try {
        await credential.user?.sendEmailVerification();
      } catch (_) {}
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Google Sign-In
  // ---------------------------------------------------------------------------

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final googleAccount = await _googleSignIn.signIn();
      if (googleAccount == null) {
        return null;
      }

      final googleAuth = await googleAccount.authentication;
      if (googleAuth.idToken == null || googleAuth.idToken!.isEmpty) {
        throw const AuthException(
          'Google sign-in is not configured correctly for this app yet. '
          'Please check the Firebase OAuth setup and try again.',
          code: 'google-id-token-missing',
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on PlatformException catch (e) {
      throw _mapGooglePlatformError(e);
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    } catch (e) {
      throw AuthException('Google sign-in failed. Please try again.');
    }
  }

  // ---------------------------------------------------------------------------
  // Password reset & email verification
  // ---------------------------------------------------------------------------

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  /// Reloads the current user from Firebase and returns whether the email is
  /// verified. Returns [false] if there is no signed-in user.
  Future<bool> reloadAndCheckVerification() async {
    try {
      await _auth.currentUser?.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Sign-out
  // ---------------------------------------------------------------------------

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Error mapping
  // ---------------------------------------------------------------------------

  AuthException _mapError(FirebaseAuthException e) {
    final message = switch (e.code) {
      'user-not-found' => 'No account found with this email.',
      'wrong-password' || 'invalid-credential' =>
        'Incorrect email or password.',
      'email-already-in-use' =>
        'An account with this email already exists.',
      'too-many-requests' =>
        'Too many attempts. Please wait and try again.',
      'network-request-failed' =>
        'Network error. Check your connection and try again.',
      'user-disabled' =>
        'This account has been disabled. Please contact support.',
      'weak-password' =>
        'Password is too weak. Please choose a stronger password.',
      'invalid-email' => 'Please enter a valid email address.',
      'operation-not-allowed' =>
        'This sign-in method is not enabled. Please contact support.',
      'requires-recent-login' =>
        'Please sign out and sign in again to continue.',
      _ => 'Something went wrong. Please try again.',
    };
    return AuthException(message, code: e.code);
  }

  AuthException _mapGooglePlatformError(PlatformException e) {
    final code = e.code.toLowerCase();
    final details = '${e.message ?? ''} ${e.details ?? ''}'.toLowerCase();

    if (code.contains('sign_in_canceled') || code.contains('canceled')) {
      return const AuthException(
        'Google sign-in was cancelled.',
        code: 'google-sign-in-cancelled',
      );
    }

    if (details.contains('10') ||
        details.contains('developer_error') ||
        details.contains('config') ||
        details.contains('oauth')) {
      return const AuthException(
        'Google sign-in is not configured correctly for this app yet. '
        'Please add the required Firebase OAuth client and SHA fingerprints.',
        code: 'google-sign-in-misconfigured',
      );
    }

    if (code.contains('network') || details.contains('network')) {
      return const AuthException(
        'Network error while signing in with Google. Please try again.',
        code: 'google-sign-in-network',
      );
    }

    return AuthException(
      e.message ?? 'Google sign-in failed. Please try again.',
      code: e.code,
    );
  }
}
