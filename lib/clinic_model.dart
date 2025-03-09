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

  // Add a new clinic
  Future<void> addClinic(Clinic clinic) async {
    // Check if user is authenticated (optional, depending on your security rules)
    /*
    if (FirebaseAuth.instance.currentUser == null) {
      throw Exception('User must be logged in to add a clinic');
    }
    */

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

  // Fetch clinics from Firestore
  Stream<List<Clinic>> getClinics() {
    return clinicsCollection
        .orderBy('createdAt', descending: true) // Show newest first
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Clinic.fromFirestore(doc)).toList());
  }

  // Update a clinic
  Future<void> updateClinic(String id, Map<String, dynamic> data) async {
    await clinicsCollection.doc(id).update(data);
  }

  // Delete a clinic
  Future<void> deleteClinic(String id) async {
    await clinicsCollection.doc(id).delete();
  }
}