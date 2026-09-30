import 'package:drift/drift.dart';
import '../app_database.dart';

/// Runs versioned, additive schema migrations for Firefly.
Future<void> runDatabaseMigrations(
  AppDatabase db,
  Migrator m,
  int from,
  int to,
) async {
  // Monotonically increasing schema migrations
  // v1 is initial baseline. Future migrations will be gated by `if (from < X)`
}
