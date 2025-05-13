import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_apps/model/product.dart';
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
        return user;
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

  Future<List<Product>> getProductByCategory(String id) async {
    try {
      print("Truy vấn Firestore: categories/$id/product");
      final snapshot = await FirebaseFirestore.instance
          .collection("categoires")
          .doc(id)
          .collection("product")
          .get();
      final products = snapshot.docs
          .map((doc) => Product.fromFireStore(doc.data()))
          .toList();
      return products;
    } catch (e) {
      throw Exception("Lỗi khi lấy sản phẩm trong $id: $e");
    }
  }

  Future<void> updateFavoriteStatus(
      String categoryId, String productId, bool isCurrentlyFavorite) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final productRef = FirebaseFirestore.instance
        .collection("categoires")
        .doc(categoryId)
        .collection("product")
        .doc(productId);

    try {
      await productRef.update({
        'isFavorite': isCurrentlyFavorite
            ? FieldValue.arrayRemove([userId])
            : FieldValue.arrayUnion([userId])
      });
    } catch (e) {
      throw Exception("Lỗi khi cập nhật isFavorite: $e");
    }
  }
}
