import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbitapp/models/user_model.dart';
import 'package:orbitapp/services/firestore_service.dart';

import 'auth_provider.dart';

/// Real-time stream of the signed-in user's Firestore document.
///
/// Emits `null` when:
///   - No user is authenticated.
///   - The document does not exist yet (e.g. during signup before the write).
///   - Auth state is still loading.
final userProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return FirestoreService.instance.userStream(user.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});
