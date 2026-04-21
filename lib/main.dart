import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // prevent Google Fonts from hitting the network on every cold start —
  // fonts must be bundled in assets/fonts/ for offline use
  GoogleFonts.config.allowRuntimeFetching = false;

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);


  runApp(
    const ProviderScope(
      child: OrbitApp(),
    ),
  );
}
