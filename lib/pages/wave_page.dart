import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:semicolon/main_interface.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class WavePage extends StatefulWidget {
  final String? id_token;
  const WavePage({super.key, required this.id_token});

  @override
  _WavePageState createState() => _WavePageState();
}

class _WavePageState extends State<WavePage> with TickerProviderStateMixin {
  late AnimationController _rippleController;
  bool isListening = false;
  bool isAssistantSpeaking = false;
  late stt.SpeechToText _speech;
  String recognizedText = "";

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _speech = stt.SpeechToText();
    _checkMicrophonePermission(); // Check permission on startup
  }

  Future<void> _checkMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) {
        print("❌ Microphone permission denied!");
      }
    }
  }

  Future<void> sendDataToAPI(String text) async {
    final String apiUrl = "http://10.0.2.2:8000/hey";
    final Map<String, dynamic> requestBody = {
      "query": text,
      "mood": "happy",
      "id_token": widget.id_token,
    };
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        print("✅ API Response: ${response.body}");
      } else {
        print("❌ Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("⚠️ Exception: $e");
    }
  }

  void _toggleListening() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) {
        print("❌ Microphone permission denied!");
        return;
      }
    }

    if (isListening) {
      // Stop listening when clicked again
      setState(() {
        isListening = false;
        isAssistantSpeaking = true;
      });
      _speech.stop();
      print("🛑 Stopped Listening! Final Text: $recognizedText");
      sendDataToAPI(recognizedText); // Send the final recognized text
    } else {
      // Start listening when clicked
      bool available = await _speech.initialize(
        onStatus: (status) => print("🎤 Speech Status: $status"),
        onError: (error) => print("⚠️ Speech Error: $error"),
      );

      if (available) {
        setState(() {
          isListening = true;
          isAssistantSpeaking = false;
        });

        recognizedText = ""; // Clear previous text before new listening session

        _speech.listen(
          onResult: (result) {
            setState(() {
              recognizedText =
                  result.recognizedWords; // Update only with final result
            });
          },
          partialResults: false, // Only process final result
          listenMode:
              stt.ListenMode.dictation, // Improves accuracy for full sentences
        );

        print("🎙️ Started Listening...");
      }
    }
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("id token: ${widget.id_token}");
    final Color backgroundColor = isAssistantSpeaking
        ? const Color(0x80A8D8D2)
        : isListening
            ? const Color(0xFFD3E8E1)
            : const Color(0xFFF4F1E1);
    final Color buttonColor = const Color(0xFF8FB8A8);
    final Color iconColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(
              isListening
                  ? "Listening to you..."
                  : isAssistantSpeaking
                      ? "Your Homie’s got something to say!"
                      : "Your Best Friend!",
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color:
                    isAssistantSpeaking ? buttonColor : const Color(0xFF4A635D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Center(
                child: Container(
                  width: 250,
                  height: 250,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: buttonColor,
                    boxShadow: [
                      BoxShadow(
                        color: buttonColor.withOpacity(0.6),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.waves,
                    color: iconColor,
                    size: 40,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _toggleListening,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: isListening
                            ? buttonColor.withOpacity(0.7)
                            : buttonColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: buttonColor.withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        isListening ? Icons.pause_circle_filled : Icons.mic,
                        color: iconColor,
                        size: 36,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainInterface(),
                        ),
                      );
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: buttonColor.withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close,
                        color: iconColor,
                        size: 36,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
