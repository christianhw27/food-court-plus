import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../models/food_model.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  List<CartItemModel> items = [];

  void addToCart(FoodModel food, String stallName, {int quantity = 1}) {

    final existingIndex = items.indexWhere((item) => item.food.id == food.id);
    if (existingIndex >= 0) {
      items[existingIndex].quantity += quantity;
    } else {
      items.add(CartItemModel(food: food, stallName: stallName, quantity: quantity));
    }
    notifyListeners();
  }

  void updateQuantity(String foodId, int newQuantity) {
    if (newQuantity <= 0) {
      items.removeWhere((item) => item.food.id == foodId);
    } else {
      final existingIndex = items.indexWhere((item) => item.food.id == foodId);
      if (existingIndex >= 0) {
        items[existingIndex].quantity = newQuantity;
      }
    }
    notifyListeners();
  }

  void clearCartByStall(String stallId) {
    items.removeWhere((item) => item.food.stallId == stallId);
    notifyListeners();
  }

  void clearCart() {
    items.clear();
    notifyListeners();
  }

  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);
}
