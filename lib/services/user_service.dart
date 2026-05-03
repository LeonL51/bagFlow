import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore;

  UserService({FirebaseFirestore? firestore})
    : _firestore = firestore 
    ?? FirebaseFirestore.instance;

  Future<void> createUserProfile({
    required String uid,
    required String fullName,
    required String email,
  }) async {
    // Save user data 
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'fullName': fullName.trim(),
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Fetches user from Firestore 
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  Future<void> createUserProfileIfNotExists({
    required String uid,
    required String fullName,
    required String email,
  }) async {
    final docRef = _firestore.collection('users').doc(uid);
    final doc = await docRef.get();

    // If there is no user profile, create one 
    if (!doc.exists) {
      await docRef.set({
        'uid': uid,
        'fullName': fullName.trim(),
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    required String fullName,
    String? photoUrl,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'fullName': fullName.trim(),
      'photoUrl': photoUrl?.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
