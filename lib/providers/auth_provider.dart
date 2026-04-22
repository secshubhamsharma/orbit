import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';

/// Exposes the [AuthService] singleton so the rest of the app can read it via
/// `ref.read(authServiceProvider)` without creating multiple instances.
final authServiceProvider = Provider<AuthService>(
  (_) => AuthService.instance,
);

/// Streams the Firebase auth state. Use this wherever the app needs to react
/// to sign-in / sign-out events in real time.
///
/// AsyncValue states:
///   - loading  → Firebase hasn't emitted yet (first frame).
///   - data(null) → no user signed in.
///   - data(User) → a user is signed in.
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.read(authServiceProvider).authStateChanges,
);

/// Synchronous snapshot of the current [User]. Returns `null` when signed out.
/// Derived from [authStateProvider] so it always stays in sync.
final currentUserProvider = Provider<User?>(
  (ref) => ref.watch(authStateProvider).valueOrNull,
);
