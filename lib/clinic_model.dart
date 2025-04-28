import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Clinic {
  String id;
  String name;
  String category;
  String address;
  String workingHours;
  String contactInfo;
  String phone;
  String email;
  String? description;

  Clinic({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.workingHours,
    required this.contactInfo,
    required this.phone,
    required this.email,
    this.description,
  });

  factory Clinic.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Clinic(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      address: data['address'] ?? '',
      workingHours: data['workingHours'] ?? '',
      contactInfo: data['contactInfo'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      description: data['description'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'address': address,
      'workingHours': workingHours,
      'contactInfo': contactInfo,
      'phone': phone,
      'email': email,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(), // Add timestamp
      'createdBy': FirebaseAuth.instance.currentUser?.uid, // Add user ID if authenticated
    };
  }
}

class ClinicService {
  final CollectionReference clinicsCollection =
  FirebaseFirestore.instance.collection('clinics');

  // Check if user is admin
  bool _isUserAdmin() {
    final user = FirebaseAuth.instance.currentUser;
    return user != null && user.email == "admin4@gmail.com";
  }

  // Add a new clinic (only admin)
  Future<void> addClinic(Clinic clinic) async {
    // Check if user is admin
    if (!_isUserAdmin()) {
      throw Exception('فقط المشرف يمكنه إضافة عيادات');
    }

    try {
      await clinicsCollection.add(clinic.toFirestore());
    } catch (e) {
      // Provide more detail on Firestore errors
      if (e is FirebaseException) {
        throw '${e.code}: ${e.message}';
      }
      throw e;
    }
  }

  // Fetch clinics from Firestore (available to all users)
  Stream<List<Clinic>> getClinics() {
    return clinicsCollection
        .orderBy('createdAt', descending: true) // Show newest first
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Clinic.fromFirestore(doc)).toList());
  }

  // Update a clinic (only admin)
  Future<void> updateClinic(String id, Map<String, dynamic> data) async {
    // Check if user is admin
    if (!_isUserAdmin()) {
      throw Exception('فقط المشرف يمكنه تعديل العيادات');
    }

    await clinicsCollection.doc(id).update(data);
  }

  // Delete a clinic (only admin)
  Future<void> deleteClinic(String id) async {
    // Check if user is admin
    if (!_isUserAdmin()) {
      throw Exception('فقط المشرف يمكنه حذف العيادات');
    }

    await clinicsCollection.doc(id).delete();
  }
}