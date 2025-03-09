import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'new_password.dart';

class OTPVerificationPage extends StatefulWidget {
  final String verificationId; // Required for Firebase OTP Verification
  final String email; // The email to which OTP was sent

  const OTPVerificationPage({
    super.key,
    required this.verificationId,
    required this.email,
  });

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final TextEditingController _digit1 = TextEditingController();
  final TextEditingController _digit2 = TextEditingController();
  final TextEditingController _digit3 = TextEditingController();
  final TextEditingController _digit4 = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _secondsRemaining = 59;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
        startTimer();
      } else {
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  // 🔹 Function to verify OTP
  Future<void> _verifyOTP() async {
    String otpCode =
        "${_digit1.text}${_digit2.text}${_digit3.text}${_digit4.text}";

    if (otpCode.length != 4) {
      _showMessage("Please enter the complete OTP.");
      return;
    }

    try {
      // 🔹 Verify OTP with Firebase
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otpCode,
      );

      // 🔹 Sign in the user with the verified OTP
      await _auth.signInWithCredential(credential);

      // 🔹 Navigate to Reset Password Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NewPasswordPage(email: widget.email),
        ),
      );

      _showMessage("OTP Verified Successfully!");
    } catch (e) {
      _showMessage("Invalid OTP. Please try again.");
    }
  }

  // 🔹 Function to display messages
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 70),

              // 🔹 Lock Icon
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E6),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(Icons.lock_outline, size: 40, color: Colors.black),
              ),
              const SizedBox(height: 20),

              // 🔹 Title
              const Text(
                'ادخل رمز التحقق',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B132A),
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
              const SizedBox(height: 8),

              // 🔹 Subtitle
              const Text(
                'لقد قمنا بإرسال رمز التأكيد للبريد الإلكتروني التالي',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7A7A7A),
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
              const SizedBox(height: 4),

              // 🔹 Email Address
              Text(
                widget.email,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
              const SizedBox(height: 24),

              // 🔹 OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _otpBox(_digit1),
                  const SizedBox(width: 10),
                  _otpBox(_digit2),
                  const SizedBox(width: 10),
                  _otpBox(_digit3),
                  const SizedBox(width: 10),
                  _otpBox(_digit4),
                ],
              ),
              const SizedBox(height: 20),

              // 🔹 Countdown Timer
              Text(
                _secondsRemaining > 0
                    ? "00:${_secondsRemaining.toString().padLeft(2, '0')}"
                    : '',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // 🔹 Resend Code Option
              _canResend
                  ? TextButton(
                onPressed: () {
                  setState(() {
                    _secondsRemaining = 59;
                    _canResend = false;
                    startTimer();
                  });
                },
                child: const Text(
                  'طلب رمز جديد',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'IBM Plex Sans Arabic',
                  ),
                ),
              )
                  : const Text(
                'لم تستلم رمزاً؟',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7A7A7A),
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
              const SizedBox(height: 24),

              // 🔹 Verify Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE399),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _verifyOTP,
                  child: const Text(
                    'تحقق',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 🔹 "Remember Password?" & "Login"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
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
                  const Text(
                    'تذكرت كلمة المرور؟',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 OTP Input Box
  Widget _otpBox(TextEditingController controller) {
    return SizedBox(
      width: 50,
      height: 50,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFFFE399), width: 2),
          ),
        ),
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}