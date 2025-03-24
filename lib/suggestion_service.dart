import 'package:cloud_firestore/cloud_firestore.dart';
import 'clinic_model.dart';

class ClinicSuggestion {
  String id;
  String name;
  String category;
  String address;
  String workingHours;
  String phone;
  String email;
  String? description;
  String status; // pending, approved, rejected
  Timestamp? timestamp;

  ClinicSuggestion({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.workingHours,
    required this.phone,
    required this.email,
    this.description,
    required this.status,
    this.timestamp,
  });

  factory ClinicSuggestion.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ClinicSuggestion(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      address: data['address'] ?? '',
      workingHours: data['workingHours'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      description: data['description'],
      status: data['status'] ?? 'pending',
      timestamp: data['timestamp'],
    );
  }

  // Convert to a Clinic object for addition to the clinics collection
  Clinic toClinic() {
    return Clinic(
      id: id, // This will be overwritten by Firestore when added
      name: name,
      category: category,
      address: address,
      workingHours: workingHours,
      contactInfo: '$phone - $email',
      phone: phone,
      email: email,
      description: description,
    );
  }
}

class ClinicSuggestionService {
  final CollectionReference suggestionsCollection =
  FirebaseFirestore.instance.collection('clinic_suggestions');

  final ClinicService clinicService = ClinicService();

  // Get all clinic suggestions
  Stream<List<ClinicSuggestion>> getSuggestions() {
    return suggestionsCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ClinicSuggestion.fromFirestore(doc))
        .toList());
  }

  // Get pending clinic suggestions
  Stream<List<ClinicSuggestion>> getPendingSuggestions() {
    return suggestionsCollection
        .where('status', isEqualTo: 'pending')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ClinicSuggestion.fromFirestore(doc))
        .toList());
  }

  // Approve a clinic suggestion
  Future<void> approveSuggestion(String id) async {
    // Get the suggestion
    DocumentSnapshot doc = await suggestionsCollection.doc(id).get();
    ClinicSuggestion suggestion = ClinicSuggestion.fromFirestore(doc);

    // Update suggestion status
    await suggestionsCollection.doc(id).update({
      'status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
    });

    // Add to clinics collection
    Clinic clinic = suggestion.toClinic();
    await clinicService.addClinic(clinic);
  }

  // Reject a clinic suggestion
  Future<void> rejectSuggestion(String id) async {
    await suggestionsCollection.doc(id).update({
      'status': 'rejected',
      'rejectedAt': FieldValue.serverTimestamp(),
    });
  }
}