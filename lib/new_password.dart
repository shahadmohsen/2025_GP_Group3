import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'congratulations.dart';

class NewPasswordPage extends StatefulWidget {
  final String email; // User's email passed from the previous screen

  const NewPasswordPage({super.key, required this.email});

  @override
  _NewPasswordPageState createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isObscuredNewPassword = true;
  bool _isObscuredConfirmPassword = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔹 Function to update password
  Future<void> _updatePassword() async {
    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // 🔸 Validate input
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showMessage("Please fill in both fields.");
      return;
    }
    if (newPassword.length < 8) {
      _showMessage("Password must be at least 8 characters long.");
      return;
    }
    if (newPassword != confirmPassword) {
      _showMessage("Passwords do not match.");
      return;
    }

    try {
      // 🔹 Get the current user
      User? user = _auth.currentUser;

      if (user != null) {
        // 🔹 Update password in Firebase Authentication
        await user.updatePassword(newPassword);

        // 🔹 Update password in Firestore (if using Firestore)
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid) // Using UID as document ID
            .update({'password': newPassword}); // ⚠️ Store hashed passwords in production!

        // 🔹 Navigate to success page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CongratulationsPage()),
        );

        _showMessage("Password updated successfully!");
      } else {
        _showMessage("User not found. Please log in again.");
      }
    } catch (e) {
      _showMessage("Error updating password: $e");
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 16),
              const Text(
                'ادخل كلمة المرور الجديدة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B132A),
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
              const SizedBox(height: 32),

              // 🔹 New Password Field
              _buildPasswordField(
                controller: _newPasswordController,
                label: 'كلمة المرور الجديدة',
                obscureText: _isObscuredNewPassword,
                toggleVisibility: () {
                  setState(() {
                    _isObscuredNewPassword = !_isObscuredNewPassword;
                  });
                },
              ),

              const SizedBox(height: 16),

              // 🔹 Confirm Password Field
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: 'تأكيد كلمة المرور الجديدة',
                obscureText: _isObscuredConfirmPassword,
                toggleVisibility: () {
                  setState(() {
                    _isObscuredConfirmPassword = !_isObscuredConfirmPassword;
                  });
                },
              ),

              const SizedBox(height: 24),

              // 🔹 Change Password Button
              _buildChangePasswordButton(),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Custom Password Field
  Widget _buildPasswordField({
    required TextEditingController controller,
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
          controller: controller,
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

  // 🔹 Change Password Button
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
        onPressed: _updatePassword,
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