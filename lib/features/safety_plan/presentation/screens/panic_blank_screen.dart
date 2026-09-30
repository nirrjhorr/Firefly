import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/security/biometric_guard.dart';
import '../controllers/safety_plan_controller.dart';

class PanicBlankScreen extends ConsumerStatefulWidget {
  const PanicBlankScreen({super.key});

  @override
  ConsumerState<PanicBlankScreen> createState() => _PanicBlankScreenState();
}

class _PanicBlankScreenState extends ConsumerState<PanicBlankScreen> {
  @override
  void initState() {
    super.initState();
    _executePanicPurge();
  }

  Future<void> _executePanicPurge() async {
    // Phase 1 (< 10ms): Blank screen rendered immediately (Container black)
    // Phase 2 (< 50ms): Invalidate providers with sensitive state
    ref.invalidate(safetyPlanControllerProvider);

    // Phase 3 (< 100ms): Lock the app and drop database key
    ref.read(biometricGuardProvider).lockApp();

    // Phase 4: Minimize or exit application
    await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(),
    );
  }
}
