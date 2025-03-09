import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'congratulations.dart'; // Import the Congratulations page

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Function to handle password reset
  Future<void> _resetPassword() async {
    String email = _emailController.text.trim();

    // Basic email validation
    if (email.isEmpty || !email.contains('@')) {
      _showMessage('الرجاء إدخال بريد إلكتروني صالح');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Send password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // Navigate to Congratulations Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const CongratulationsPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase authentication errors
      String errorMessage = 'حدث خطأ غير متوقع';

      if (e.code == 'user-not-found') {
        errorMessage = 'لم يتم العثور على حساب مرتبط بهذا البريد الإلكتروني';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'عنوان البريد الإلكتروني غير صالح';
      }

      _showMessage(errorMessage);
    } catch (e) {
      _showMessage('حدث خطأ: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to display messages
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
        ),
        backgroundColor: Colors.black87,
      ),
    );
  }

  // Custom Widget: Input Field (Right Aligned)
  Widget _buildInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'البريد الإلكتروني',
          textAlign: TextAlign.end,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF989898),
            fontFamily: 'IBM Plex Sans Arabic',
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _emailController,
          textAlign: TextAlign.end,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'example@gmail.com',
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: const BorderSide(color: Color(0xFFECECEC)),
            ),
          ),
        ),
      ],
    );
  }

  // Custom Widget: Reset Password Button
  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFE399),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: _isLoading ? null : _resetPassword,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          'استعادة كلمة المرور',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'IBM Plex Sans Arabic',
          ),
        ),
      ),
    );
  }

  // Custom Widget: "Remember Password?" & "Login"
  Widget _buildLoginOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Login button
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Go back to Login Page
          },
          child: const Text(
            '!تسجيل الدخول',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'IBM Plex Sans Arabic',
            ),
          ),
        ),

        // Remember Password text
        const Text(
          'تذكرت كلمة المرور؟',
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontFamily: 'IBM Plex Sans Arabic',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 2),

              // Lock Icon Container
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7E6),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 50,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Title: Forgot Password
              const Text(
                '!استعادة كلمة المرور',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B132A),
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              const Text(
                '!قم بإدخال البريد الإلكتروني لاستعادة كلمة المرور الخاصة بك',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7A7A7A),
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),

              const SizedBox(height: 10),

              // Email Input Field
              _buildInputField(),

              const SizedBox(height: 24),

              // Reset Password Button
              _buildResetButton(),

              const SizedBox(height: 16),

              // Login Option
              _buildLoginOption(),
            ],
          ),
        ),
      ),
    );
  }
}