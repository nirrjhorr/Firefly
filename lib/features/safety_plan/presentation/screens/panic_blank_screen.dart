import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/security/biometric_guard.dart';
import '../../../../core/security/panic_cryptographic_service.dart';
import '../../../check_in/presentation/controllers/check_in_controller.dart';
import '../../../journaling/presentation/controllers/journal_editor_controller.dart';
import '../../../journaling/presentation/controllers/journal_list_controller.dart';
import '../../../tiny_steps/presentation/controllers/tiny_steps_controller.dart';
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
    // Phase 1 (< 10ms): Instant black screen rendering (pure Black Container)
    
    // Phase 2 (< 50ms): Invalidate all sensitive state providers & lock database key
    final panicService = ref.read(panicCryptographicServiceProvider);
    final biometricGuard = ref.read(biometricGuardProvider);

    await panicService.profileAndExecutePanicPipeline(
      biometricGuard: biometricGuard,
      providerInvalidators: [
        () => ref.invalidate(safetyPlanControllerProvider),
        () => ref.invalidate(checkInControllerProvider),
        () => ref.invalidate(journalEditorControllerProvider),
        () => ref.invalidate(journalListControllerProvider),
        () => ref.invalidate(tinyStepsControllerProvider),
      ],
    );

    // Phase 3 (< 100ms): Minimize or exit application to prevent screen snapshots
    try {
      await SystemNavigator.pop();
    } catch (_) {
      // Graceful fallback on testing / non-mobile targets
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(),
    );
  }
}
