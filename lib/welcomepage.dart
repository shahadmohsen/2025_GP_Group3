import 'package:flutter/material.dart';
import 'main.dart';
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFBFA),
      body: Stack(
        children: [
          // Yellow corner image
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/images/corner.png',
              width: 200,
              fit: BoxFit.cover,
            ),
          ),

          // Page content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // Logo
                Image.asset(
                  'assets/images/logo.png',
                  width: 300,
                ),

                const SizedBox(height: 30),

                // Arabic slogan with blue word
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    text: 'كل يد ممدودة تصنع ',
                    style: TextStyle(
                      fontFamily: 'Lateef',
                      fontSize: 32,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: 'فرقًا',
                        style: TextStyle(
                          fontFamily: 'Lateef',
                          fontSize: 32,
                          color: Color(0xFF80CFEF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // Button
                SizedBox(
                  width: 250,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterWidget()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFE399),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text(
                      'انضم إلينا الآن',
                      style: TextStyle(
                        fontFamily: 'Lateef',
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
