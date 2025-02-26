import 'package:flutter/material.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7ECCA), // Yellow background
      body: SafeArea(
        child: Stack(
          children: [
            // White rounded background
            Positioned(
              top: 150,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height - 150,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEFBFA), // White Background
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
              ),
            ),

            // Back button and title
            Positioned(
              top: 50,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                onPressed: () => Navigator.pop(context),
                tooltip: 'رجوع',
              ),
            ),
            Positioned(
              top: 50,
              right: MediaQuery.of(context).size.width / 2 - 40,
              child: const Text(
                'مساعدة',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Main Content
            Positioned(
              top: 180,
              left: 0,
              right: 0,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'مرحبًا بك في مركز المساعدة',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'إذا كان لديك أي استفسار أو مشكلة تتعلق بالتطبيق، يمكنك التواصل معنا في أي وقت عبر البريد الإلكتروني',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [
                          Icon(Icons.email, color: Colors.deepPurple),
                          SizedBox(width: 8),
                          Text(
                            'support@example.com',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.blueAccent,
                              decoration: TextDecoration.underline,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'مميزات الدعم:\n'
                            '- إرشادات الاستخدام.\n'
                            '- الدعم الفني.\n'
                            '- الأسئلة الشائعة.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          height: 1.8,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: const BoxDecoration(
                                color: Color(0xFFB0DCDD),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.help_outline,
                                  size: 40, color: Colors.white),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              '!نحن هنا للمساعدة في أي وقت',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
