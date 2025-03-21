import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:semicolon/main_interface.dart';
import 'package:semicolon/pages/signup_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Color(0xFFFAF3E0);
    final Color cardColor = Color(0xFFE3E8E1);
    final Color primaryTextColor = Color(0xFF4A635D);
    final Color buttonColor = Color(0xFF9DC3C2);
    final Color inputBorderColor = Color(0xFFA5A58D);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Welcome Back!",
                textAlign: TextAlign.center,
                style: GoogleFonts.merriweather(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              SizedBox(height: 40),
              _buildInputField(
                controller: _emailController,
                label: "Email",
                icon: Icons.mail_outline_rounded,
                borderColor: inputBorderColor,
                fillColor: cardColor,
                textColor: primaryTextColor,
              ),
              SizedBox(height: 20),
              _buildInputField(
                controller: _passwordController,
                label: "Password",
                icon: Icons.lock_outline,
                borderColor: inputBorderColor,
                fillColor: cardColor,
                textColor: primaryTextColor,
                obscureText: true,
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                  shadowColor: buttonColor.withAlpha(120),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Login",
                        style: GoogleFonts.lora(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignupPage()),
                  );
                },
                child: Text(
                  "Don't have an account? Sign Up",
                  style: GoogleFonts.lora(
                    fontSize: 14,
                    color: primaryTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _requestPermissions() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Check if permissions were granted before
  bool permissionsGranted = prefs.getBool("permissionsGranted") ?? false;

  if (!permissionsGranted) {
    // Request microphone permission (Internet is automatically granted)
    PermissionStatus microphoneStatus = await Permission.microphone.request();

    if (microphoneStatus.isGranted) {
      // Save permission status to SharedPreferences
      await prefs.setBool("permissionsGranted", true);
    } else {
      _showSnackbar("Microphone permission is required for voice features.");
    }
  }
}

  void _handleLogin() async {
  setState(() {
    _isLoading = true;
  });

  // Ensure permissions are granted
  await _requestPermissions();

  String email = _emailController.text.trim();
  String password = _passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    _showSnackbar("Please enter both email and password.");
    setState(() {
      _isLoading = false;
    });
    return;
  }

  bool loginSuccess = await _loginUser(email, password);
  if (loginSuccess) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainInterface()),
    );
  }

  setState(() {
    _isLoading = false;
  });
}


  Future<bool> _loginUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    String message = "Login failed. Please try again.";

    if (e.code == 'user-not-found') {
      message = "No user found with this email.";
    } else if (e.code == 'wrong-password') {
      message = "Incorrect password.";
    } else if (e.code == 'invalid-email') {
      message = "Invalid email format.";
    }

    _showSnackbar(message);
  }

  void _showSnackbar(String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color borderColor,
    required Color fillColor,
    required Color textColor,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        cursorColor: textColor,
        style: GoogleFonts.lora(
          color: textColor,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          labelText: label,
          labelStyle: GoogleFonts.lora(
            color: textColor.withAlpha(200),
          ),
          prefixIcon: Icon(
            icon,
            color: textColor.withAlpha(200),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: borderColor.withAlpha(100),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: borderColor,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          filled: true,
          fillColor: fillColor,
        ),
      ),
    );
  }
}
