import 'package:flutter/material.dart';
import 'login.dart'; // ✅ Make sure this is your actual login page

class CongratulationsPage extends StatelessWidget {
  const CongratulationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr, // ✅ Ensures RTL layout
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black), // ✅ Back button
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // ✅ Center content
            children: <Widget>[
              // ✅ Celebration Icon
              Container(

                child: Image.asset(
                  'assets/images/confetti.png', // ✅ Use your confetti image
                  width: 100,
                  height: 100,
                ),
              ),


              // ✅ Title: "Congratulations!"
              const Text(
                '!تهانينا',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B132A),
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
              const SizedBox(height: 30),

              // ✅ Subtitle: Password changed successfully
              const Text(
                'لقد تم تغيير كلمة مرور حسابك بنجاح، يمكنك الآن العودة وتسجيل الدخول من جديد',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7A7A7A),
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
              const SizedBox(height: 32),

              // ✅ Login Button
              _buildLoginButton(context),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Custom Widget: Login Button
  Widget _buildLoginButton(BuildContext context) {
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
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()), // ✅ Navigate to login
                (route) => false, // ✅ Remove previous screens from stack
          );
        },
        child: const Text(
          'تسجيل الدخول',
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
}
