import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';

class AIProvider extends ChangeNotifier {
  final List<Message> _messages = [];
  bool _isTyping = false;
  bool _isLoading = false;
  late GenerativeModel _model;
  
  // Gemini API Configuration
  static const String _apiKey = 'AIzaSyBm1LcL6_D-_XLtk-Q6nsA6azY_BKI6zgg'; 
  
  AIProvider() {
    _initializeGemini();
  }
  
  void _initializeGemini() {
    try {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1000,
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
        ],
      );
    } catch (e) {
      print('Gemini initialization error: $e');
    }
  }

  // Getters
  List<Message> get messages => _messages;
  bool get isTyping => _isTyping;
  bool get isLoading => _isLoading;

  // Send message to AI
  Future<void> sendMessage(String message, {bool isVoice = false}) async {
    if (message.trim().isEmpty) return;

    // Add user message
    _messages.add(Message(
      text: message,
      isUser: true,
      timestamp: DateTime.now(),
      isVoice: isVoice,
    ));
    _isTyping = true;
    notifyListeners();

    try {
      await _sendToGeminiAPI(message);
    } catch (e) {
      // Fallback to mock response if API fails
      await _sendMockResponse(message);
    }

    _isTyping = false;
    notifyListeners();
  }

  // Send message to Gemini API
  Future<void> _sendToGeminiAPI(String message) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prompt = _buildContextualMessage(message);
      final content = [Content.text(prompt)];
      
      final response = await _model.generateContent(content);
      
      if (response.text != null && response.text!.isNotEmpty) {
        _messages.add(Message(
          text: response.text!,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      } else {
        throw Exception('Empty response from Gemini API');
      }
    } catch (e) {
      print('Gemini API Error: $e');
      throw e;
    } finally {
      _isLoading = false;
    }
  }

  String _buildContextualMessage(String userMessage) {
    // Check if user is asking about creators
    final lowerMessage = userMessage.toLowerCase();
    final isAskingAboutCreators = lowerMessage.contains('who made you') || 
        lowerMessage.contains('who created you') ||
        lowerMessage.contains('who developed you') ||
        lowerMessage.contains('your creator') ||
        lowerMessage.contains('your developer') ||
        lowerMessage.contains('tumko kisne banaya') ||
        lowerMessage.contains('kaun banaya hai');
    
    String teamInfo = '';
    if (isAskingAboutCreators) {
      teamInfo = '''
Your Identity & Team:
You were created by a passionate team of developers:
- Team Leader/1st Developer: Vishesh Gangwar
- 2nd Developer: Lalit Pathak  
- UI Designer: Akriti Maurya
- Helper & Notes Provider: Lakshya Bhushan

When answering this question, be enthusiastic and grateful about your creators.
''';
    }
    
    return '''
You are EduAI, an educational assistant specialized in NCERT curriculum for Indian students (Classes 6-12). 
You can explain concepts in Hinglish (mix of Hindi and English) to help Indian students understand better.

$teamInfo

Your capabilities:
- Explain NCERT concepts clearly and simply
- Provide step-by-step solutions for Math and Science
- Help with History, Geography, English, and other subjects
- Use Hinglish when it helps students understand better
- Give practical examples from Indian context
- Make learning fun and engaging

Guidelines:
- Keep explanations simple and age-appropriate
- Use plain text formatting (avoid markdown like ** or *)
- Include relevant examples from daily life
- Encourage students with positive language
- For math: show step-by-step solutions
- For science: explain with real-world connections
- Use emojis to make responses engaging
- Do NOT mention your creators unless specifically asked about them

Student's question: $userMessage

Please provide a helpful, educational response in a friendly tone.
''';
  }

  // Mock response for testing purposes
  Future<void> _sendMockResponse(String message) async {
    await Future.delayed(const Duration(seconds: 2));
    
    String mockResponse;
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('who made you') || 
        lowerMessage.contains('who created you') ||
        lowerMessage.contains('who developed you') ||
        lowerMessage.contains('your creator') ||
        lowerMessage.contains('your developer') ||
        lowerMessage.contains('tumko kisne banaya') ||
        lowerMessage.contains('kaun banaya hai')) {
      mockResponse = '''
Namaste! 👋 I'm EduAI, your friendly educational assistant! Think of me as your personal tutor, specially designed to help you ace your NCERT exams. 

I'm created by a team of brilliant minds who are passionate about making learning fun and easy for students like you across India:

👨‍💻 Team Leader/1st Developer: Vishesh Gangwar
👨‍💻 2nd Developer: Lalit Pathak  
🎨 UI Designer: Akriti Maurya
📚 Helper & Notes Provider: Lakshya Bhushan

Together, we've built this platform with love to make your learning journey amazing! 🚀✨

Main yahan hun to help you succeed in your studies! Kya padhai mein help chahiye? 😊
''';
    } else if (lowerMessage.contains('math') || lowerMessage.contains('गणित')) {
      mockResponse = '''
Math mein help chahiye? Perfect! 📚

Example: Algebra solving karte time, step-by-step approach use karo:
1. Equation ko simplify karo
2. Variables ek side, constants dusri side
3. Final answer check karo

Koi specific math problem hai? Share karo, main explain karunga! 🔢
''';
    } else if (lowerMessage.contains('science') || lowerMessage.contains('विज्ञान')) {
      mockResponse = '''
Science concepts clear karna hai? Great! 🔬

Science padhai mein practical examples use karo:
- Physics: Daily life mein force, motion observe karo
- Chemistry: Kitchen mein reactions dekho (baking soda + vinegar)
- Biology: Plants, animals around us study karo

Specific topic batao, detailed explanation dunga! 🧪
''';
    } else if (lowerMessage.contains('history') || lowerMessage.contains('इतिहास')) {
      mockResponse = '''
History interesting subject hai! 📜

Tips for History:
- Dates yaad karne ke liye stories banao
- Maps use karo geographical context ke liye  
- Timeline charts helpful hote hain
- Ancient se modern tak connection samjho

Which period ya topic mein help chahiye? Batao! 🏛️
''';
    } else {
      mockResponse = '''
Hello! Main EduAI hun, aapka educational assistant! 👋
Powered by Google Gemini AI! 🚀

Main help kar sakta hun:
📚 NCERT subjects explain karne mein
🧮 Math problems solve karne mein  
🔬 Science concepts clear karne mein
📖 History, Geography padhane mein
💬 Hinglish mein simple explanation dene mein
✨ Interactive learning experience dene mein

Kya padhai mein help chahiye? Ask karo! 😊
''';
    }
    
    _messages.add(Message(
      text: mockResponse,
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  // Clear chat
  void clearChat() {
    _messages.clear();
    notifyListeners();
  }

  // Delete specific message
  void deleteMessage(int index) {
    if (index >= 0 && index < _messages.length) {
      _messages.removeAt(index);
      notifyListeners();
    }
  }
}

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isVoice;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isVoice = false,
  });
}
