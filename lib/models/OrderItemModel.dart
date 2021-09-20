import './CartItemModel.dart';

class OrderItemModel {
    final String id;
    final double amount;
    final List<CartItemModel> products;
    final DateTime dateTime;

    OrderItemModel({
        required this.id, 
        required this.amount, 
        required this.products, 
        required this.dateTime
    });
}