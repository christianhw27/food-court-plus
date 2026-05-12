import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String buyerUid;
  final String buyerName;
  final String buyerPhone;
  final String stallId;
  final String stallName;
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double serviceFee;
  final double totalAmount;
  final String status;
  final String paymentMethod;
  final DateTime createdAt;
  final String? qrString;
  final String? transactionId;

  OrderModel({
    required this.id,
    required this.buyerUid,
    required this.buyerName,
    required this.buyerPhone,
    required this.stallId,
    required this.stallName,
    required this.items,
    required this.subtotal,
    required this.serviceFee,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
    this.qrString,
    this.transactionId,
  });

  Map<String, dynamic> toMap() {
    return {
      'buyerUid': buyerUid,
      'buyerName': buyerName,
      'buyerPhone': buyerPhone,
      'stallId': stallId,
      'stallName': stallName,
      'items': items,
      'subtotal': subtotal,
      'serviceFee': serviceFee,
      'totalAmount': totalAmount,
      'status': status,
      'paymentMethod': paymentMethod,
      'createdAt': Timestamp.fromDate(createdAt),
      'qrString': qrString,
      'transactionId': transactionId,
    };
  }

  factory OrderModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      buyerUid: data['buyerUid'] ?? '',
      buyerName: data['buyerName'] ?? 'Pembeli',
      buyerPhone: data['buyerPhone'] ?? '',
      stallId: data['stallId'] ?? '',
      stallName: data['stallName'] ?? '',
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      serviceFee: (data['serviceFee'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      status: data['status'] ?? 'Menunggu Pembayaran',
      paymentMethod: data['paymentMethod'] ?? 'QRIS',
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
      qrString: data['qrString'],
      transactionId: data['transactionId'],
    );
  }
}
