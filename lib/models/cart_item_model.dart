import 'food_model.dart';

class CartItemModel {
  final FoodModel food;
  final String stallName;
  int quantity;

  CartItemModel({required this.food, required this.stallName, this.quantity = 1});

  double get totalPrice => food.price * quantity;
}
