import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'clinic_model.dart';
import 'AddClinic.dart'; // Import the AddClinicPage

class ListOfClinicsWidget extends StatefulWidget {
  const ListOfClinicsWidget({super.key});

  @override
  State<ListOfClinicsWidget> createState() => _ListOfClinicsWidgetState();
}

class _ListOfClinicsWidgetState extends State<ListOfClinicsWidget> {
  final TextEditingController searchController = TextEditingController();
  final ClinicService _clinicService = ClinicService();
  bool _isLoading = true;

  List<Clinic> clinics = [];
  List<Clinic> filteredClinics = [];

  @override
  void initState() {
    super.initState();
    _fetchClinics();
  }

  void _fetchClinics() {
    setState(() {
      _isLoading = true;
    });

    _clinicService.getClinics().listen((fetchedClinics) {
      setState(() {
        clinics = fetchedClinics;
        filteredClinics = List.from(clinics);
        _isLoading = false;
      });
    }, onError: (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء تحميل العيادات: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void filterClinics(String query) {
    setState(() {
      filteredClinics = clinics
          .where((clinic) =>
      clinic.name.toLowerCase().contains(query.toLowerCase()) ||
          clinic.category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // Set RTL for the whole screen
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'العيادات',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: searchController,
                textAlign: TextAlign.right,
                onChanged: filterClinics,
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
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredClinics.isEmpty
                    ? const Center(child: Text('لا توجد عيادات'))
                    : ListView.builder(
                  itemCount: filteredClinics.length,
                  itemBuilder: (context, index) {
                    final clinic = filteredClinics[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Delete button
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    // Show confirmation dialog
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
                                // Clinic name and category
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

                            // Only show address if it's not empty
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

                            // Only show contact info if available
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

                            // Only show working hours if available
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // Navigate to AddClinicPage and wait for result

          },
          backgroundColor: const Color(0xFFFFE399),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}