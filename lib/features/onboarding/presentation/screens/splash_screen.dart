import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Cold start to check-in transition
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go(AppRoutes.checkIn);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
