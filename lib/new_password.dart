import 'package:flutter/material.dart';
import 'congratulations.dart';
class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});

  @override
  _NewPasswordPageState createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  bool _isObscuredNewPassword = true;
  bool _isObscuredConfirmPassword = true;

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
            crossAxisAlignment: CrossAxisAlignment.center, // ✅ Center text
            children: <Widget>[
              // ✅ Lock Icon in Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E7), // Light background
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  '***',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ✅ Title: "Enter New Password"
              const Text(
                '!ادخل كلمة المرور الجديدة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B132A),
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
              const SizedBox(height: 8),

              // ✅ Subtitle: Password instructions
              const Text(
                '!قم بادخال كلمة المرور الجديدة ويجب ان تكون مكونه من 8 خانات',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7A7A7A),
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
              const SizedBox(height: 32),

              // ✅ New Password Field
              _buildPasswordField(
                label: 'كلمة المرور الجديدة',
                obscureText: _isObscuredNewPassword,
                toggleVisibility: () {
                  setState(() {
                    _isObscuredNewPassword = !_isObscuredNewPassword;
                  });
                },
              ),

              const SizedBox(height: 16),

              // ✅ Confirm New Password Field
              _buildPasswordField(
                label: 'تأكيد كلمة المرور الجديدة',
                obscureText: _isObscuredConfirmPassword,
                toggleVisibility: () {
                  setState(() {
                    _isObscuredConfirmPassword = !_isObscuredConfirmPassword;
                  });
                },
              ),

              const SizedBox(height: 24),

              // ✅ Change Password Button
              _buildChangePasswordButton(),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Custom Widget: Password Input Field
  Widget _buildPasswordField({
    required String label,
    required bool obscureText,
    required VoidCallback toggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF989898),
            fontFamily: 'IBM Plex Sans Arabic',
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          obscureText: obscureText,
          textAlign: TextAlign.end,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: '**********',
            hintStyle: const TextStyle(color: Colors.black),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: const BorderSide(color: Color(0xFFECECEC)),
            ),
            prefixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.black,
              ),
              onPressed: toggleVisibility,
            ),
          ),
        ),
      ],
    );
  }

  // 🔹 Custom Widget: Change Password Button
  Widget _buildChangePasswordButton() {
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
            MaterialPageRoute(builder: (context) => const CongratulationsPage()),
          );
          // TODO: Implement password change logic
        },
        child: const Text(
          'تغيير كلمة المرور',
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
