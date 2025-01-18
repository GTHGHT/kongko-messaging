import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreServices {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<void> addUserDoc(
      {required String email, required String username}) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userRef = _firestore.collection('users').doc(user.uid);
      await userRef.set({
        'uid': user.uid,
        'username': username,
        'image': "default_profile.png",
        'email': email,
      });
    }
  }

  static Future<void> changeUserName({required String name}) async {}


  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserPersonalChats() {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection("users")
          .doc(user.uid)
          .collection("personalChats")
          .snapshots();
    } else {
      throw Exception("Gagal Menerima Daftar Group");
    }
  }
}