import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

/// Speech service prepared for Vosk offline speech recognition
/// Note: Speech-to-text is currently disabled. Text-to-speech still works.
/// To enable offline speech recognition, Vosk models and native integration are required.
/// See VOSK_INTEGRATION.md for details.
class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;
  bool _isInitialized = false;
  bool _isTtsInitialized = false;

  // Language code mapping for TTS
  final Map<String, String> _ttsLanguageCodes = {
    'SINAMA': 'en-US', // Using English as fallback
    'CEBUANO': 'en-US', // Using English as fallback
    'TAGALOG': 'fil-PH', // Filipino/Tagalog
    'ENGLISH': 'en-US',
  };

  /// Initialize speech recognition (ready for Vosk)
  Future<bool> initializeSpeech() async {
    if (_isInitialized) return true;

    try {
      // Request microphone permission
      final status = await Permission.microphone.request();
      _isInitialized = status.isGranted;
      return status.isGranted;
    } catch (e) {
      print('Error initializing speech: $e');
      return false;
    }
  }

  /// Initialize text-to-speech
  Future<bool> initializeTts() async {
    if (_isTtsInitialized) return true;

    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      _isTtsInitialized = true;
      return true;
    } catch (e) {
      print('Error initializing TTS: $e');
      return false;
    }
  }

  /// Start listening for speech
  /// NOTE: Speech recognition is currently disabled
  /// This is a placeholder for Vosk integration
  /// To enable: Add Vosk models and implement native bridge
  Future<void> startListening({
    required Function(String) onResult,
    required String language,
    Function()? onError,
  }) async {
    if (!_isInitialized) {
      final initialized = await initializeSpeech();
      if (!initialized) {
        onError?.call();
        return;
      }
    }

    // Speech recognition disabled - Vosk models required
    print('Speech recognition requires Vosk model integration');
    print('See VOSK_INTEGRATION.md for setup instructions');
    onError?.call();
  }

  /// Stop listening
  Future<void> stopListening() async {
    _isListening = false;
  }

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Check if speech recognition is available
  Future<bool> isAvailable() async {
    if (!_isInitialized) {
      return await initializeSpeech();
    }
    return _isInitialized;
  }

  /// Speak text using TTS
  Future<void> speak(String text, {String? language}) async {
    if (text.isEmpty) return;

    if (!_isTtsInitialized) {
      await initializeTts();
    }

    try {
      // Set language if provided
      if (language != null) {
        final localeId = _ttsLanguageCodes[language.toUpperCase()] ?? 'en-US';
        await _tts.setLanguage(localeId);
      }

      await _tts.speak(text);
    } catch (e) {
      print('Error speaking text: $e');
    }
  }

  /// Stop speaking
  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  /// Check if TTS is currently speaking
  Future<bool> isSpeaking() async {
    return false; // FlutterTts doesn't provide this directly
  }

  /// Dispose resources
  void dispose() {
    _tts.stop();
  }
}
