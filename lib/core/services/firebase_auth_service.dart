import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  // ── Phone Auth ──────────────────────────────────────────────────────────────

  /// Format số điện thoại sang E.164 (+84...)
  String formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\s|-'), '');
    if (cleaned.startsWith('+')) return cleaned;
    if (cleaned.startsWith('0')) return '+84${cleaned.substring(1)}';
    return '+84$cleaned';
  }

  /// Gửi SMS OTP qua Firebase Phone Auth
  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
    required void Function(PhoneAuthCredential credential) onAutoVerified,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) {
        onAutoVerified(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Phone verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  /// Verify mã SMS — link vào user hiện tại hoặc sign in mới
  Future<void> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
    PhoneAuthCredential? credential,
  }) async {
    final phoneCredential = credential ??
        PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );

    final user = _auth.currentUser;
    if (user != null) {
      try {
        await user.linkWithCredential(phoneCredential);
      } on FirebaseAuthException catch (e) {
        // Nếu phone đã được link → sign in trực tiếp
        if (e.code == 'provider-already-linked' ||
            e.code == 'credential-already-in-use') {
          await _auth.signInWithCredential(phoneCredential);
        } else {
          throw Exception('Phone verification failed: ${e.message}');
        }
      }
    } else {
      await _auth.signInWithCredential(phoneCredential);
    }
  }

  // ────────────────────────────────────────────────────────────────────────────

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
