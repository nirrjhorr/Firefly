import 'dart:convert';
import 'dart:io';

import '../../../lib/core/routing/app_routes.dart';
import '../../../lib/features/activities/domain/models/activity_category.dart';
import '../../../lib/features/journaling/domain/models/journal_ttl_option.dart';

void main() {
  stdout.writeln('=== Verifying Story 14.1: Encrypted Worry Dump & Unsent Letters Integration ===');

  // 1. Verify Route Constants
  assert(AppRoutes.unsentLetter == '/home/unsent-letter', 'AppRoutes.unsentLetter mismatch');
  assert(AppRoutes.worryDump == '/home/worry-dump', 'AppRoutes.worryDump mismatch');
  stdout.writeln('✓ Route constants verified: ${AppRoutes.unsentLetter}, ${AppRoutes.worryDump}');

  // 2. Verify TTL Option Matrix
  assert(JournalTtlOption.none.displayName == 'Keep permanently', 'none display mismatch');
  assert(JournalTtlOption.oneHour.displayName == '1 Hour', 'oneHour display mismatch');
  assert(JournalTtlOption.twentyFourHours.displayName == '24 Hours', 'twentyFourHours display mismatch');
  assert(JournalTtlOption.sevenDays.displayName == '7 Days', 'sevenDays display mismatch');
  assert(JournalTtlOption.twentyFourHours.duration == const Duration(hours: 24), '24h duration mismatch');
  stdout.writeln('✓ JournalTtlOption configurations validated.');

  // 3. Verify Activity Category & Fallback Catalog Mapping
  final cat = ActivityCategory.fromString('emotionalExpression');
  assert(cat == ActivityCategory.emotionalExpression, 'Category resolution mismatch');
  assert(cat.displayName == 'Emotional Expression', 'Display name mismatch');
  assert(cat.iconKey == 'pencil.and.outline', 'Icon key mismatch');
  stdout.writeln('✓ ActivityCategory.emotionalExpression properties verified.');

  // 4. Verify Catalog JSON Activity Definitions
  final catalogFile = File('assets/data/curated_activities.json');
  assert(catalogFile.existsSync(), 'Catalog file must exist');
  final dynamic decoded = jsonDecode(catalogFile.readAsStringSync());
  assert(decoded is List, 'Catalog must be a List');

  final activities = (decoded as List).cast<Map<String, dynamic>>();
  final unsent = activities.firstWhere(
    (a) => a['id'] == 'act_unsent_letter',
    orElse: () => throw Exception('act_unsent_letter not found in catalog'),
  );
  assert(unsent['category'] == 'emotionalExpression', 'Unsent letter category mismatch');
  assert(unsent['title'] == 'Unsent Letter', 'Unsent letter title mismatch');

  final worry = activities.firstWhere(
    (a) => a['id'] == 'act_worry_dump',
    orElse: () => throw Exception('act_worry_dump not found in catalog'),
  );
  assert(worry['category'] == 'emotionalExpression', 'Worry dump category mismatch');
  assert(worry['title'] == 'Nighttime Worry Dump', 'Worry dump title mismatch');
  stdout.writeln('✓ Curated activities act_unsent_letter and act_worry_dump validated in JSON catalog.');

  stdout.writeln('=== ALL Story 14.1 Standalone Verifications PASSED successfully! ===');
}
