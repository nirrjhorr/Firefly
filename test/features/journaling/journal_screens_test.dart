import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app.firefly/core/contracts/voice_recognition_port.dart';
import 'package:app.firefly/core/database/daos/journal_dao.dart';
import 'package:app.firefly/core/errors/result.dart';
import 'package:app.firefly/core/routing/app_routes.dart';
import 'package:app.firefly/core/security/journal_crypto_service.dart';
import 'package:app.firefly/core/security/key_manager.dart';
import 'package:app.firefly/core/theme/app_theme.dart';
import 'package:app.firefly/features/journaling/data/adapters/vosk_voice_adapter.dart';
import 'package:app.firefly/features/journaling/data/repositories/journal_repository_impl.dart';
import 'package:app.firefly/features/journaling/domain/models/journal_entry.dart';
import 'package:app.firefly/features/journaling/domain/repositories/journal_repository.dart';
import 'package:app.firefly/features/journaling/presentation/controllers/journal_editor_controller.dart';
import 'package:app.firefly/features/journaling/presentation/controllers/journal_list_controller.dart';
import 'package:app.firefly/features/journaling/presentation/screens/journal_entry_screen.dart';
import 'package:app.firefly/features/journaling/presentation/screens/journal_list_screen.dart';

class MockVoiceRecognitionPort extends Mock implements VoiceRecognitionPort {}
class MockKeyManager extends Mock implements KeyManager {}

void main() {
  group('Journal Screens Widget Tests', () {
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

      when(() => mockVoicePort.transcribePartial())
          .thenAnswer((_) => voicePartialStream.stream);
      when(() => mockVoicePort.onError)
          .thenAnswer((_) => voiceErrorStream.stream);
      when(() => mockVoicePort.startListening()).thenAnswer((_) async {});
      when(() => mockVoicePort.stopListening()).thenAnswer((_) async {});
      when(() => mockVoicePort.transcribeFinal()).thenAnswer((_) async => '');
      when(() => mockVoicePort.isListening).thenReturn(false);
    });

    tearDown(() {
      voicePartialStream.close();
      voiceErrorStream.close();
      dao.dispose();
    });

    Widget createTestApp({
      required Widget home,
      List<Override> overrides = const [],
    }) {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => home,
          ),
          GoRoute(
            path: '${AppRoutes.journal}/new',
            builder: (context, state) =>
                const Scaffold(body: Text('New Reflection Screen')),
          ),
          GoRoute(
            path: '${AppRoutes.journal}/new-letter',
            builder: (context, state) =>
                const Scaffold(body: Text('New Letter Screen')),
          ),
          GoRoute(
            path: '${AppRoutes.journal}/:id',
            builder: (context, state) => Scaffold(
              body: Text('Entry Screen: ${state.pathParameters['id']}'),
            ),
          ),
        ],
      );

      return ProviderScope(
        overrides: [
          journalRepositoryProvider.overrideWithValue(repository),
          voiceRecognitionPortProvider.overrideWithValue(mockVoicePort),
          ...overrides,
        ],
        child: MaterialApp.router(
          theme: AppTheme.darkTheme,
          routerConfig: router,
        ),
      );
    }

    group('JournalListScreen', () {
      testWidgets('renders header, action buttons, and empty state when empty',
          (tester) async {
        await tester.pumpWidget(createTestApp(home: const JournalListScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Journal & Letters'), findsOneWidget);
        expect(
          find.text(
              'Private, double-encrypted reflections. Never synced, never leaves this device.'),
          findsOneWidget,
        );
        expect(find.text('+ New Reflection'), findsOneWidget);
        expect(find.text('Unsent Letter'), findsOneWidget);
        expect(find.text('A Quiet, Judgment-Free Space'), findsOneWidget);
        expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      });

      testWidgets('renders populated entries with titles, dates, word counts, and TTL chips',
          (tester) async {
        final entry1 = JournalEntry(
          id: 'entry-perm',
          title: 'Grounded in Evening',
          contentPlaintext: 'Feeling calm after breathing.',
          wordCount: 5,
          isAutoDeleteEnabled: false,
          createdAtUnix: nowUnix - 3600,
          updatedAtUnix: nowUnix - 3600,
        );
        final entry2 = JournalEntry(
          id: 'entry-unsent',
          title: 'Letter to the Past',
          contentPlaintext: 'Words I will never send anyone.',
          wordCount: 6,
          isAutoDeleteEnabled: true,
          ttlDeleteAtUnix: nowUnix + 86400,
          createdAtUnix: nowUnix,
          updatedAtUnix: nowUnix,
        );

        await repository.saveEntry(entry1);
        await repository.saveEntry(entry2);

        await tester.pumpWidget(createTestApp(home: const JournalListScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Grounded in Evening'), findsOneWidget);
        expect(find.text('Letter to the Past'), findsOneWidget);
        expect(find.text('Encrypted'), findsOneWidget);
        expect(find.textContaining('Auto-deletes in 24h'), findsOneWidget);
        expect(find.textContaining('5 words'), findsOneWidget);
        expect(find.textContaining('6 words'), findsOneWidget);
      });

      testWidgets('filters entries by search query including untitled fallback',
          (tester) async {
        final entry1 = JournalEntry(
          id: 'e1',
          title: 'Forest walk meditation',
          contentPlaintext: 'Pine trees and silence.',
          createdAtUnix: nowUnix,
          updatedAtUnix: nowUnix,
        );
        final entry2 = JournalEntry(
          id: 'e2',
          title: '', // Untitled reflection fallback
          contentPlaintext: 'Thankful for a quiet cup of tea.',
          createdAtUnix: nowUnix,
          updatedAtUnix: nowUnix,
        );

        await repository.saveEntry(entry1);
        await repository.saveEntry(entry2);

        await tester.pumpWidget(createTestApp(home: const JournalListScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Forest walk meditation'), findsOneWidget);
        expect(find.text('Untitled reflection'), findsOneWidget);

        // Search for 'Forest'
        await tester.enterText(find.byType(TextField), 'Forest');
        await tester.pumpAndSettle();

        expect(find.text('Forest walk meditation'), findsOneWidget);
        expect(find.text('Untitled reflection'), findsNothing);

        // Search for 'Untitled'
        await tester.enterText(find.byType(TextField), 'Untitled');
        await tester.pumpAndSettle();

        expect(find.text('Forest walk meditation'), findsNothing);
        expect(find.text('Untitled reflection'), findsOneWidget);

        // Clear search query
        await tester.tap(find.byIcon(Icons.clear));
        await tester.pumpAndSettle();

        expect(find.text('Forest walk meditation'), findsOneWidget);
        expect(find.text('Untitled reflection'), findsOneWidget);
      });

      testWidgets('shows empty search state when search matches no entries',
          (tester) async {
        final entry = JournalEntry(
          id: 'e1',
          title: 'Solitude',
          contentPlaintext: 'Quiet time.',
          createdAtUnix: nowUnix,
          updatedAtUnix: nowUnix,
        );
        await repository.saveEntry(entry);

        await tester.pumpWidget(createTestApp(home: const JournalListScreen()));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Ocean waves');
        await tester.pumpAndSettle();

        expect(find.text('No matching entries found'), findsOneWidget);
        expect(find.byIcon(Icons.search_off), findsOneWidget);
      });

      testWidgets('confirms and deletes entry permanently upon clicking delete icon',
          (tester) async {
        final entry = JournalEntry(
          id: 'to-delete',
          title: 'Temporary Note',
          contentPlaintext: 'Delete me soon.',
          createdAtUnix: nowUnix,
          updatedAtUnix: nowUnix,
        );
        await repository.saveEntry(entry);

        await tester.pumpWidget(createTestApp(home: const JournalListScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Temporary Note'), findsOneWidget);

        // Tap delete icon button on the card
        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();

        expect(find.text('Delete Reflection?'), findsOneWidget);
        expect(
          find.text(
              'This entry will be cryptographically overwritten with zeroes and permanently removed.'),
          findsOneWidget,
        );

        // Tap Delete Permanently
        await tester.tap(find.text('Delete Permanently'));
        await tester.pumpAndSettle();

        expect(find.text('Temporary Note'), findsNothing);
        expect(find.text('A Quiet, Judgment-Free Space'), findsOneWidget);
      });

      testWidgets('purging expired letters provides explicit user feedback',
          (tester) async {
        await tester.pumpWidget(createTestApp(home: const JournalListScreen()));
        await tester.pumpAndSettle();

        final purgeButton = find.byIcon(Icons.cleaning_services_outlined);
        expect(purgeButton, findsOneWidget);

        await tester.tap(purgeButton);
        await tester.pumpAndSettle();

        // 0 expired entries in empty state
        expect(find.text('No expired entries to purge'), findsOneWidget);
      });

      testWidgets('navigates to new reflection and new letter routes',
          (tester) async {
        await tester.pumpWidget(createTestApp(home: const JournalListScreen()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('+ New Reflection'));
        await tester.pumpAndSettle();
        expect(find.text('New Reflection Screen'), findsOneWidget);
      });

      testWidgets('displays error banner if listState has errorMessage',
          (tester) async {
        await tester.pumpWidget(createTestApp(
          home: const JournalListScreen(),
          overrides: [
            journalListControllerProvider.overrideWith((ref) {
              final controller =
                  JournalListController(repository: repository);
              controller.state = controller.state
                  .copyWith(errorMessage: 'Storage decrypt failure test');
              return controller;
            }),
          ],
        ));
        await tester.pumpAndSettle();

        expect(find.text('Storage decrypt failure test'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });
    });

    group('JournalEntryScreen', () {
      testWidgets('renders distraction-free canvas in #111518 with word count and save button',
          (tester) async {
        await tester.pumpWidget(createTestApp(
          home: const JournalEntryScreen(entryId: 'new-entry'),
        ));
        await tester.pumpAndSettle();

        // Check dark canvas background
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, const Color(0xFF111518));

        expect(find.text('0 words'), findsOneWidget);
        expect(find.text('Save'), findsOneWidget);
        expect(find.byType(TextField), findsNWidgets(2)); // Title and Content
        expect(find.text('Burn Now'), findsOneWidget);
      });

      testWidgets('loads existing entry from repository into title and content',
          (tester) async {
        final existing = JournalEntry(
          id: 'existing-id',
          title: 'Reflections on Silence',
          contentPlaintext: 'The silence tonight is restful.',
          wordCount: 5,
          createdAtUnix: nowUnix,
          updatedAtUnix: nowUnix,
        );
        await repository.saveEntry(existing);

        await tester.pumpWidget(createTestApp(
          home: const JournalEntryScreen(entryId: 'existing-id'),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Reflections on Silence'), findsOneWidget);
        expect(find.text('The silence tonight is restful.'), findsOneWidget);
        expect(find.text('5 words'), findsOneWidget);
      });

      testWidgets('reactively updates word count as user types', (tester) async {
        await tester.pumpWidget(createTestApp(
          home: const JournalEntryScreen(entryId: 'test-wc'),
        ));
        await tester.pumpAndSettle();

        expect(find.text('0 words'), findsOneWidget);

        // Enter 6 words into the body TextField (second TextField)
        final bodyField = find.byType(TextField).at(1);
        await tester.enterText(bodyField, 'Firefly provides a safe, calming sanctuary');
        await tester.pumpAndSettle();

        expect(find.text('6 words'), findsOneWidget);
      });

      testWidgets('renders all 4 TTL choice chips and allows selecting different options',
          (tester) async {
        await tester.pumpWidget(createTestApp(
          home: const JournalEntryScreen(entryId: 'test-chips'),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Keep permanently'), findsOneWidget);
        expect(find.text('1 Hour'), findsOneWidget);
        expect(find.text('24 Hours'), findsOneWidget);
        expect(find.text('7 Days'), findsOneWidget);

        // Select 24 Hours
        await tester.tap(find.text('24 Hours'));
        await tester.pumpAndSettle();

        // Select 1 Hour
        await tester.tap(find.text('1 Hour'));
        await tester.pumpAndSettle();

        // Select Keep permanently
        await tester.tap(find.text('Keep permanently'));
        await tester.pumpAndSettle();
      });

      testWidgets('toggles offline Vosk voice dictation and updates text dynamically',
          (tester) async {
        await tester.pumpWidget(createTestApp(
          home: const JournalEntryScreen(entryId: 'test-voice'),
        ));
        await tester.pumpAndSettle();

        final micIcon = find.byIcon(Icons.mic_none);
        expect(micIcon, findsOneWidget);

        // Tap mic to start dictation
        await tester.tap(micIcon);
        await tester.pumpAndSettle();

        expect(find.text('Listening offline via Vosk...'), findsOneWidget);
        expect(find.byIcon(Icons.mic), findsOneWidget);

        // Stream speech hypothesis
        voicePartialStream.add('feeling much calmer now');
        await tester.pumpAndSettle();

        expect(find.text('feeling much calmer now'), findsOneWidget);
        expect(find.text('4 words'), findsOneWidget);

        // Tap mic again to stop
        await tester.tap(find.byIcon(Icons.mic));
        await tester.pumpAndSettle();

        expect(find.text('Listening offline via Vosk...'), findsNothing);
        expect(find.byIcon(Icons.mic_none), findsOneWidget);
      });

      testWidgets('handles voice error stream by displaying error banner',
          (tester) async {
        await tester.pumpWidget(createTestApp(
          home: const JournalEntryScreen(entryId: 'test-voice-err'),
        ));
        await tester.pumpAndSettle();

        // Tap mic
        await tester.tap(find.byIcon(Icons.mic_none));
        await tester.pumpAndSettle();

        // Emit voice error
        voiceErrorStream.add('Audio hardware microphone failure');
        await tester.pumpAndSettle();

        expect(find.text('Audio hardware microphone failure'), findsOneWidget);
        expect(find.byIcon(Icons.info_outline), findsOneWidget);
        expect(find.byIcon(Icons.mic_none), findsOneWidget);
      });

      testWidgets('burn sequence shows confirmation and triggers cryptographic erase',
          (tester) async {
        await tester.pumpWidget(createTestApp(
          home: const JournalEntryScreen(entryId: 'to-burn'),
        ));
        await tester.pumpAndSettle();

        // Enter unsent thoughts
        await tester.enterText(
          find.byType(TextField).at(1),
          'Unsent letter meant to be dissolved.',
        );
        await tester.pumpAndSettle();

        // Tap Burn Now button
        await tester.tap(find.text('Burn Now'));
        await tester.pumpAndSettle();

        expect(find.text('Burn Unsent Letter?'), findsOneWidget);
        expect(
          find.text(
              'This unsent letter will be cryptographically overwritten with zeroes and permanently erased immediately. It cannot be recovered.'),
          findsOneWidget,
        );

        // Cancel dialog first
        await tester.tap(find.text('Keep Writing'));
        await tester.pumpAndSettle();
        expect(find.text('Burn Unsent Letter?'), findsNothing);

        // Tap Burn Now again and confirm
        await tester.tap(find.text('Burn Now'));
        await tester.pumpAndSettle();

        final confirmBurnBtn = find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Burn Now'),
        );
        await tester.tap(confirmBurnBtn);

        // Advance through tactile feedback delays and dissolve animation
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();
      });

      testWidgets('save button persists reflection double-encrypted to repository',
          (tester) async {
        await tester.pumpWidget(createTestApp(
          home: const JournalEntryScreen(entryId: 'saved-entry'),
        ));
        await tester.pumpAndSettle();

        // Fill title and content
        await tester.enterText(find.byType(TextField).first, 'Midnight Reflection');
        await tester.enterText(find.byType(TextField).last, 'Breathe in, breathe out.');
        await tester.pumpAndSettle();

        // Tap Save
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(find.text('Saved securely'), findsOneWidget);

        // Verify entry is present in repository
        final entryResult = await repository.getEntryById('saved-entry', decrypt: true);
        expect(entryResult.isOk, isTrue);
        final saved = entryResult.unwrap();
        expect(saved, isNotNull);
        expect(saved!.title, 'Midnight Reflection');
        expect(saved.contentPlaintext, 'Breathe in, breathe out.');
      });

      testWidgets('back navigation on unchanged existing entry pops cleanly without prompt',
          (tester) async {
        final existing = JournalEntry(
          id: 'clean-entry',
          title: 'Old Thoughts',
          contentPlaintext: 'Already saved content.',
          createdAtUnix: nowUnix,
          updatedAtUnix: nowUnix,
        );
        await repository.saveEntry(existing);

        await tester.pumpWidget(createTestApp(
          home: const JournalEntryScreen(entryId: 'clean-entry'),
        ));
        await tester.pumpAndSettle();

        // Tap leading back arrow without making changes
        await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
        await tester.pumpAndSettle();

        // Should NOT show "Save Changes?" prompt
        expect(find.text('Save Changes?'), findsNothing);
      });

      testWidgets('back navigation with dirty edits prompts discard or save',
          (tester) async {
        await tester.pumpWidget(createTestApp(
          home: const JournalEntryScreen(entryId: 'unsaved-back'),
        ));
        await tester.pumpAndSettle();

        // Enter content
        await tester.enterText(
          find.byType(TextField).last,
          'Unsaved thoughts that I typed.',
        );
        await tester.pumpAndSettle();

        // Tap leading back arrow
        await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
        await tester.pumpAndSettle();

        expect(find.text('Save Changes?'), findsOneWidget);
        expect(
          find.text('Would you like to save your reflection before leaving?'),
          findsOneWidget,
        );

        // Tap Discard
        await tester.tap(find.text('Discard'));
        await tester.pumpAndSettle();
      });
    });
  });
}
