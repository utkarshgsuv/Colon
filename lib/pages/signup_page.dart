import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart'; // Import login page to navigate back

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      final userCredentials =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      print(userCredentials);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign Up Successful!'),
          backgroundColor: Color(0xFF4A635D),
        ),
      );

      // Navigate back to login page after successful signup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already registered. Please login.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The password is too weak. Use at least 6 characters.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email format.';
      }

      // Show error message in a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Create Account",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.merriweather(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                SizedBox(height: 40),

                // Email Field
                _buildInputField(
                  controller: _emailController,
                  label: "Email",
                  icon: Icons.email_outlined,
                  borderColor: inputBorderColor,
                  fillColor: cardColor,
                  textColor: primaryTextColor,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Password Field
                _buildInputField(
                  controller: _passwordController,
                  label: "Password",
                  icon: Icons.lock_outline,
                  borderColor: inputBorderColor,
                  fillColor: cardColor,
                  textColor: primaryTextColor,
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: primaryTextColor.withAlpha(200),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40),

                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      createUserWithEmailAndPassword(); // Call function on button press
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                    shadowColor: buttonColor.withAlpha(120),
                  ),
                  child: Text(
                    "Sign Up",
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
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text(
                    "Already have an account? Login",
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
      ),
    );
  }

  /// Custom Input Field Widget
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color borderColor,
    required Color fillColor,
    required Color textColor,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
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
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        cursorColor: textColor,
        validator: validator, // Ensure validator is properly handled
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
          suffixIcon: suffixIcon ?? SizedBox(), // Ensures no null errors
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
