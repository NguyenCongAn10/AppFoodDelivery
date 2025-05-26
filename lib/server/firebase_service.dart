import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_apps/model/cartItem.dart';
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
        FirebaseAuth.instance.currentUser?.updateDisplayName(name);
        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception('Error creating user: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<User?> getCurrentUser() async {
    return await _firebaseAuth.currentUser;
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

  Future<List<CartItem>> getCartItem() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) throw Exception("Người dùng chưa đăng nhập");
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("cart")
          .get();
      return snapshot.docs
          .map((doc) => CartItem.fromFireStore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception("Loi khi lay san pham trong gio hang: $e");
    }
  }

  Future<void> addToCart(CartItem newItem) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) throw Exception("Người dùng chưa đăng nhập");

    try {
      final cartRef = FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("cart")
          .doc(newItem.id);

      final doc = await cartRef.get();

      if (doc.exists) {
        final data = doc.data()!;
        final oldQty = int.tryParse(data["quantity"].toString()) ?? 1;
        final newQty = oldQty + int.parse(newItem.quantity);

        final unitPrice =
            (double.tryParse(newItem.price)! / int.parse(newItem.quantity));
        final newPrice = (unitPrice * newQty).toStringAsFixed(2);

        await cartRef.set({
          ...newItem.toMap(),
          "quantity": newQty.toString(),
          "price": newPrice,
        });
      } else {
        await cartRef.set(newItem.toMap());
      }
    } catch (e) {
      throw Exception("Lỗi khi thêm sản phẩm vào giỏ hàng: $e");
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) throw Exception("Người dùng chưa đăng nhập");
    try {
      final cartRef = FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("cart")
          .doc(cartItemId);
      await cartRef.delete();
    } catch (e) {
      throw Exception("Lỗi khi xóa sản phẩm trong giỏ hàng: $e");
    }
  }

  Future<void> updateCartItem(String cartItemId, String newquantity) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) throw Exception("Người dùng chưa đăng nhập");
    try {
      final cartRef = FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("cart")
          .doc(cartItemId);
      await cartRef.update({
        "quantity": newquantity,
      });
    } catch (e) {
      throw Exception("Lỗi khi cập nhật số lượng sản phẩm trong giỏ hàng: $e");
    }
  }
}
