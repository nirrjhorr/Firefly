import 'package:flutter_test/flutter_test.dart';
import 'package:firefly/core/database/tables/mood_check_ins.dart';
import 'package:firefly/core/database/tables/journal_entries.dart';
import 'package:firefly/core/database/tables/safety_plan_tables.dart';
import 'package:firefly/core/database/tables/audio_preferences.dart';
import 'package:firefly/core/database/tables/app_configuration.dart';
import 'package:firefly/core/database/tables/usage_summaries.dart';

void main() {
  group('Database Schema Tables', () {
    test('All Drift table schemas instantiate properly', () {
      final moodCheckIns = MoodCheckIns();
      final journalEntries = JournalEntries();
      final safetyPlans = SafetyPlans();
      final safetyPlanContacts = SafetyPlanContacts();
      final safetyPlanWarnings = SafetyPlanWarnings();
      final safetyPlanSteps = SafetyPlanSteps();
      final audioPreferences = AudioPreferences();
      final appConfig = AppConfiguration();
      final usageSummaries = UsageSummaries();

      expect(moodCheckIns.primaryKey.length, equals(1));
      expect(journalEntries.primaryKey.length, equals(1));
      expect(safetyPlans.primaryKey.length, equals(1));
      expect(safetyPlanContacts.primaryKey.length, equals(1));
      expect(safetyPlanWarnings.primaryKey.length, equals(1));
      expect(safetyPlanSteps.primaryKey.length, equals(1));
      expect(audioPreferences.primaryKey.length, equals(1));
      expect(appConfig.primaryKey.length, equals(1));
      expect(usageSummaries.primaryKey.length, equals(1));
    });
  });
}
