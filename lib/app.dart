import 'package:flutter/material.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class OrbitApp extends StatelessWidget {
  const OrbitApp({super.key});

  // Built once at class load time — never re-computed on rebuilds.
  static final _dark  = AppTheme.dark;
  static final _light = AppTheme.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Orbit',
      debugShowCheckedModeBanner: false,
      theme: _light,
      darkTheme: _dark,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}
