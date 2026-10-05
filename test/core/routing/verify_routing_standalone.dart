import '../../../lib/core/routing/app_routes.dart';

void main() {
  print('=== Verifying App Route Constants & Paths ===');

  // Verify core routes
  assert(AppRoutes.splash == '/', 'Splash path mismatch');
  assert(AppRoutes.onboarding == '/onboarding', 'Onboarding path mismatch');
  assert(AppRoutes.privacyLock == '/privacy-lock', 'Privacy lock path mismatch');
  assert(AppRoutes.safetyPlan == '/safety-plan', 'Safety plan path mismatch');
  assert(AppRoutes.safetyPlanEditor == '/safety-plan/edit', 'Safety plan editor path mismatch');
  assert(AppRoutes.panicBlank == '/panic', 'Panic blank path mismatch');

  // Verify shell routes
  assert(AppRoutes.home == '/home', 'Home path mismatch');
  assert(AppRoutes.checkIn == '/home/check-in', 'Check-in path mismatch');
  assert(AppRoutes.breathe == '/home/breathe', 'Breathe path mismatch');
  assert(AppRoutes.journal == '/home/journal', 'Journal path mismatch');
  assert(AppRoutes.tinySteps == '/home/tiny-steps', 'Tiny steps path mismatch');
  assert(AppRoutes.progress == '/home/progress', 'Progress path mismatch');
  assert(AppRoutes.loneliness == '/home/loneliness', 'Loneliness path mismatch');
  assert(AppRoutes.soundscapes == '/home/soundscapes', 'Soundscapes path mismatch');

  // Verify v2 new routes
  assert(AppRoutes.pmr == '/home/pmr', 'PMR path mismatch');
  assert(AppRoutes.rightNow == '/home/right-now', 'Right Now path mismatch');

  print('All 16 routes verified:');
  print(' - Splash: ${AppRoutes.splash}');
  print(' - CheckIn: ${AppRoutes.checkIn}');
  print(' - Breathe: ${AppRoutes.breathe}');
  print(' - PMR: ${AppRoutes.pmr}');
  print(' - Right Now: ${AppRoutes.rightNow}');
  print(' - Safety Plan: ${AppRoutes.safetyPlan}');
  print(' - Panic Blank: ${AppRoutes.panicBlank}');

  print('=== All Routing Assertions PASSED successfully! ===');
}
