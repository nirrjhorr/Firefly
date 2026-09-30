import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/security/network_kill_switch.dart';
import 'core/theme/app_theme.dart';

void main() async {
  // CRITICAL SECURITY RULE: Block all outbound HTTP requests globally before anything else.
  HttpOverrides.global = FireflyHttpOverride();

  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation to prevent layout distortion in distress states
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: FireflyApp(),
    ),
  );
}

class FireflyApp extends ConsumerWidget {
  const FireflyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Firefly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // Default to low-stimulation dark canvas, respect system mode
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
