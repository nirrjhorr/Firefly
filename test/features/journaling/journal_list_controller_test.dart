import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firefly/core/database/daos/journal_dao.dart';
import 'package:firefly/core/security/journal_crypto_service.dart';
import 'package:firefly/core/security/key_manager.dart';
import 'package:firefly/features/journaling/data/repositories/journal_repository_impl.dart';
import 'package:firefly/features/journaling/domain/models/journal_entry.dart';
import 'package:firefly/features/journaling/domain/repositories/journal_repository.dart';
import 'package:firefly/features/journaling/presentation/controllers/journal_list_controller.dart';

class MockKeyManager extends Mock implements KeyManager {}

void main() {
  group('JournalListController', () {
    late JournalCryptoService cryptoService;
    late MockKeyManager mockKeyManager;
    late InMemoryJournalDao dao;
    late JournalRepository repository;

    const testMasterKey = 'dGhpcy1pcy1hLXNlY3VyZS0yNTYtYml0LW1hc3Rlci1rZXk=';
    final nowUnix = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    setUp(() {
      cryptoService = JournalCryptoService();
      mockKeyManager = MockKeyManager();
      when(() => mockKeyManager.getOrGenerateDatabaseKey())
          .thenAnswer((_) async => testMasterKey);

      dao = InMemoryJournalDao();
      repository = JournalRepositoryImpl(
        cryptoService: cryptoService,
        keyManager: mockKeyManager,
        dao: dao,
      );
    });

    test('Initializes, watches repository stream, and updates entries list', () async {
      final entry = JournalEntry(
        id: 'list-item-1',
        title: 'First reflection',
        contentPlaintext: 'Feeling calm now.',
        createdAtUnix: nowUnix,
        updatedAtUnix: nowUnix,
      );
      await repository.saveEntry(entry);

      final controller = JournalListController(repository: repository);
      await pumpEventQueue();

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.entries.length, equals(1));
      expect(controller.state.entries.first.id, equals('list-item-1'));

      controller.dispose();
    });

    test('purgeExpired triggers TTL cleanup and updates lastPurgedCount', () async {
      final expired = JournalEntry(
        id: 'expired-1',
        title: 'Old unsent letter',
        contentEncrypted: 'xyz',
        ttlDeleteAtUnix: nowUnix - 300,
        isAutoDeleteEnabled: true,
        createdAtUnix: nowUnix - 1000,
        updatedAtUnix: nowUnix - 1000,
      );
      await dao.insertEntry(expired);

      final controller = JournalListController(repository: repository);
      await pumpEventQueue();

      expect(controller.state.entries.length, equals(1));

      final purged = await controller.purgeExpired();
      expect(purged, equals(1));
      expect(controller.state.lastPurgedCount, equals(1));

      await pumpEventQueue();
      expect(controller.state.entries.isEmpty, isTrue);

      controller.dispose();
    });

    test('deleteEntry removes entry from stream and state', () async {
      final entry = JournalEntry(
        id: 'to-delete-item',
        title: 'Delete me',
        contentPlaintext: 'Will be deleted.',
        createdAtUnix: nowUnix,
        updatedAtUnix: nowUnix,
      );
      await repository.saveEntry(entry);

      final controller = JournalListController(repository: repository);
      await pumpEventQueue();

      expect(controller.state.entries.length, equals(1));

      final deleted = await controller.deleteEntry('to-delete-item');
      expect(deleted, isTrue);

      await pumpEventQueue();
      expect(controller.state.entries.isEmpty, isTrue);

      controller.dispose();
    });

    test('Riverpod provider instantiates JournalListController', () async {
      final container = ProviderContainer(
        overrides: [
          journalRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(journalListControllerProvider.notifier);
      expect(controller, isA<JournalListController>());

      await pumpEventQueue();
      final state = container.read(journalListControllerProvider);
      expect(state, isA<JournalListState>());
    });
  });
}
