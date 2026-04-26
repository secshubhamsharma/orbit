import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionService {
  PermissionService._();

  static const _requestedKey = 'initial_permissions_requested';

  static Future<void> requestInitialPermissions(
    SharedPreferences prefs,
  ) async {
    final alreadyRequested = prefs.getBool(_requestedKey) ?? false;
    if (alreadyRequested) return;

    final permissions = <Permission>[
      Permission.notification,
    ];

    for (final permission in permissions) {
      try {
        final status = await permission.status;
        if (status.isDenied || status.isRestricted || status.isLimited) {
          await permission.request();
        }
      } catch (_) {
        // Best-effort only — permission prompts should never block app startup.
      }
    }

    await prefs.setBool(_requestedKey, true);
  }
}
