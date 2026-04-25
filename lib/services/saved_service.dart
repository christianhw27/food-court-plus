import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _currentUid() {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw FirebaseException(
        plugin: 'firebase_auth',
        message: 'User belum login.',
      );
    }
    return uid;
  }

  DocumentReference<Map<String, dynamic>> _userRef(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  Stream<Set<String>> savedFoodIdsStream() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) {
        return Stream.value(<String>{});
      }

      return _userRef(user.uid).snapshots().map((snapshot) {
        final data = snapshot.data();
        final ids = (data?['savedFoodIds'] as List<dynamic>? ?? [])
            .map((id) => id.toString())
            .toSet();
        return ids;
      });
    }).asBroadcastStream();
  }

  Stream<Set<String>> savedStallIdsStream() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) {
        return Stream.value(<String>{});
      }

      return _userRef(user.uid).snapshots().map((snapshot) {
        final data = snapshot.data();
        final ids = (data?['savedStallIds'] as List<dynamic>? ?? [])
            .map((id) => id.toString())
            .toSet();
        return ids;
      });
    }).asBroadcastStream();
  }

  Future<void> toggleFoodSaved(String foodId) async {
    final uid = _currentUid();
    final userRef = _userRef(uid);
    final doc = await userRef.get();
    final data = doc.data() ?? <String, dynamic>{};
    final current = (data['savedFoodIds'] as List<dynamic>? ?? []).map((e) => e.toString()).toSet();
    final isSaved = current.contains(foodId);

    if (isSaved) {
      await userRef.set({
        'savedFoodIds': FieldValue.arrayRemove([foodId]),
      }, SetOptions(merge: true));
    } else {
      await userRef.set({
        'savedFoodIds': FieldValue.arrayUnion([foodId]),
      }, SetOptions(merge: true));
    }
  }

  Future<void> toggleStallSaved(String stallId) async {
    final uid = _currentUid();
    final userRef = _userRef(uid);
    final doc = await userRef.get();
    final data = doc.data() ?? <String, dynamic>{};
    final current = (data['savedStallIds'] as List<dynamic>? ?? []).map((e) => e.toString()).toSet();
    final isSaved = current.contains(stallId);

    if (isSaved) {
      await userRef.set({
        'savedStallIds': FieldValue.arrayRemove([stallId]),
      }, SetOptions(merge: true));
    } else {
      await userRef.set({
        'savedStallIds': FieldValue.arrayUnion([stallId]),
      }, SetOptions(merge: true));
    }
  }
}
