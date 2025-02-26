import 'package:flutter/material.dart';
import 'otp_verification.dart';
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality( // ✅ Ensures the whole screen is RTL
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar( // ✅ Add a back button
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // ✅ Right-align text
            children: <Widget>[
              const SizedBox(height: 2),
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7E6), // Light background
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.lock_outline, // Lock icon
                    size: 50,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ✅ Title: Forgot Password
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

              // ✅ Subtitle
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

              // ✅ Email Input Field
              _buildInputField(
                label: 'البريد الإلكتروني',
                hintText: 'example@gmail.com',
              ),
              const SizedBox(height: 24),

              // ✅ Send Verification Button
              _buildVerificationButton(context),

              const SizedBox(height: 16),

              // ✅ "Remember Password?" & "Login"
              _buildLoginOption(context), // ✅ Pass context here
            ],
          ),
        ),
      ),

    );
  }

  // 🔹 Custom Widget: Input Field (Right Aligned)
  Widget _buildInputField({required String label, required String hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          textAlign: TextAlign.end,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF989898),
            fontFamily: 'IBM Plex Sans Arabic',
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          textAlign: TextAlign.end,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.black),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: const BorderSide(color: Color(0xFFECECEC)),
            ),
          ),
        ),
      ],
    );
  }

  // 🔹 Custom Widget: Send Verification Button
  Widget _buildVerificationButton(BuildContext context) { // ✅ Accept context here
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OTPVerificationPage()),
          );
        },
        child: const Text(
          'إرسال رمز التحقق',
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


  // 🔹 Custom Widget: "Remember Password?" & "Login"
  Widget _buildLoginOption(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // ✅ Aligns elements properly
      children: [
        // ✅ "Login" button (Right-aligned)
        TextButton(
          onPressed: () {
            Navigator.pop(context); // ✅ Go back to Login Page
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

        // ✅ "Remember Password?" (Left-aligned)
        const Text(
          'تذكرت كلمة المرور؟',
          textAlign: TextAlign.start, // ✅ Left-aligns text
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontFamily: 'IBM Plex Sans Arabic',
          ),
        ),
      ],
    );
  }
}
