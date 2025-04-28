import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'forgetpass.dart';
import 'homepage.dart';
import 'main.dart';
import 'AdminPage.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Login',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFEFBFA),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String _errorMessage = '';

  /// Handle login with FirebaseAuth
  Future<void> _handleLogin() async {
    // Clear any previous error messages
    setState(() {
      _errorMessage = '';
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = '⚠️ الرجاء إدخال البريد الإلكتروني وكلمة المرور';
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _showMessage('✅ تم تسجيل الدخول بنجاح!');

      // Delay navigation slightly to allow Snackbar to show
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          // Check if this is a special account
          if (email == "admin4@gmail.com") {
            // Navigate to admin page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminPage()),
            );
          } else {
            // Navigate to regular homepage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
        }
      });
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors with clear Arabic messages
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = '⚠️ لم يتم العثور على حساب بهذا البريد الإلكتروني';
            break;
          case 'wrong-password':
            _errorMessage = '⚠️ كلمة المرور غير صحيحة';
            break;
          case 'invalid-email':
            _errorMessage = '⚠️ صيغة البريد الإلكتروني غير صحيحة';
            break;
          case 'user-disabled':
            _errorMessage = '⚠️ تم تعطيل هذا الحساب';
            break;
          case 'too-many-requests':
            _errorMessage = '⚠️ محاولات كثيرة للدخول، الرجاء المحاولة لاحقاً';
            break;
          default:
            _errorMessage = '⚠️ فشل تسجيل الدخول، الرجاء التحقق من بياناتك';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = '⚠️ حدث خطأ غير متوقع، الرجاء المحاولة مرة أخرى';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Show message in Snackbar
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // Changed to RTL for Arabic
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start, // Adjusted for RTL
                children: <Widget>[
                  Align(
                    alignment: Alignment.topRight,
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'أهلا بعودتك!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildInputField(
                      controller: _emailController,
                      label: 'البريد الإلكتروني',
                      hintText: 'example@gmail.com'),
                  const SizedBox(height: 16),
                  _buildPasswordField(),

                  // Display error message if there is one
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: 24),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildLoginButton(),
                  const SizedBox(height: 16),
                  _buildSignupOption(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Password Field with Forgot Password link
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Adjusted for RTL
      children: [
        const Text(
          'كلمة المرور',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF989898),
            fontFamily: 'IBM Plex Sans Arabic',
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: '***********',
            hintStyle: const TextStyle(color: Colors.black),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: const BorderSide(color: Color(0xFFECECEC)),
            ),
            suffixIcon: IconButton( // Changed from prefixIcon to suffixIcon for RTL
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ForgotPasswordPage()),
              );
            },
            child: const Text(
              'هل نسيت كلمة المرور؟',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'IBM Plex Sans Arabic',
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Reusable Input Field
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Adjusted for RTL
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF989898),
            fontFamily: 'IBM Plex Sans Arabic',
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          textAlign: TextAlign.right,
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

  /// Login Button
  Widget _buildLoginButton() {
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
        onPressed: _handleLogin,
        child: const Text(
          'تسجيل الدخول',
          style: TextStyle(
            color: Colors.white, // Changed to black for better visibility on yellow
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'IBM Plex Sans Arabic',
          ),
        ),
      ),
    );
  }

  /// Signup & Admin Options
  Widget _buildSignupOption(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ليس لديك حساب؟',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontFamily: 'IBM Plex Sans Arabic',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterWidget()),
                );
              },
              child: const Text(
                'سجل الآن!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
            ),

          ],
        ),
      ],
    );
  }
}