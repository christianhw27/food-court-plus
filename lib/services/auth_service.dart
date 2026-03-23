import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
