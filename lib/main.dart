import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'login.dart';
import 'homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Registration',
      theme: ThemeData(
        fontFamily: 'IBM Plex Sans Arabic',
        scaffoldBackgroundColor: const Color(0xFFFEFBFA),
      ),
      home: const RegisterWidget(),
    );
  }
}

class RegisterWidget extends StatefulWidget {
  const RegisterWidget({Key? key}) : super(key: key);

  @override
  State<RegisterWidget> createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  /// ✅ **Handles registration with FirebaseAuth and saves user data to Firestore**
  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': name,
          'email': email,
          'createdAt': Timestamp.now(),
        });

        _showMessage('✅ تم التسجيل بنجاح: $email');
        _navigateToHome();

      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          _showMessage('⚠️ هذا البريد الإلكتروني مسجل بالفعل.');
        } else {
          _showMessage('⚠️ فشل التسجيل: ${e.message}');
        }
      } catch (e) {
        _showMessage('⚠️ حدث خطأ غير متوقع: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      _showMessage('⚠️ يرجى ملء جميع الحقول.');
    }
  }

  /// 📝 **Snackbar for messages**
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
  /// 🔄 **Navigate to Home Page**
  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }
  /// 🔄 **Navigate to Login Page**
  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.topRight,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 100,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '!سجّل الآن',
                    style: TextStyle(
                      color: Color.fromRGBO(27, 19, 42, 1),
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '.ادخل البيانات التالية لإنشاء حساب جديد',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Color.fromRGBO(122, 122, 122, 1),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildInputField(
                    controller: _nameController,
                    label: 'الاسم الكامل',
                    hintText: 'Ahmed Al-Azaiza'),
                const SizedBox(height: 16),
                _buildInputField(
                    controller: _emailController,
                    label: 'البريد الالكتروني',
                    hintText: 'example@gmail.com'),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 32),
                _isLoading
                    ? const CircularProgressIndicator()
                    : _buildRegisterButton(),
                const SizedBox(height: 24),
                _buildLoginOption(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 📝 **Reusable Input Field Widget**
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF989898),
            fontSize: 14,
            fontFamily: 'IBM Plex Sans Arabic',
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
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

  /// 🔒 **Password Field Widget**
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
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
          textAlign: TextAlign.end,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: '***********',
            hintStyle: const TextStyle(color: Colors.black),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: const BorderSide(color: Color(0xFFECECEC)),
            ),
            prefixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible; // ✅ Toggle state
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  /// 🟡 **Register Button**
  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFE399),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'تسجيل مستخدم جديد',
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

  /// 🟢 **Login Redirect Option**
  Widget _buildLoginOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: _navigateToLogin,
          child: const Text(
            '!سجّل دخول الآن',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'IBM Plex Sans Arabic',
            ),
          ),
        ),
        const Text(
          'لديك حساب بالفعل؟',
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
