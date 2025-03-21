import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:semicolon/pages/mood_page.dart';
import 'dart:math';

import 'package:semicolon/pages/wave_page.dart';

class MainInterface extends StatefulWidget {
  const MainInterface({super.key});

  @override
  _MainInterfaceState createState() => _MainInterfaceState();
}

class _MainInterfaceState extends State<MainInterface>
    with SingleTickerProviderStateMixin {
  Future<String?> getIdToken() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser; // Get the current user
    if (user != null) {
      return await user.getIdToken(); // Fetch the ID token
    }
    return null; // User is not logged in
  }

  Future<String?> getUserID() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid; // Returns null if no user is logged in
  }

  final List<String> quotes = [
    "You are stronger than you think.",
    "Every day is a new beginning.",
    "Believe in yourself and all that you are.",
    "You radiate positivity!",
    "Your smile can light up the darkest room.",
    "You are enough, just as you are.",
    "Take a deep breath. You’re doing great.",
    "Happiness looks good on you.",
    "The best is yet to come!",
    "You bring light wherever you go.",
    "Be proud of how far you’ve come.",
    "You have the power to create change.",
    "Trust the magic of new beginnings.",
    "Small steps every day lead to big changes.",
    "Your presence makes a difference.",
    "You are more capable than you realize.",
    "Shine bright, the world needs your light.",
    "It's okay to take a break and breathe.",
    "Your kindness is contagious.",
    "Today is full of endless possibilities.",
    "You are a beautiful work in progress.",
    "Let your heart be light and your smile wide.",
    "You are loved more than you know.",
    "Embrace the journey, not just the destination.",
    "There is calm in every storm, and you’ll find it."
  ];

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFFFAF3E0); // Soft beige
    final Color primaryTextColor = const Color(0xFF4A635D); // Sage green
    final Color buttonColor = const Color(0xFF9DC3C2); // Muted blue/green

    final random = Random();
    final String randomQuote = quotes[random.nextInt(quotes.length)];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Heading & Quote Section
              Column(
                children: [
                  const SizedBox(height: 60),

                  // Calmer Heading
                  Text(
                    "Let's Check In with You",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.merriweather(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: primaryTextColor.withOpacity(0.9),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Subtle Quote with Fade & Slide
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          // Optional icon, made small and subtle
                          Text(
                            "🌿",
                            style: TextStyle(
                              fontSize: 20,
                              color: primaryTextColor.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Minimal quote, no box, lots of breathing room
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "“$randomQuote”",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lora(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                height: 1.5,
                                color: primaryTextColor.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Center Ripple Start Button
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: () async {
                      String? idToken =
                          await getIdToken(); // Fetch token asynchronously

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WavePage(
                              id_token: idToken), // Pass the fetched token
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            buttonColor.withOpacity(0.4),
                            buttonColor,
                          ],
                          radius: 0.85,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: buttonColor.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "Start",
                          style: GoogleFonts.lora(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // What's My Mood Button
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: ElevatedButton(
                  onPressed: () async {
                    String? userID = await getUserID();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return MoodPieChart(
                          userID: userID!,
                        );
                      }),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    shadowColor: buttonColor.withAlpha(100),
                  ),
                  child: Text(
                    "What's my Mood?",
                    style: GoogleFonts.lora(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
