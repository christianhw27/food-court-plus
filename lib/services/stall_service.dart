import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stall_model.dart';
import '../models/food_model.dart';

class StallService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =============================================
  //  STALL CRUD
  // =============================================

  /// Cek apakah user sudah punya stan di Firestore
  Future<StallModel?> getStallByOwner(String ownerUid) async {
    final query = await _firestore
        .collection('stalls')
        .where('ownerUid', isEqualTo: ownerUid)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return StallModel.fromDocument(query.docs.first);
  }

  /// Buat stan baru di Firestore
  Future<StallModel> createStall({
    required String ownerUid,
    required String name,
    required String description,
    required String category,
    required String location,
  }) async {
    final docRef = _firestore.collection('stalls').doc();
    final stall = StallModel(
      id: docRef.id,
      ownerUid: ownerUid,
      name: name,
      description: description,
      category: category,
      location: location,
      isOpen: true,
    );
    await docRef.set(stall.toMap());
    return stall;
  }

  /// Update data profil stan
  Future<void> updateStall(String stallId, Map<String, dynamic> data) async {
    await _firestore.collection('stalls').doc(stallId).update(data);
  }

  /// Toggle status buka/tutup stan
  Future<void> toggleStallStatus(String stallId, bool isOpen) async {
    await _firestore.collection('stalls').doc(stallId).update({'isOpen': isOpen});
  }

  /// Stream semua stan (untuk halaman Buyer)
  Stream<List<StallModel>> getAllStalls() {
    return _firestore
        .collection('stalls')
        .snapshots()
        .map((snap) => snap.docs.map((d) => StallModel.fromDocument(d)).toList());
  }

  // =============================================
  //  FOOD / MENU CRUD
  // =============================================

  /// Stream semua menu dari sebuah stan
  Stream<List<FoodModel>> getFoodByStall(String stallId) {
    return _firestore
        .collection('foods')
        .where('stallId', isEqualTo: stallId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => FoodModel.fromDocument(d)).toList());
  }

  /// Tambah item menu baru — returns the new document ID
  Future<String> addFood(FoodModel food) async {
    final docRef = _firestore.collection('foods').doc();
    await docRef.set({...food.toMap(), 'id': docRef.id});
    return docRef.id;
  }

  /// Update item menu
  Future<void> updateFood(String foodId, Map<String, dynamic> data) async {
    await _firestore.collection('foods').doc(foodId).update(data);
  }

  /// Hapus item menu
  Future<void> deleteFood(String foodId) async {
    await _firestore.collection('foods').doc(foodId).delete();
  }

  /// Toggle ketersediaan menu
  Future<void> toggleFoodAvailability(String foodId, bool isAvailable) async {
    await _firestore.collection('foods').doc(foodId).update({'isAvailable': isAvailable});
  }

  /// Stream semua menu yang tersedia (untuk halaman Home Buyer)
  Stream<List<FoodModel>> getAllFoods() {
    return _firestore
        .collection('foods')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => FoodModel.fromDocument(d)).toList());
  }

  /// Stream semua menu tanpa filter (untuk halaman Saved)
  Stream<List<FoodModel>> getAllFoodsUnfiltered() {
    return _firestore
        .collection('foods')
        .snapshots()
        .map((snap) => snap.docs.map((d) => FoodModel.fromDocument(d)).toList());
  }
}
