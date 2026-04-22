import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_options.dart';

/// Firebase initialisation future started before [runApp].
/// The splash screen awaits this so navigation never fires before Firebase
/// is ready — but [runApp] is no longer blocked, so Flutter draws its first
/// frame (and the splash animation begins) as fast as possible.
Future<FirebaseApp>? orbitFirebaseFuture;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Kick off async work immediately — do NOT await here.
  // Dart runs these concurrently with the Flutter engine rendering the first
  // frame, cutting the blank-window delay from ~500 ms to near zero.
  orbitFirebaseFuture = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A0B14),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(
    const ProviderScope(
      child: OrbitApp(),
    ),
  );
}
