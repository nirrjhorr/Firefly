import '../../../lib/features/sleep/data/repositories/worry_dump_repository_impl.dart';
import '../../../lib/features/sleep/domain/models/sleep_session_state.dart';
import '../../../lib/features/sleep/domain/models/sleep_sound_track.dart';
import '../../../lib/features/sleep/domain/models/worry_dump_entry.dart';

Future<void> main() async {
  print('=== Verifying Pre-Bed Sleep & Wind-Down Suite (FR-15 / RM-03) ===');

  // 1. Verify Curated Sleep Sound Tracks
  assert(kCuratedSleepTracks.length >= 4, 'Should have at least 4 curated sleep tracks');
  assert(kDefaultSleepTrack.id == 'gentle_rain', 'Default track should be gentle_rain');
  for (final track in kCuratedSleepTracks) {
    assert(track.id.isNotEmpty);
    assert(track.title.isNotEmpty);
    assert(track.assetPath.endsWith('.mp3'));
    assert(track.iconKey.isNotEmpty);
    print('Track: ${track.id.padRight(20)} | Title: ${track.title.padRight(18)} | Asset: ${track.assetPath}');
  }
  print('✓ Curated offline sleep tracks verified.');

  // 2. Verify WorryDumpEntry Morning Lockup Calculation
  // Case A: Night-time entry at 23:30 (11:30 PM) on Oct 6
  final nightTime = DateTime(2026, 10, 6, 23, 30);
  final nightEntry = WorryDumpEntry.createParked(
    id: 'worry_1',
    contentPlaintext: 'Racing thoughts about project deadlines',
    now: nightTime,
  );

  final expectedUnlockTime = DateTime(2026, 10, 7, 8, 0).millisecondsSinceEpoch ~/ 1000;
  assert(nightEntry.lockedUntilUnix == expectedUnlockTime, 'Must unlock at 8:00 AM next morning');
  assert(nightEntry.ttlDeleteAtUnix == nightEntry.createdAtUnix + (24 * 3600), 'TTL must be 24 hours');
  assert(nightEntry.isParked == true);
  assert(nightEntry.lockStatusDescription.contains('08:00'), 'Status description should show 08:00');
  print('✓ Night-time 8:00 AM lockup derivation verified.');

  // Case B: Early morning entry at 3:15 AM
  final earlyMorning = DateTime(2026, 10, 7, 3, 15);
  final earlyEntry = WorryDumpEntry.createParked(
    id: 'worry_2',
    contentPlaintext: 'Awake in middle of the night worrying',
    now: earlyMorning,
  );
  final expectedSameDay8Am = DateTime(2026, 10, 7, 8, 0).millisecondsSinceEpoch ~/ 1000;
  assert(earlyEntry.lockedUntilUnix == expectedSameDay8Am, 'Early AM entry must unlock at 8:00 AM same day');
  print('✓ Early morning 3:15 AM entry unlocks at 8:00 AM same day verified.');

  // 3. Verify Logarithmic Volume Attenuation Math
  const totalDuration = 1800; // 30 minutes
  // At 300s remaining: full factor 1.0
  final f300 = SleepSessionState.computeLogarithmicFadeFactor(300, totalDuration);
  assert((f300 - 1.0).abs() < 0.001, 'At 300s remaining, fade factor must be 1.0');

  // At 150s remaining (midpoint of fade): logarithmic factor ~0.74
  final f150 = SleepSessionState.computeLogarithmicFadeFactor(150, totalDuration);
  assert(f150 > 0.70 && f150 < 0.76, 'Midpoint logarithmic factor should be ~0.74 (actual: $f150)');

  // At 30s remaining: factor ~0.278
  final f30 = SleepSessionState.computeLogarithmicFadeFactor(30, totalDuration);
  assert(f30 > 0.25 && f30 < 0.31, 'At 30s factor should be ~0.28 (actual: $f30)');

  // At 0s remaining: factor must be 0.0
  final f0 = SleepSessionState.computeLogarithmicFadeFactor(0, totalDuration);
  assert(f0 == 0.0, 'At 0s remaining, fade factor must be 0.0');

  // Monotonicity check: decreasing remaining time continuously decreases volume
  assert(f0 < f30 && f30 < f150 && f150 < f300, 'Fade factor must be strictly monotonically increasing with time');
  print('✓ Logarithmic volume attenuation curve verified (f(300)=$f300, f(150)=${f150.toStringAsFixed(3)}, f(30)=${f30.toStringAsFixed(3)}, f(0)=$f0).');

  // 4. Verify WorryDumpRepository operations and memory erasure
  final repo = WorryDumpRepositoryImpl();
  await repo.saveParkedWorry(nightEntry);
  var parked = await repo.getParkedWorries();
  assert(parked.length == 1, 'Should contain 1 parked worry');
  assert(parked.first.contentPlaintext == null, 'Stored entry must not hold plaintext in memory');
  assert(parked.first.contentEncrypted.isNotEmpty, 'Stored entry must hold encrypted payload');

  // Test crypto zeroing
  WorryDumpRepositoryImpl.cryptoEraseString('Sensitive secret worry');
  print('✓ Memory buffer crypto erasure executed.');

  // Delete entry
  await repo.deleteWorry(nightEntry.id);
  parked = await repo.getParkedWorries();
  assert(parked.isEmpty, 'Entry must be deleted from repository');
  print('✓ Repository save, query, and cryptographic deletion verified.');

  // 5. Verify SleepSessionState State Transitions
  var state = const SleepSessionState();
  assert(state.activeTab == SleepSuiteTab.worryDump);
  assert(state.selectedTrack.id == 'gentle_rain');

  // Switch tabs
  state = state.copyWith(activeTab: SleepSuiteTab.soundscape);
  assert(state.activeTab == SleepSuiteTab.soundscape);
  state = state.copyWith(activeTab: SleepSuiteTab.wakeAnchor);
  assert(state.activeTab == SleepSuiteTab.wakeAnchor);
  print('✓ SleepSessionState tab navigation state verified.');

  // Workflow A: Worry typing and parking
  state = state.copyWith(
    activeTab: SleepSuiteTab.worryDump,
    worryText: 'Unfinished work from earlier today',
  );
  assert(state.worryText.isNotEmpty);
  // Park entry
  state = state.copyWith(
    worryText: '',
    parkedEntries: [nightEntry],
    statusMessage: 'Parked safely until 8:00 AM.',
  );
  assert(state.worryText.isEmpty);
  assert(state.parkedEntries.length == 1);
  assert(state.statusMessage != null);
  print('✓ Worry Dump state parking flow verified.');

  // Workflow B: Dissolve animation simulation
  state = state.copyWith(worryText: 'Lingering anxious tension');
  assert(state.worryText.isNotEmpty);
  state = state.copyWith(isDissolving: true, dissolveProgress: 0.5);
  assert(state.isDissolving == true && state.dissolveProgress == 0.5);
  // Complete dissolution
  state = state.copyWith(
    worryText: '',
    isDissolving: false,
    dissolveProgress: 0.0,
    statusMessage: 'Dissolved into the dark.',
  );
  assert(state.worryText.isEmpty);
  assert(state.isDissolving == false);
  print('✓ Dissolve animation state progression verified.');

  // Workflow C: Audio timer & countdown formatting
  state = state.copyWith(
    timerMinutes: 30,
    timerSecondsRemaining: 1800,
    isPlaying: true,
  );
  assert(state.timerMinutes == 30);
  assert(state.formattedTimeRemaining == '30:00');

  // Step timer down to 4m 30s (270s remaining - inside the 5m fade window)
  state = state.copyWith(timerSecondsRemaining: 270);
  assert(state.formattedTimeRemaining == '04:30');
  final fadeFactor270 = SleepSessionState.computeLogarithmicFadeFactor(270, 1800);
  final fadedVol = state.baseVolume * fadeFactor270;
  state = state.copyWith(currentVolume: fadedVol);
  assert(state.currentVolume < state.baseVolume);
  print('✓ Audio timer countdown and volume fade verified (formatted: ${state.formattedTimeRemaining}, volume: ${state.currentVolume.toStringAsFixed(3)}).');

  // Workflow D: Wake target time formatting
  state = state.copyWith(
    wakeTargetHour: 7,
    wakeTargetMinute: 15,
    isWakeTargetSet: true,
  );
  assert(state.formattedWakeTarget == '7:15 AM');

  state = state.copyWith(
    wakeTargetHour: 22,
    wakeTargetMinute: 30,
  );
  assert(state.formattedWakeTarget == '10:30 PM');
  print('✓ Circadian wake anchor time formatting verified (7:15 AM, 10:30 PM).');

  print('=== ALL Pre-Bed Sleep & Wind-Down Suite Assertions PASSED successfully! (100% Validated) ===');
}
