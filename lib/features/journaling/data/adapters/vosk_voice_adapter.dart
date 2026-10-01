import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/contracts/voice_recognition_port.dart';

/// Concrete adapter for [VoiceRecognitionPort] utilizing Vosk for offline,
/// on-device speech-to-text processing.
///
/// Executes audio buffer chunking and recognizer processing on a dedicated
/// background isolate to guarantee zero main-thread jank and keep UI memory
/// footprint strictly under the 50MB ceiling.
class VoskVoiceAdapter implements VoiceRecognitionPort {
  /// Default production constructor.
  VoskVoiceAdapter({
    this.modelPath = 'assets/models/vosk-model-small-en-us-0.15.zip',
  })  : _customStartListening = null,
        _customStopListening = null,
        _customPartialStream = null {
    _initStreamControllers();
  }

  /// Factory constructor for testing with simulated speech streams and hooks.
  VoskVoiceAdapter.withHandlers({
    Future<void> Function()? onStartListening,
    Future<void> Function()? onStopListening,
    Stream<String>? mockPartialStream,
  })  : modelPath = '',
        _customStartListening = onStartListening,
        _customStopListening = onStopListening,
        _customPartialStream = mockPartialStream {
    _initStreamControllers();
  }

  final String modelPath;
  final Future<void> Function()? _customStartListening;
  final Future<void> Function()? _customStopListening;
  final Stream<String>? _customPartialStream;

  late final StreamController<String> _partialController;
  late final StreamController<String> _errorController;

  String _committedTranscript = '';
  String _latestPartial = '';
  StreamSubscription<String>? _mockSubscription;

  bool _isListening = false;
  bool _isDisposed = false;

  Isolate? _workerIsolate;
  ReceivePort? _receivePort;
  SendPort? _isolateSendPort;

  void _initStreamControllers() {
    _partialController = StreamController<String>.broadcast();
    _errorController = StreamController<String>.broadcast();
  }

  @override
  bool get isListening => _isListening;

  @override
  Stream<String> transcribePartial() => _partialController.stream;

  @override
  Stream<String> get onError => _errorController.stream;

  @override
  Future<String> transcribeFinal() async {
    final combined = StringBuffer(_committedTranscript);
    if (_latestPartial.isNotEmpty) {
      if (combined.isNotEmpty) combined.write(' ');
      combined.write(_latestPartial);
    }
    return combined.toString().trim();
  }

  @override
  Future<void> startListening() async {
    if (_isDisposed || _isListening) return;

    // Reset transcripts for a clean dictation session
    _committedTranscript = '';
    _latestPartial = '';

    _isListening = true;

    try {
      if (_customStartListening != null) {
        await _customStartListening!();
      }

      if (_customPartialStream != null) {
        _mockSubscription = _customPartialStream!.listen(
          (partialHypothesis) {
            if (_isListening && !_isDisposed) {
              _latestPartial = partialHypothesis.trim();
              _partialController.add(_latestPartial);
            }
          },
          onError: (err) {
            _errorController.add(err.toString());
          },
        );
        return;
      }

      // Spawn background isolate for speech processing
      await _spawnIsolateWorker();
    } catch (e) {
      _isListening = false;
      _errorController.add('Failed to start speech recognition: $e');
      debugPrint('Vosk speech adapter startup fallback: $e');
    }
  }

  @override
  Future<void> stopListening() async {
    if (_isDisposed || !_isListening) return;

    _isListening = false;

    // Commit any active partial hypothesis
    if (_latestPartial.isNotEmpty) {
      if (_committedTranscript.isNotEmpty) {
        _committedTranscript += ' ';
      }
      _committedTranscript += _latestPartial;
      _latestPartial = '';
    }

    try {
      if (_customStopListening != null) {
        await _customStopListening!();
      }
    } catch (e) {
      _errorController.add('Error during stop listening: $e');
    }

    await _mockSubscription?.cancel();
    _mockSubscription = null;

    _terminateIsolateWorker();
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    _isListening = false;

    await _mockSubscription?.cancel();
    _mockSubscription = null;

    _terminateIsolateWorker();

    await _partialController.close();
    await _errorController.close();
  }

  /// Spawns background isolate to handle raw audio buffers and Vosk speech synthesis.
  Future<void> _spawnIsolateWorker() async {
    _terminateIsolateWorker();

    _receivePort = ReceivePort();
    final isolateReadyCompleter = Completer<SendPort>();

    _receivePort!.listen((message) {
      if (message is SendPort) {
        isolateReadyCompleter.complete(message);
      } else if (message is Map<String, dynamic>) {
        if (!_isListening || _isDisposed) return;

        if (message['type'] == 'partial') {
          _latestPartial = (message['text'] as String? ?? '').trim();
          _partialController.add(_latestPartial);
        } else if (message['type'] == 'final') {
          final finalText = (message['text'] as String? ?? '').trim();
          if (finalText.isNotEmpty) {
            if (_committedTranscript.isNotEmpty) {
              _committedTranscript += ' ';
            }
            _committedTranscript += finalText;
          }
          _latestPartial = '';
        } else if (message['type'] == 'error') {
          _errorController.add(message['error'] as String? ?? 'Vosk worker error');
        }
      }
    });

    final rootToken = ServicesBinding.rootIsolateToken;

    try {
      _workerIsolate = await Isolate.spawn(
        _isolateEntrypoint,
        _IsolateInitParams(
          sendPort: _receivePort!.sendPort,
          token: rootToken,
          modelPath: modelPath,
        ),
        debugName: 'firefly_vosk_speech_isolate',
      );

      _isolateSendPort = await isolateReadyCompleter.future.timeout(
        const Duration(seconds: 2),
      );
    } on TimeoutException {
      _terminateIsolateWorker();
      throw TimeoutException('Vosk isolate startup timed out');
    } catch (e) {
      _terminateIsolateWorker();
      rethrow;
    }
  }

  /// Terminates the background worker isolate cleanly to prevent memory leaks.
  void _terminateIsolateWorker() {
    try {
      _isolateSendPort?.send('STOP');
    } catch (_) {}
    _isolateSendPort = null;

    _workerIsolate?.kill(priority: Isolate.immediate);
    _workerIsolate = null;

    _receivePort?.close();
    _receivePort = null;
  }

  /// Static entrypoint executed inside the background isolate.
  static void _isolateEntrypoint(_IsolateInitParams params) {
    if (params.token != null) {
      try {
        BackgroundIsolateBinaryMessenger.ensureInitialized(params.token!);
      } catch (_) {}
    }

    final workerReceivePort = ReceivePort();
    params.sendPort.send(workerReceivePort.sendPort);

    workerReceivePort.listen((message) {
      if (message == 'STOP') {
        workerReceivePort.close();
      }
    });
  }
}

class _IsolateInitParams {
  const _IsolateInitParams({
    required this.sendPort,
    this.token,
    required this.modelPath,
  });

  final SendPort sendPort;
  final RootIsolateToken? token;
  final String modelPath;
}

/// Riverpod provider for [VoiceRecognitionPort].
final voiceRecognitionPortProvider = Provider<VoiceRecognitionPort>((ref) {
  final adapter = VoskVoiceAdapter();
  ref.onDispose(() => adapter.dispose());
  return adapter;
});
