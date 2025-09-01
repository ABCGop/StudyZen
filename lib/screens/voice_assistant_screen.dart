import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_provider.dart';
import '../providers/ai_provider.dart';
import '../utils/app_theme.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkPermissions();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _checkPermissions() async {
    final voiceProvider = Provider.of<VoiceProvider>(context, listen: false);
    final hasPermission = await voiceProvider.checkMicrophonePermission();
    
    if (!hasPermission) {
      _showPermissionDialog();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Assistant'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        actions: [
          Consumer<VoiceProvider>(
            builder: (context, voiceProvider, child) {
              return IconButton(
                icon: Icon(
                  voiceProvider.isSpeaking ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (voiceProvider.isSpeaking) {
                    voiceProvider.stopSpeaking();
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Status Text
              Consumer<VoiceProvider>(
                builder: (context, voiceProvider, child) {
                  String statusText;
                  if (voiceProvider.isListening) {
                    statusText = 'Listening... Speak now';
                    if (!_pulseController.isAnimating) {
                      _pulseController.repeat(reverse: true);
                    }
                  } else if (voiceProvider.isSpeaking) {
                    statusText = 'Speaking...';
                    _pulseController.stop();
                  } else {
                    statusText = 'Tap to start voice chat';
                    _pulseController.stop();
                  }
                  
                  return Text(
                    statusText,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              
              const SizedBox(height: 60),
              
              // Voice Visualizer
              Expanded(
                child: Consumer<VoiceProvider>(
                  builder: (context, voiceProvider, child) {
                    return Center(
                      child: GestureDetector(
                        onTap: _toggleVoiceInput,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: voiceProvider.isListening 
                                  ? _pulseAnimation.value 
                                  : 1.0,
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.2),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  child: Icon(
                                    voiceProvider.isListening 
                                        ? Icons.mic 
                                        : Icons.mic_none,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Recognition Text
              Consumer<VoiceProvider>(
                builder: (context, voiceProvider, child) {
                  if (voiceProvider.recognizedText.isNotEmpty) {
                    return Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'You said:',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            voiceProvider.recognizedText,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: voiceProvider.confidence,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              
              // Instructions
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Voice Commands',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Ask about any subject or topic\n'
                      '• Speak in Hindi, English, or Hinglish\n'
                      '• Say "explain" for detailed answers\n'
                      '• Ask for examples or practice questions',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleVoiceInput() async {
    final voiceProvider = Provider.of<VoiceProvider>(context, listen: false);
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    
    if (!voiceProvider.isAvailable) {
      _showPermissionDialog();
      return;
    }
    
    if (voiceProvider.isListening) {
      await voiceProvider.stopListening();
      
      // Process the recognized text with AI
      if (voiceProvider.recognizedText.isNotEmpty) {
        await aiProvider.sendMessage(voiceProvider.recognizedText, isVoice: true);
        
        // Speak the AI response
        if (aiProvider.messages.isNotEmpty) {
          final lastMessage = aiProvider.messages.last;
          if (!lastMessage.isUser) {
            await voiceProvider.speak(lastMessage.text);
          }
        }
      }
    } else {
      await voiceProvider.startListening();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Microphone Permission'),
        content: const Text(
          'Voice Assistant needs microphone permission to listen to your voice commands. Please grant permission to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final voiceProvider = Provider.of<VoiceProvider>(context, listen: false);
              await voiceProvider.requestMicrophonePermission();
            },
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );
  }
}
