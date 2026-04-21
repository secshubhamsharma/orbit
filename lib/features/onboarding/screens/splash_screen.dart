import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.kBackground,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.public_rounded, size: 64, color: AppColors.kPrimary),
            SizedBox(height: 16),
            Text('Orbit', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.kTextPrimary)),
          ],
        ),
      ),
    );
  }
}
