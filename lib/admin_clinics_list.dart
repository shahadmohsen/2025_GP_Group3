import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'clinic_model.dart';
import 'AddClinic.dart';

// Create a separate AdminClinicsList class that doesn't use ListOfClinicsWidget
class AdminClinicsList extends StatefulWidget {
  const AdminClinicsList({Key? key}) : super(key: key);

  @override
  State<AdminClinicsList> createState() => _AdminClinicsListState();
}

class _AdminClinicsListState extends State<AdminClinicsList> {
  final ClinicService _clinicService = ClinicService();
  final TextEditingController searchController = TextEditingController();
  List<Clinic> filteredClinics = [];

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

          // Filter if search text exists
          final List<Clinic> displayClinics;
          if (searchController.text.isNotEmpty) {
            displayClinics = clinics.where((clinic) =>
            clinic.name.toLowerCase().contains(searchController.text.toLowerCase()) ||
                clinic.category.toLowerCase().contains(searchController.text.toLowerCase())
            ).toList();
          } else {
            displayClinics = clinics;
          }

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: searchController,
                    textAlign: TextAlign.right,
                    onChanged: (value) {
                      setState(() {});  // Refresh to apply filter
                    },
                    decoration: InputDecoration(
                      hintText: 'بحث',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                    ),
                  ),
                ),

                // Clinics list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: displayClinics.length,
                    itemBuilder: (context, index) {
                      final clinic = displayClinics[index];
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
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to AddClinicPage and wait for result
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddClinicPage()),
          );

          // Refresh the list if a clinic was added
          if (result == true) {
            setState(() {}); // Trigger a rebuild
          }
        },
        backgroundColor: const Color(0xFFFFE399),
        child: const Icon(Icons.add, color: Colors.white),
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