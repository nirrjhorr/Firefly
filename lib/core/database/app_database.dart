import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'migrations/migration_runner.dart';
import 'tables/app_configuration.dart';
import 'tables/audio_preferences.dart';
import 'tables/journal_entries.dart';
import 'tables/mood_check_ins.dart';
import 'tables/safety_plan_tables.dart';
import 'tables/usage_summaries.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  MoodCheckIns,
  JournalEntries,
  SafetyPlans,
  SafetyPlanContacts,
  SafetyPlanWarnings,
  SafetyPlanSteps,
  AudioPreferences,
  AppConfiguration,
  UsageSummaries,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor, {this.encryptionKey});

  final String? encryptionKey;

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => await m.createAll(),
        onUpgrade: (m, from, to) async {
          await runDatabaseMigrations(this, m, from, to);
        },
        beforeOpen: (details) async {
          if (encryptionKey != null && encryptionKey!.isNotEmpty) {
            final escapedKey = encryptionKey!.replaceAll("'", "''");
            await customStatement("PRAGMA key = '$escapedKey';");
            await customStatement('PRAGMA cipher_page_size = 4096;');
            await customStatement('PRAGMA kdf_iter = 256000;');
            await customStatement('PRAGMA cipher_hmac_algorithm = HMAC_SHA512;');
            await customStatement('PRAGMA cipher_default_kdf_algorithm = PBKDF2_HMAC_SHA512;');
          }
          // Enforce foreign key constraints
          await customStatement('PRAGMA foreign_keys = ON;');
          // WAL mode for crash safety & concurrency
          await customStatement('PRAGMA journal_mode = WAL;');
          // Mobile page size optimization
          await customStatement('PRAGMA page_size = 4096;');
          // Overwrite deleted data with zeros
          await customStatement('PRAGMA secure_delete = ON;');
        },
      );
}

/// Creates and configures the encrypted Drift database instance with SQLCipher.
AppDatabase openEncryptedDatabase({
  required String encryptionKey,
  String dbName = 'firefly_encrypted.db',
}) {
  final executor = SqfliteQueryExecutor.inDatabaseFolder(
    path: dbName,
    singleInstance: true,
  );

  return AppDatabase(executor, encryptionKey: encryptionKey);
}
