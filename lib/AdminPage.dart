import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AddClinic.dart';
import 'manageprofile.dart';
import 'admin_clinics_list.dart';
import 'clinic_model.dart';

// Define the suggestions tab directly within this file
class AdminSuggestionsTab extends StatefulWidget {
  const AdminSuggestionsTab({Key? key}) : super(key: key);

  @override
  State<AdminSuggestionsTab> createState() => _AdminSuggestionsTabState();
}

class _AdminSuggestionsTabState extends State<AdminSuggestionsTab> {
  bool _showApproved = false;
  bool _showRejected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('clinic_suggestions').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('لا توجد اقتراحات حتى الآن'));
          }

          // Filter suggestions based on selected filters
          var suggestions = snapshot.data!.docs;
          List<QueryDocumentSnapshot> filteredSuggestions = [];

          if (!_showApproved && !_showRejected) {
            filteredSuggestions = suggestions.where((doc) => doc['status'] == 'pending').toList();
          } else if (_showApproved) {
            filteredSuggestions = suggestions.where((doc) => doc['status'] == 'approved').toList();
          } else if (_showRejected) {
            filteredSuggestions = suggestions.where((doc) => doc['status'] == 'rejected').toList();
          }

          if (filteredSuggestions.isEmpty) {
            return Center(
              child: Text(
                _showApproved
                    ? 'لا توجد اقتراحات موافق عليها'
                    : _showRejected
                    ? 'لا توجد اقتراحات مرفوضة'
                    : 'لا توجد اقتراحات قيد الانتظار',
              ),
            );
          }

          return Column(
            children: [
              // Filter options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: FilterChip(
                        label: const Text('قيد الانتظار'),
                        selected: !_showApproved && !_showRejected,
                        onSelected: (selected) {
                          setState(() {
                            _showApproved = false;
                            _showRejected = false;
                          });
                        },
                        backgroundColor: Colors.grey.shade200,
                        selectedColor: const Color(0xFFFFE399),
                      ),
                    ),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: FilterChip(
                        label: const Text('الموافق عليها'),
                        selected: _showApproved,
                        onSelected: (selected) {
                          setState(() {
                            _showApproved = selected;
                            if (selected) _showRejected = false;
                          });
                        },
                        backgroundColor: Colors.grey.shade200,
                        selectedColor: Colors.green.shade100,
                      ),
                    ),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: FilterChip(
                        label: const Text('المرفوضة'),
                        selected: _showRejected,
                        onSelected: (selected) {
                          setState(() {
                            _showRejected = selected;
                            if (selected) _showApproved = false;
                          });
                        },
                        backgroundColor: Colors.grey.shade200,
                        selectedColor: Colors.red.shade100,
                      ),
                    ),
                  ],
                ),
              ),

              // Suggestions list
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredSuggestions.length,
                    itemBuilder: (context, index) {
                      final doc = filteredSuggestions[index];
                      final data = doc.data() as Map<String, dynamic>;

                      // Define card color based on status
                      Color cardColor = Colors.white;
                      if (data['status'] == 'approved') {
                        cardColor = Colors.green.shade50;
                      } else if (data['status'] == 'rejected') {
                        cardColor = Colors.red.shade50;
                      }

                      return Card(
                        color: cardColor,
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
                                  // Action buttons based on status
                                  data['status'] == 'pending'
                                      ? Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.check_circle, color: Colors.green),
                                        onPressed: () => _approveSuggestion(doc.id, data),
                                        tooltip: 'موافقة',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.cancel, color: Colors.red),
                                        onPressed: () => _rejectSuggestion(doc.id),
                                        tooltip: 'رفض',
                                      ),
                                    ],
                                  )
                                      : data['status'] == 'approved'
                                      ? const Chip(
                                    label: Text('تمت الموافقة'),
                                    backgroundColor: Colors.green,
                                    labelStyle: TextStyle(color: Colors.white),
                                  )
                                      : const Chip(
                                    label: Text('مرفوضة'),
                                    backgroundColor: Colors.red,
                                    labelStyle: TextStyle(color: Colors.white),
                                  ),

                                  // Clinic name and category
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          data['name'] ?? 'غير محدد',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (data['category'] != null && data['category'].isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 5),
                                            child: Text(
                                              data['category'],
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

                              // Description
                              if (data['description'] != null && data['description'].isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    data['description'],
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),

                              // Address
                              if (data['address'] != null && data['address'].isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(data['address']),
                                      const SizedBox(width: 5),
                                      const Icon(Icons.location_on, color: Colors.blue),
                                    ],
                                  ),
                                ),

                              // Contact Info
                              if ((data['phone'] != null && data['phone'].isNotEmpty) || (data['email'] != null && data['email'].isNotEmpty))
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (data['phone'] != null && data['phone'].isNotEmpty) ...[
                                        Text(data['phone']),
                                        const SizedBox(width: 5),
                                        const Icon(Icons.phone, color: Colors.blue),
                                      ],
                                      if (data['phone'] != null && data['phone'].isNotEmpty && data['email'] != null && data['email'].isNotEmpty)
                                        const SizedBox(width: 20),
                                      if (data['email'] != null && data['email'].isNotEmpty) ...[
                                        Text(data['email']),
                                        const SizedBox(width: 5),
                                        const Icon(Icons.email, color: Colors.blue),
                                      ],
                                    ],
                                  ),
                                ),

                              // Working Hours
                              if (data['workingHours'] != null && data['workingHours'].isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(data['workingHours']),
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
              ),
            ],
          );
        },
      ),
    );
  }

  void _approveSuggestion(String id, Map<String, dynamic> data) async {
    try {
      // Update suggestion status
      await FirebaseFirestore.instance.collection('clinic_suggestions').doc(id).update({
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
      });

      // Add to clinics collection
      await FirebaseFirestore.instance.collection('clinics').add({
        'name': data['name'] ?? '',
        'category': data['category'] ?? '',
        'address': data['address'] ?? '',
        'workingHours': data['workingHours'] ?? '',
        'phone': data['phone'] ?? '',
        'email': data['email'] ?? '',
        'description': data['description'],
        'contactInfo': '${data['phone'] ?? ''} - ${data['email'] ?? ''}',
        'createdAt': FieldValue.serverTimestamp(),
        'createdFromSuggestion': true,
        'suggestionId': id,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت الموافقة على العيادة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _rejectSuggestion(String id) async {
    try {
      await FirebaseFirestore.instance.collection('clinic_suggestions').doc(id).update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم رفض العيادة'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // Set initial index to 0 to show الاقتراحات by default
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
          // Suggestions tab (now the first tab)
          const AdminSuggestionsTab(),
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
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Regular nav items in a row
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(Icons.person, "الحساب", _currentIndex == 3, () => _onItemTapped(3)),

                  // Empty space for the center button
                  const SizedBox(width: 40),
                  _buildNavItem(Icons.lightbulb_outline, "الاقتراحات", _currentIndex == 0, () => _onItemTapped(0)),
                ],
              ),
            ),
            // Centered main button on top
            Positioned(
              bottom: 15, // Adjust as needed to align vertically
              child: _buildMainNavItem(() => _onItemTapped(1)),
            ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.amberAccent,
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
    );
  }
}