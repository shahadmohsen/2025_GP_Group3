import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AddClinic.dart';
import 'manageprofile.dart';
import 'clinics.dart'; // Import for the clinic list
import 'clinic_model.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // Set initial index to 0 to show الرئيسية by default
  int _currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          // Main content (could be a dashboard)
          Container(
            color: Colors.white,
            child: const Center(
              child: Text(
                'لوحة التحكم',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // List of clinics page with edit functionality
          const AdminClinicsList(),
          // Add clinic page
          const AddClinicPage(),
          // Manage profile page
          const ManageProfile(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 80,
        padding: const EdgeInsets.only(bottom: 10), // Add padding to move items up a bit
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.person, "الحساب", _currentIndex == 3, () => _onItemTapped(3)),
            _buildNavItem(Icons.add_circle_outline, "إضافة عيادة", _currentIndex == 2, () => _onItemTapped(2)),
            _buildMainNavItem(() => _onItemTapped(1)), // Main button for clinic list
            _buildNavItem(Icons.lightbulb_outline, "الاقتراحات", _currentIndex == 0, () => _onItemTapped(0)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? Colors.blue : Colors.grey),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.blue : Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainNavItem(VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8), // Add padding to move the button up
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFE399),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 3,
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: const Icon(
            Icons.storefront,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}

class AdminClinicsList extends StatefulWidget {
  const AdminClinicsList({Key? key}) : super(key: key);

  @override
  State<AdminClinicsList> createState() => _AdminClinicsListState();
}

class _AdminClinicsListState extends State<AdminClinicsList> {
  final ClinicService _clinicService = ClinicService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Clinic>>(
        stream: _clinicService.getClinics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد عيادات'));
          }

          final clinics = snapshot.data!;

          return Directionality(
            textDirection: TextDirection.rtl,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: clinics.length,
              itemBuilder: (context, index) {
                final clinic = clinics[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: InkWell(
                    onTap: () {
                      // This is what was missing - the onTap handler
                      _showEditDialog(context, clinic);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  bool confirm = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('تأكيد الحذف'),
                                        content: const Text('هل أنت متأكد من حذف هذه العيادة؟'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: const Text('إلغاء'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            child: const Text('حذف'),
                                          ),
                                        ],
                                      );
                                    },
                                  ) ?? false;

                                  if (confirm) {
                                    try {
                                      await _clinicService.deleteClinic(clinic.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('تم حذف العيادة بنجاح'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('حدث خطأ أثناء الحذف: ${e.toString()}'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      clinic.name.isNotEmpty ? clinic.name : 'غير محدد',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (clinic.category.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Text(
                                          clinic.category,
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (clinic.description != null && clinic.description!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                clinic.description!,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          // Additional clinic info...
                          // Address
                          if (clinic.address.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(clinic.address),
                                  const SizedBox(width: 5),
                                  const Icon(Icons.location_on, color: Colors.blue),
                                ],
                              ),
                            ),
                          // Contact Info
                          if (clinic.phone.isNotEmpty || clinic.email.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (clinic.phone.isNotEmpty) ...[
                                    Text(clinic.phone),
                                    const SizedBox(width: 5),
                                    const Icon(Icons.phone, color: Colors.blue),
                                  ],
                                  if (clinic.phone.isNotEmpty && clinic.email.isNotEmpty)
                                    const SizedBox(width: 20),
                                  if (clinic.email.isNotEmpty) ...[
                                    Text(clinic.email),
                                    const SizedBox(width: 5),
                                    const Icon(Icons.email, color: Colors.blue),
                                  ],
                                ],
                              ),
                            ),
                          // Working Hours
                          if (clinic.workingHours.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(clinic.workingHours),
                                  const SizedBox(width: 5),
                                  const Icon(Icons.access_time, color: Colors.blue),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Dialog to edit clinic details
  void _showEditDialog(BuildContext context, Clinic clinic) {
    // Create controllers with existing clinic data
    final nameController = TextEditingController(text: clinic.name);
    final addressController = TextEditingController(text: clinic.address);
    final workingHoursController = TextEditingController(text: clinic.workingHours);
    final phoneController = TextEditingController(text: clinic.phone);
    final emailController = TextEditingController(text: clinic.email);
    final descriptionController = TextEditingController(text: clinic.description ?? '');

    // For dropdown
    String selectedCategory = clinic.category;
    final List<String> categoryOptions = [
      'عيادة',
      'مستشفى',
      'مركز طبي',
      'عيادة مختصة',
      'أخرى'
    ];

    // If category is not in the list and not empty, add it to options
    if (clinic.category.isNotEmpty && !categoryOptions.contains(clinic.category)) {
      categoryOptions.add(clinic.category);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setState) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: AlertDialog(
                  title: const Text('تعديل معلومات العيادة'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Name field
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'اسم العيادة'),
                        ),
                        const SizedBox(height: 12),

                        // Category dropdown field
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'الفئة',
                            border: OutlineInputBorder(),
                          ),
                          value: selectedCategory.isEmpty ? null : selectedCategory,
                          hint: const Text('اختر الفئة'),
                          isExpanded: true,
                          items: categoryOptions.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedCategory = newValue;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        // Address field
                        TextField(
                          controller: addressController,
                          decoration: const InputDecoration(labelText: 'العنوان'),
                        ),
                        const SizedBox(height: 8),

                        // Working hours field
                        TextField(
                          controller: workingHoursController,
                          decoration: const InputDecoration(labelText: 'ساعات العمل'),
                        ),
                        const SizedBox(height: 8),

                        // Phone field
                        TextField(
                          controller: phoneController,
                          decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                        ),
                        const SizedBox(height: 8),

                        // Email field
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                        ),
                        const SizedBox(height: 8),

                        // Description field
                        TextField(
                          controller: descriptionController,
                          decoration: const InputDecoration(labelText: 'الوصف'),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () async {
                        try {
                          // Update clinic data
                          await _clinicService.updateClinic(clinic.id, {
                            'name': nameController.text,
                            'category': selectedCategory,
                            'address': addressController.text,
                            'workingHours': workingHoursController.text,
                            'phone': phoneController.text,
                            'email': emailController.text,
                            'description': descriptionController.text.isEmpty ? null : descriptionController.text,
                            'updatedAt': FieldValue.serverTimestamp(),
                          });

                          if (context.mounted) {
                            Navigator.pop(context);

                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم تحديث العيادة بنجاح'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('حدث خطأ: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        }
                      },
                      child: const Text('حفظ'),
                    ),
                  ],
                ),
              );
            }
        );
      },
    );
  }
}