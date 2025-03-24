import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'suggestion_service.dart';

class AdminSuggestionsTab extends StatefulWidget {
  const AdminSuggestionsTab({Key? key}) : super(key: key);

  @override
  State<AdminSuggestionsTab> createState() => _AdminSuggestionsTabState();
}

class _AdminSuggestionsTabState extends State<AdminSuggestionsTab> {
  final ClinicSuggestionService _suggestionService = ClinicSuggestionService();
  bool _showApproved = false;
  bool _showRejected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
            child: StreamBuilder<List<ClinicSuggestion>>(
              stream: _suggestionService.getSuggestions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('حدث خطأ: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('لا توجد اقتراحات حتى الآن'));
                }

                // Filter suggestions based on selected filters
                var suggestions = snapshot.data!;

                if (!_showApproved && !_showRejected) {
                  suggestions = suggestions.where((s) => s.status == 'pending').toList();
                } else if (_showApproved) {
                  suggestions = suggestions.where((s) => s.status == 'approved').toList();
                } else if (_showRejected) {
                  suggestions = suggestions.where((s) => s.status == 'rejected').toList();
                }

                if (suggestions.isEmpty) {
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

                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = suggestions[index];
                      return _buildSuggestionCard(suggestion);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(ClinicSuggestion suggestion) {
    // Define card color based on status
    Color cardColor = Colors.white;
    if (suggestion.status == 'approved') {
      cardColor = Colors.green.shade50;
    } else if (suggestion.status == 'rejected') {
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
                suggestion.status == 'pending'
                    ? Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () => _confirmAction(
                        context,
                        'تأكيد الموافقة',
                        'هل تريد الموافقة على إضافة هذه العيادة؟',
                            () => _approveSuggestion(suggestion.id),
                      ),
                      tooltip: 'موافقة',
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () => _confirmAction(
                        context,
                        'تأكيد الرفض',
                        'هل تريد رفض هذه العيادة؟',
                            () => _rejectSuggestion(suggestion.id),
                      ),
                      tooltip: 'رفض',
                    ),
                  ],
                )
                    : suggestion.status == 'approved'
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
                        suggestion.name.isNotEmpty ? suggestion.name : 'غير محدد',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (suggestion.category.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            suggestion.category,
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
            if (suggestion.description != null && suggestion.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  suggestion.description!,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),

            // Address
            if (suggestion.address.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(suggestion.address),
                    const SizedBox(width: 5),
                    const Icon(Icons.location_on, color: Colors.blue),
                  ],
                ),
              ),

            // Contact Info
            if (suggestion.phone.isNotEmpty || suggestion.email.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (suggestion.phone.isNotEmpty) ...[
                      Text(suggestion.phone),
                      const SizedBox(width: 5),
                      const Icon(Icons.phone, color: Colors.blue),
                    ],
                    if (suggestion.phone.isNotEmpty && suggestion.email.isNotEmpty)
                      const SizedBox(width: 20),
                    if (suggestion.email.isNotEmpty) ...[
                      Text(suggestion.email),
                      const SizedBox(width: 5),
                      const Icon(Icons.email, color: Colors.blue),
                    ],
                  ],
                ),
              ),

            // Working Hours
            if (suggestion.workingHours.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(suggestion.workingHours),
                    const SizedBox(width: 5),
                    const Icon(Icons.access_time, color: Colors.blue),
                  ],
                ),
              ),

            // Timestamp
            if (suggestion.timestamp != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'تاريخ الاقتراح: ${_formatTimestamp(suggestion.timestamp!)}',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmAction(BuildContext context, String title, String message, Function onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm();
                },
                child: const Text('تأكيد'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _approveSuggestion(String id) async {
    try {
      await _suggestionService.approveSuggestion(id);
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
      await _suggestionService.rejectSuggestion(id);
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

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}