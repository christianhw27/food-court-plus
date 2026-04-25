import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createOrder(OrderModel order) async {
    final docRef = _firestore.collection('orders').doc();
    await docRef.set({
      ...order.toMap(),
      'id': docRef.id,
    });
    return docRef.id;
  }

  Stream<List<OrderModel>> getBuyerOrders(String buyerUid) {
    return _firestore
        .collection('orders')
        .where('buyerUid', isEqualTo: buyerUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => OrderModel.fromDocument(d)).toList());
  }

  Stream<List<OrderModel>> getStallOrders(String stallId) {
    return _firestore
        .collection('orders')
        .where('stallId', isEqualTo: stallId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => OrderModel.fromDocument(d)).toList());
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _firestore.collection('orders').doc(orderId).update({'status': newStatus});
  }
}
