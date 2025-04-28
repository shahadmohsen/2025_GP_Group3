import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SuggestClinicPage extends StatefulWidget {
  @override
  _SuggestClinicPageState createState() => _SuggestClinicPageState();
}

class _SuggestClinicPageState extends State<SuggestClinicPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController workingHoursController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool isLoading = false;
  String? selectedCategory;

  // List of clinic categories
  final List<String> categories = [
    'عيادة',
    'مستشفى',
    'مركز طبي',
    'عيادة مختصة',
    'مدرسة',
    'أخرى'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اقتراح عيادة', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'يرجى تقديم المعلومات الأساسية حول العيادة',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              SizedBox(height: 20),
              _buildInputField('إسم المكان', nameController),

              // Dropdown menu for category selection
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      hint: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'الفئة',
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                      icon: Icon(Icons.arrow_drop_down),
                      elevation: 16,
                      style: TextStyle(color: Colors.black),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue;
                        });
                      },
                      items: categories.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              value,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              _buildInputField('العنوان', addressController),
              _buildInputField('ساعات العمل', workingHoursController),
              _buildInputField('رقم الهاتف', phoneController),
              _buildInputField('البريد الإلكتروني', emailController),
              _buildInputField('وصف العيادة (اختياري)', descriptionController, maxLines: 3),
              SizedBox(height: 30),
              Center(
                child: isLoading
                    ? CircularProgressIndicator(color: Color(0xFFFFE399))
                    : ElevatedButton(
                  onPressed: _submitSuggestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFE399),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    minimumSize: Size(260, 54),
                  ),
                  child: Text('إرسال',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: label,
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }

  void _submitSuggestion() async {
    if (nameController.text.isEmpty) {
      _showErrorDialog('الرجاء إدخال اسم المكان على الأقل');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Store suggestion in Firestore
      await FirebaseFirestore.instance.collection('clinic_suggestions').add({
        'name': nameController.text,
        'category': selectedCategory ?? 'غير محدد',
        'address': addressController.text,
        'workingHours': workingHoursController.text,
        'phone': phoneController.text,
        'email': emailController.text,
        'description': descriptionController.text.isEmpty ? null : descriptionController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending', // pending, approved, or rejected
        'contactInfo': '', // For compatibility with your Clinic model
      });

      // Show success message
      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog('حدث خطأ: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تم الإرسال بنجاح'),
          content: Text('شكراً لك على اقتراح عيادة جديدة. سنراجع المعلومات قريباً.'),
          actions: [
            TextButton(
              child: Text('حسناً'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to previous screen
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('خطأ'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('حسناً'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}