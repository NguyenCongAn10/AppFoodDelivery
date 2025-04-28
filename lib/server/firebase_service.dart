import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/category.dart';

class FirebaseService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<User?> createUser(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        await _firebaseFirestore.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "email": email,
          "name": name,
          "createdAt": FieldValue.serverTimestamp(),
        });
        return user; // Return the created user
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception('Error creating user: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection("categoires").get();
      if (snapshot.docs.isEmpty) {
        print("khong co danh muc nao");
        return [];
      }
      return snapshot.docs
          .map((doc) => Category.fromFireStore(doc.data()))
          .toList();
    } catch (e) {
      print("loi khi lay danh muc $e");
      return [];
    }
  }
}
