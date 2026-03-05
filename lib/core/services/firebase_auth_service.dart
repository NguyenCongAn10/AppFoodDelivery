import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  Future<User?> createUser(
    String email,
    String password,
    String username,
    String name,
    String phone,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception('Lỗi tạo user: ${e.message}');
    }
  }

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<({User user, bool isNewUser})?>  signInWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user!;
    final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

    return (user: user, isNewUser: isNewUser);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Người dùng chưa đăng nhập');
    final email = user.email;
    if (email == null) throw Exception('Email người dùng không tồn tại');

    try {
      final cred = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Mật khẩu hiện tại không đúng');
      } else if (e.code == 'weak-password') {
        throw Exception('Mật khẩu mới quá yếu');
      } else {
        throw Exception('Lỗi xác thực: ${e.message}');
      }
    }
  }
}
