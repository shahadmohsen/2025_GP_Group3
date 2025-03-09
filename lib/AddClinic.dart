import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'clinic_model.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Optional, if you're using authentication

class AddClinicPage extends StatefulWidget {
  const AddClinicPage({super.key});

  @override
  State<AddClinicPage> createState() => _AddClinicPageState();
}

class _AddClinicPageState extends State<AddClinicPage> {
  // Controllers for text fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController workingHoursController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Create an instance of ClinicService
  final ClinicService _clinicService = ClinicService();

  // Dropdown related variables
  String? selectedCategory;
  final List<String> categoryOptions = [
    'عيادة',
    'مستشفى',
    'مركز طبي',
    'عيادة مختصة',
    'أخرى'
  ];

  bool _isLoading = false; // Loading state to show progress

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    nameController.dispose();
    addressController.dispose();
    workingHoursController.dispose();
    phoneController.dispose();
    emailController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // Method to display detailed error message
  void _showErrorDetails(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('خطأ في الإضافة'),
          content: SingleChildScrollView(
            child: Text(message),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('حسناً'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // Set RTL for the UI layout
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'إضافة عيادة',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Changed to start for RTL support
              children: [
                // Title
                const Center(
                  child: Text(
                    'تفاصيل العيادة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFFE399),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                const Text(
                  'يرجى تقديم المعلومات حول العيادة. جميع الحقول اختيارية.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
                const SizedBox(height: 20),

                // Text Fields - all optional
                buildTextField('إسم العيادة', nameController),

                // Dropdown for Category
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'الفئة',
                      labelStyle: const TextStyle(color: Colors.black54, fontSize: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: Color(0xFFFFE399),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: Color(0xFFFFE399),
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    value: selectedCategory,
                    hint: const Text('اختر الفئة (اختياري)'),
                    isExpanded: true,
                    alignment: Alignment.centerRight,
                    items: categoryOptions.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        alignment: Alignment.centerRight,
                        child: Text(
                          category,
                          textAlign: TextAlign.right,
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue;
                      });
                    },
                  ),
                ),

                buildTextField('العنوان', addressController),
                buildTextField('ساعات العمل', workingHoursController),
                buildTextField('رقم الهاتف', phoneController),
                buildTextField('البريد الالكتروني', emailController),
                buildTextField('وصف العيادة', descriptionController),

                const SizedBox(height: 30),
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Color(0xFFFFE399))
                      : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFE399),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(260, 54),
                    ),
                    onPressed: () async {
                      // Set loading state
                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        // Debugging: Check if user is authenticated (if using Firebase Auth)
                        /*
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          throw Exception('المستخدم غير مسجل الدخول. يرجى تسجيل الدخول أولاً.');
                        }
                        */

                        // Create a new Clinic object with possibly empty fields
                        final Clinic newClinic = Clinic(
                          id: '', // This will be set by Firestore
                          name: nameController.text,
                          category: selectedCategory ?? '',
                          address: addressController.text,
                          workingHours: workingHoursController.text,
                          contactInfo: '', // Empty string since we removed this field
                          phone: phoneController.text,
                          email: emailController.text,
                          description: descriptionController.text.isNotEmpty
                              ? descriptionController.text
                              : null,
                        );

                        // Save to Firestore
                        await _clinicService.addClinic(newClinic);

                        // Reset loading state
                        setState(() {
                          _isLoading = false;
                        });

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تمت إضافة العيادة بنجاح'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );

                        // Navigate back to the previous screen
                        Navigator.of(context).pop(true); // Pass true to indicate a clinic was added
                      } catch (e) {
                        // Reset loading state
                        setState(() {
                          _isLoading = false;
                        });

                        // Show specific error messages
                        if (e.toString().contains('permission-denied')) {
                          _showErrorDetails(
                              'ليس لديك الصلاحية لإضافة عيادة. يرجى التحقق من قواعد الأمان في Firebase.'
                                  '\n\nتفاصيل الخطأ: ${e.toString()}'
                          );
                        } else {
                          _showErrorDetails('حدث خطأ: ${e.toString()}');
                        }
                      }
                    },
                    child: const Text(
                      'إضافة العيادة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to Create a Text Field with bidirectional text support
  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right, // اجعل النص يبدأ من اليمين
        textDirection: TextDirection.rtl, // دعم الكتابة باللغة العربية
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: true,
          labelStyle: const TextStyle(color: Colors.black54, fontSize: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Color(0xFFFFE399),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Color(0xFFFFE399),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}