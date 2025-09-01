import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:permission_handler/permission_handler.dart';

class VoiceProvider extends ChangeNotifier {
  // late stt.SpeechToText _speech;
  // late FlutterTts _flutterTts;
  
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isAvailable = false;
  String _recognizedText = '';
  double _confidence = 1.0;

  // Getters
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get isAvailable => _isAvailable;
  String get recognizedText => _recognizedText;
  double get confidence => _confidence;

  VoiceProvider() {
    _initializeSpeech();
    _initializeTts();
  }

  // Initialize Speech-to-Text (Mock implementation)
  Future<void> _initializeSpeech() async {
    // _speech = stt.SpeechToText();
    
    // Mock implementation for Windows
    _isAvailable = true;
    notifyListeners();
    
    // Request microphone permission
    // final status = await Permission.microphone.request();
    // if (status == PermissionStatus.granted) {
    //   _isAvailable = await _speech.initialize(
    //     onStatus: (status) {
    //       print('Speech recognition status: $status');
    //       if (status == 'notListening') {
    //         _isListening = false;
    //         notifyListeners();
    //       }
    //     },
    //     onError: (error) {
    //       print('Speech recognition error: $error');
    //       _isListening = false;
    //       notifyListeners();
    //     },
    //   );
    // } else {
    //   _isAvailable = false;
    // }
    // notifyListeners();
  }

  // Initialize Text-to-Speech (Mock implementation)
  Future<void> _initializeTts() async {
    // _flutterTts = FlutterTts();
    
    // Mock implementation for Windows
    print('TTS initialized (mock)');
    
    // Configure TTS
    // await _flutterTts.setLanguage('en-IN'); // Indian English
    // await _flutterTts.setSpeechRate(0.5); // Slower rate for better understanding
    // await _flutterTts.setVolume(1.0);
    // await _flutterTts.setPitch(1.0);

    // Set completion handler
    // _flutterTts.setCompletionHandler(() {
    //   _isSpeaking = false;
    //   notifyListeners();
    // });

    // Set error handler
    // _flutterTts.setErrorHandler((message) {
    //   print('TTS Error: $message');
    //   _isSpeaking = false;
    //   notifyListeners();
    // });
  }

  // Start listening for speech (Mock implementation)
  Future<void> startListening() async {
    if (!_isAvailable || _isListening) return;

    _recognizedText = '';
    _confidence = 1.0;
    _isListening = true;
    notifyListeners();

    // Mock speech recognition for Windows
    await Future.delayed(const Duration(seconds: 3));
    _recognizedText = "Hello, this is a mock voice input for testing!";
    _confidence = 0.95;
    _isListening = false;
    notifyListeners();

    // try {
    //   await _speech.listen(
    //     onResult: (result) {
    //       _recognizedText = result.recognizedWords;
    //       _confidence = result.confidence;
    //       notifyListeners();
    //     },
    //     listenFor: const Duration(seconds: 30),
    //     pauseFor: const Duration(seconds: 3),
    //     partialResults: true,
    //     localeId: 'en_IN', // Indian English
    //     cancelOnError: true,
    //     listenMode: stt.ListenMode.confirmation,
    //   );
    // } catch (e) {
    //   print('Error starting speech recognition: $e');
    //   _isListening = false;
    //   notifyListeners();
    // }
  }

  // Stop listening
  Future<void> stopListening() async {
    if (_isListening) {
      // await _speech.stop();
      _isListening = false;
      notifyListeners();
    }
  }

  // Toggle listening state
  Future<void> toggleListening() async {
    if (_isListening) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  // Speak text using TTS (Mock implementation)
  Future<void> speak(String text) async {
    if (_isSpeaking) {
      await stopSpeaking();
    }

    if (text.isNotEmpty) {
      _isSpeaking = true;
      notifyListeners();

      // Mock TTS for Windows
      print('Speaking (mock): $text');
      await Future.delayed(const Duration(seconds: 2));
      _isSpeaking = false;
      notifyListeners();

      // try {
      //   // Clean text for better pronunciation
      //   final cleanedText = _cleanTextForSpeech(text);
      //   await _flutterTts.speak(cleanedText);
      // } catch (e) {
      //   print('Error in TTS: $e');
      //   _isSpeaking = false;
      //   notifyListeners();
      // }
    }
  }

  // Stop speaking
  Future<void> stopSpeaking() async {
    // await _flutterTts.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  // Clean text for better speech synthesis
  String _cleanTextForSpeech(String text) {
    // Remove markdown formatting
    String cleaned = text.replaceAll(RegExp(r'[*_`#]'), '');
    
    // Replace common symbols with words
    cleaned = cleaned.replaceAll('&', ' and ');
    cleaned = cleaned.replaceAll('%', ' percent ');
    cleaned = cleaned.replaceAll('@', ' at ');
    cleaned = cleaned.replaceAll('#', ' hash ');
    
    // Handle emojis - remove them for cleaner speech
    cleaned = cleaned.replaceAll(RegExp(r'[^\w\s.,!?;:-]'), '');
    
    // Handle Hinglish - add pauses for better pronunciation
    cleaned = cleaned.replaceAll(RegExp(r'([a-zA-Z]+)([^\s\w])([हिंदी-अ-य]+)'), r'\1 \2 \3');
    
    return cleaned.trim();
  }

  // Get available speech recognition locales (Mock implementation)
  Future<List<String>> getAvailableLocales() async {
    // Mock locales for Windows
    return ['en_US', 'en_IN', 'hi_IN'];
    
    // if (_isAvailable) {
    //   final locales = await _speech.locales();
    //   return locales.map((locale) => locale.localeId).toList();
    // }
    // return [];
  }

  // Set speech recognition language
  Future<void> setLanguage(String localeId) async {
    // This will be used in the next listening session
    print('Language set to: $localeId');
  }

  // Clear recognized text
  void clearRecognizedText() {
    _recognizedText = '';
    notifyListeners();
  }

  // Check microphone permission (Mock implementation)
  Future<bool> checkMicrophonePermission() async {
    // Mock permission check for Windows
    return true;
    
    // final status = await Permission.microphone.status;
    // return status == PermissionStatus.granted;
  }

  // Request microphone permission (Mock implementation)
  Future<bool> requestMicrophonePermission() async {
    // Mock permission request for Windows
    _isAvailable = true;
    return true;
    
    // final status = await Permission.microphone.request();
    // if (status == PermissionStatus.granted) {
    //   await _initializeSpeech();
    //   return true;
    // }
    // return false;
  }

  @override
  void dispose() {
    // _flutterTts.stop();
    super.dispose();
  }
}
