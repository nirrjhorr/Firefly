import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app.firefly/core/contracts/voice_recognition_port.dart';
import 'package:app.firefly/core/database/daos/journal_dao.dart';
import 'package:app.firefly/core/errors/result.dart';
import 'package:app.firefly/core/security/journal_crypto_service.dart';
import 'package:app.firefly/core/security/key_manager.dart';
import 'package:app.firefly/features/journaling/data/adapters/vosk_voice_adapter.dart';
import 'package:app.firefly/features/journaling/data/repositories/journal_repository_impl.dart';
import 'package:app.firefly/features/journaling/domain/models/journal_entry.dart';
import 'package:app.firefly/features/journaling/domain/repositories/journal_repository.dart';
import 'package:app.firefly/features/journaling/presentation/controllers/journal_editor_controller.dart';

class MockVoiceRecognitionPort extends Mock implements VoiceRecognitionPort {}
class MockKeyManager extends Mock implements KeyManager {}

void main() {
  group('JournalEditorController', () {
    late JournalCryptoService cryptoService;
    late MockKeyManager mockKeyManager;
    late InMemoryJournalDao dao;
    late JournalRepository repository;
    late MockVoiceRecognitionPort mockVoicePort;
    late StreamController<String> voicePartialStream;
    late StreamController<String> voiceErrorStream;

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

      mockVoicePort = MockVoiceRecognitionPort();
      voicePartialStream = StreamController<String>.broadcast();
      voiceErrorStream = StreamController<String>.broadcast();

      when(() => mockVoicePort.transcribePartial()).thenAnswer((_) => voicePartialStream.stream);
      when(() => mockVoicePort.onError).thenAnswer((_) => voiceErrorStream.stream);
      when(() => mockVoicePort.startListening()).thenAnswer((_) async {});
      when(() => mockVoicePort.stopListening()).thenAnswer((_) async {});
      when(() => mockVoicePort.transcribeFinal()).thenAnswer((_) async => '');
      when(() => mockVoicePort.isListening).thenReturn(false);
    });

    tearDown(() {
      voicePartialStream.close();
      voiceErrorStream.close();
    });

    test('Reactive word count updates dynamically on content changes', () {
      final controller = JournalEditorController(
        repository: repository,
        voicePort: mockVoicePort,
      );

      expect(controller.state.wordCount, equals(0));

      controller.setContent('Just three words');
      expect(controller.state.wordCount, equals(3));

      controller.setContent('  Lots   of    weird     whitespace   here  ');
      expect(controller.state.wordCount, equals(5));

      controller.setContent('');
      expect(controller.state.wordCount, equals(0));

      controller.dispose();
    });

    test('TTL options properly calculate horizon and auto-delete flags', () {
      final controller = JournalEditorController(
        repository: repository,
        voicePort: mockVoicePort,
      );

      // Default: none
      expect(controller.state.ttlOption, equals(JournalTtlOption.none));
      expect(controller.state.isAutoDeleteEnabled, isFalse);
      expect(controller.state.ttlOption.calculateExpiryUnix(nowUnix), isNull);

      // 1 hour
      controller.setTtlOption(JournalTtlOption.oneHour);
      expect(controller.state.ttlOption, equals(JournalTtlOption.oneHour));
      expect(controller.state.isAutoDeleteEnabled, isTrue);
      expect(controller.state.ttlOption.calculateExpiryUnix(nowUnix), equals(nowUnix + 3600));

      // 24 hours
      controller.setTtlOption(JournalTtlOption.twentyFourHours);
      expect(controller.state.ttlOption.calculateExpiryUnix(nowUnix), equals(nowUnix + 86400));

      // 7 days
      controller.setTtlOption(JournalTtlOption.sevenDays);
      expect(controller.state.ttlOption.calculateExpiryUnix(nowUnix), equals(nowUnix + 604800));

      controller.dispose();
    });

    test('saveEntry persists double-encrypted entry and retains initialCreatedAtUnix across saves', () async {
      final controller = JournalEditorController(
        repository: repository,
        voicePort: mockVoicePort,
        entryId: 'test-editor-save-1',
      );

      controller.setTitle('Quiet Evening');
      controller.setContent('Writing down heavy thoughts so they stop spinning.');
      controller.setTtlOption(JournalTtlOption.twentyFourHours);

      final success = await controller.saveEntry();
      expect(success, isTrue);
      expect(controller.state.initialCreatedAtUnix, isNotNull);
      final initialCreated = controller.state.initialCreatedAtUnix;

      // Second save within same session retains initial createdAt
      controller.setContent('Updated content adding more reflection.');
      await controller.saveEntry();
      expect(controller.state.initialCreatedAtUnix, equals(initialCreated));

      final fetched = await repository.getEntryById('test-editor-save-1', decrypt: true);
      expect(fetched.isOk, isTrue);
      final savedEntry = fetched.unwrap()!;
      expect(savedEntry.title, equals('Quiet Evening'));
      expect(savedEntry.contentPlaintext, equals('Updated content adding more reflection.'));
      expect(savedEntry.wordCount, equals(5));

      controller.dispose();
    });

    test('burnEntry completely deletes entry and clears in-memory state', () async {
      final controller = JournalEditorController(
        repository: repository,
        voicePort: mockVoicePort,
        entryId: 'to-burn-entry',
      );

      controller.setTitle('Unsent Letter to Ex');
      controller.setContent('Everything I was angry about.');
      await controller.saveEntry();

      // Ensure it was initially saved
      final saved = await repository.getEntryById('to-burn-entry');
      expect(saved.unwrap(), isNotNull);

      // Burn it
      final burned = await controller.burnEntry();
      expect(burned, isTrue);
      expect(controller.state.isBurned, isTrue);
      expect(controller.state.content, equals(''));
      expect(controller.state.wordCount, equals(0));

      // Verify row is gone from repository
      final afterBurn = await repository.getEntryById('to-burn-entry');
      expect(afterBurn.unwrap(), isNull);

      controller.dispose();
    });

    test('Voice dictation streams hypotheses and updates editor content', () async {
      final controller = JournalEditorController(
        repository: repository,
        voicePort: mockVoicePort,
      );

      controller.setContent('Initial note.');

      await controller.startVoiceDictation();
      expect(controller.state.isListening, isTrue);
      expect(controller.state.contentType, equals('voice'));

      voicePartialStream.add('speaking out loud');
      await pumpEventQueue();

      expect(controller.state.content, equals('Initial note. speaking out loud'));
      expect(controller.state.wordCount, equals(5));

      when(() => mockVoicePort.transcribeFinal()).thenAnswer((_) async => 'speaking out loud today');
      await controller.stopVoiceDictation();

      expect(controller.state.isListening, isFalse);
      expect(controller.state.content, equals('Initial note. speaking out loud today'));

      controller.dispose();
    });

    test('loadEntry decrypts and restores previous entry state or sets error', () async {
      final entry = JournalEntry(
        id: 'existing-entry-id',
        title: 'Existing Draft',
        contentPlaintext: 'Restored content from database.',
        ttlDeleteAtUnix: nowUnix + 3600,
        isAutoDeleteEnabled: true,
        wordCount: 4,
        createdAtUnix: nowUnix,
        updatedAtUnix: nowUnix,
      );
      await repository.saveEntry(entry);

      final controller = JournalEditorController(
        repository: repository,
        voicePort: mockVoicePort,
      );

      await controller.loadEntry('existing-entry-id');
      expect(controller.state.id, equals('existing-entry-id'));
      expect(controller.state.title, equals('Existing Draft'));
      expect(controller.state.content, equals('Restored content from database.'));
      expect(controller.state.wordCount, equals(4));
      expect(controller.state.ttlOption, equals(JournalTtlOption.oneHour));
      expect(controller.state.isAutoDeleteEnabled, isTrue);

      // Loading non-existent entry sets error message
      await controller.loadEntry('non-existent-id');
      expect(controller.state.errorMessage, contains('not found'));

      controller.dispose();
    });

    test('Riverpod family provider automatically instantiates and loads entry', () async {
      final entry = JournalEntry(
        id: 'family-entry-id',
        title: 'Family Loaded Entry',
        contentPlaintext: 'Loaded automatically.',
        createdAtUnix: nowUnix,
        updatedAtUnix: nowUnix,
      );
      await repository.saveEntry(entry);

      final container = ProviderContainer(
        overrides: [
          journalRepositoryProvider.overrideWithValue(repository),
          voiceRecognitionPortProvider.overrideWithValue(mockVoicePort),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(journalEditorControllerProvider('family-entry-id').notifier);
      await pumpEventQueue();

      expect(controller.state.id, equals('family-entry-id'));
      expect(controller.state.title, equals('Family Loaded Entry'));
      expect(controller.state.content, equals('Loaded automatically.'));
    });
  });
}
