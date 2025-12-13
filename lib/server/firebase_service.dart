import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_apps/model/cartItem.dart';
import 'package:delivery_apps/model/product.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/category.dart';

class FirebaseService {
  FirebaseAuth get _firebaseAuth => FirebaseAuth.instance;
  FirebaseFirestore get _firebaseFirestore => FirebaseFirestore.instance;

  Future<bool> isUsernameTaken(String username) async {
    final query = await _firebaseFirestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<User?> createUser(String email, String password, String username,
      String name, String phone) async {
    try {
      if (await isUsernameTaken(username)) {
        throw Exception('Username đã tồn tại, vui lòng chọn tên khác');
      }

      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        await _firebaseFirestore.collection('users').doc(user.uid).set({
          'id': user.uid,
          'email': email,
          'username': username,
          'name': name,
          "phone": phone,
          "password": password,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await user.updateDisplayName(name);
        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception('Lỗi tạo user: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<User?> getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  Future<List<Category>> getCategories() async {
    try {
      final snapshot = await _firebaseFirestore.collection("categories").get();
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
      final snapshot = await _firebaseFirestore
          .collection("categories")
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

  Future<List<Product>> getFavoriteProducts() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      print("Không có người dùng đăng nhập tại ${DateTime.now()}");
      return [];
    }

    try {
      print("Bắt đầu truy vấn danh mục tại ${DateTime.now()}");
      final categoriesSnapshot =
          await _firebaseFirestore.collection("categories").get();
      final List<Product> favoriteProducts = [];

      for (var categoryDoc in categoriesSnapshot.docs) {
        final categoryId = categoryDoc.id;
        final productsSnapshot = await _firebaseFirestore
            .collection("categories")
            .doc(categoryId)
            .collection("product")
            .where('isFavorite', arrayContains: uid)
            .get();

        final products = productsSnapshot.docs.map((doc) {
          final data = {
            ...doc.data(),
            'categoryId': categoryId,
            'id': doc.id,
          };
          return Product.fromFireStore(data);
        }).toList();
        favoriteProducts.addAll(products);
      }

      return favoriteProducts;
    } catch (e) {
      print(
          "Lỗi khi lấy sản phẩm yêu thích cho UID $uid tại ${DateTime.now()}: $e");
      return [];
    }
  }

  Future<void> updateFavoriteStatus(
      String categoryId, String productId, bool isCurrentlyFavorite) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final productRef = _firebaseFirestore
        .collection("categories")
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
      final snapshot = await _firebaseFirestore
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
      final cartRef = _firebaseFirestore
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
      final cartRef = _firebaseFirestore
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
      final cartRef = _firebaseFirestore
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

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('Người dùng chưa đăng nhập');
    final email = user.email;
    if (email == null) throw Exception('Email người dùng không tồn tại');

    try {
      final credential =
          EmailAuthProvider.credential(email: email, password: currentPassword);
      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPassword);

      await _firebaseFirestore.collection('users').doc(user.uid).update({
        'password': newPassword,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Mật khẩu hiện tại không đúng');
      } else if (e.code == 'weak-password') {
        throw Exception('Mật khẩu mới quá yếu');
      } else {
        throw Exception('Lỗi xác thực: ${e.message}');
      }
    } catch (e) {
      throw Exception('Lỗi khi cập nhật mật khẩu: $e');
    }
  }
}
