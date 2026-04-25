import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool needsPasswordSetup(User? user) {
    if (user == null) return false;
    return !user.providerData.any((provider) => provider.providerId == 'password');
  }

  Future<bool> needsPasswordSetupForCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    final refreshedUser = _auth.currentUser;
    return needsPasswordSetup(refreshedUser);
  }

  String mapFirebaseAuthError(
    Object error, {
    String fallback = 'Terjadi kesalahan. Coba lagi.',
  }) {
    if (error is! FirebaseAuthException) return fallback;

    switch (error.code) {
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun ini dinonaktifkan.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Coba login atau reset password.';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 8 karakter.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah. Cek jaringan kamu.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba beberapa saat lagi.';
      case 'popup-closed-by-user':
      case 'sign_in_canceled':
        return 'Login dibatalkan.';
      case 'account-exists-with-different-credential':
        return 'Email ini sudah terdaftar dengan metode login lain.';
      case 'provider-already-linked':
        return 'Password untuk akun ini sebenarnya sudah terhubung.';
      case 'credential-already-in-use':
        return 'Credential sudah digunakan akun lain. Coba login dengan email+password.';
      case 'requires-recent-login':
        return 'Untuk keamanan, login ulang dulu lalu coba set password lagi.';
      case 'operation-not-allowed':
        return 'Metode login ini belum diaktifkan di Firebase Console.';
      default:
        return error.message?.isNotEmpty == true ? error.message! : fallback;
    }
  }

  // Stream auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user data from Firestore
  Future<UserModel?> get currentUserData async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (doc.exists) {
        return UserModel.fromDocument(doc);
      }
    }
    return null;
  }

  // Register with email, password, name, and role
  Future<UserCredential?> registerUser({
    required String email,
    required String password,
    required String name,
    String role = 'buyer',
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user info to Firestore
      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        role: role,
      );

      await _firestore.collection('users').doc(newUser.uid).set(newUser.toMap());

      return userCredential;
    } catch (e) {
      print("Error during registration: $e");
      rethrow;
    }
  }

  // Sign In
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print("Error during sign in: $e");
      rethrow;
    }
  }

  // Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("Error sending password reset email: $e");
      rethrow;
    }
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: '1050318985848-hndcespm3mfm2637c2iko9thfl81cg3k.apps.googleusercontent.com',
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Save user to Firestore if it's the first time
      DocumentSnapshot doc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      if (!doc.exists) {
        UserModel newUser = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          name: userCredential.user!.displayName ?? 'Google User',
          role: 'buyer', // Default role
        );
        await _firestore.collection('users').doc(newUser.uid).set(newUser.toMap());
      }

      return userCredential;
    } catch (e) {
      print("Error during Google Sign In: $e");
      rethrow;
    }
  }

  Future<void> setupPasswordForCurrentUser(String password) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'User belum login.',
      );
    }

    final email = user.email;
    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-email',
        message: 'Akun Google tidak memiliki email yang valid.',
      );
    }

    final credential = EmailAuthProvider.credential(email: email, password: password);
    final hasPasswordProvider = user.providerData.any((provider) => provider.providerId == 'password');

    if (hasPasswordProvider) {
      await user.updatePassword(password);
    } else {
      await user.linkWithCredential(credential);
    }

    await user.reload();
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- ADMIN FUNCTIONS ---

  // Get all users (for Admin Dashboard)
  Stream<List<UserModel>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromDocument(doc)).toList();
    });
  }

  // Update user role
  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      await _firestore.collection('users').doc(uid).update({'role': newRole});
    } catch (e) {
      print("Error updating role: $e");
      rethrow;
    }
  }
}
