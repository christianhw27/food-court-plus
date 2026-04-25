import 'food_model.dart';

class CartItemModel {
  final FoodModel food;
  int quantity;

  CartItemModel({required this.food, this.quantity = 1});

  double get totalPrice => food.price * quantity;
}
