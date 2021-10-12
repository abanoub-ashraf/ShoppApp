// ignore_for_file: file_names, library_prefixes

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as NetworkManager;
import 'package:pretty_json/pretty_json.dart';
import 'package:print_color/print_color.dart';
import 'package:shop_app/models/OrderItemModel.dart';
import 'package:shop_app/models/CartItemModel.dart';
import 'package:shop_app/utils/AppConstants.dart';

class OrdersProvider with ChangeNotifier {
    List<OrderItemModel> _orders = [];

    final String authToken;

    OrdersProvider(this.authToken, this._orders);

    List<OrderItemModel> get orders {
        return [..._orders];
    }    

    ///
    /// fetch data from the server and fill the _orders list with that data
    ///
    Future<void> fetchOrdersAndSetOrders() async {
        final url = Uri.parse('${AppConstants.firebaseURL}/orders.json?auth=$authToken');

        try {
            final response = await NetworkManager.get(url);

            Print.yellow('------------- fetched orders --------------');
            printPrettyJson(json.decode(response.body));
            Print.yellow('-------------------------------------------');
            
            final List<OrderItemModel> loadedOrders = [];

            final extractedData = json.decode(response.body) as Map<String, dynamic>?;

            if (extractedData == null) {
                throw 'There is no Orders right now!';
            }
            
            extractedData.forEach((orderId, orderData) {
                loadedOrders.add(
                    OrderItemModel(
                        id: orderId,
                        amount: orderData['amount'],
                        dateTime: DateTime.parse(orderData['dateTime']),
                        products: (orderData['products'] as List<dynamic>).map(
                            ///
                            /// map() converts the list of products into a list of cart items
                            ///
                            (item) => CartItemModel(
                                id: item['id'], 
                                title: item['title'], 
                                quantity: item['quantity'],
                                price: item['price']
                            )
                        ).toList()
                    )
                );
            });

            ///
            /// reversed to put the recent orders on top
            ///
            _orders = loadedOrders.reversed.toList();

            notifyListeners();
        } catch (error) {
            Print.red(error);
            throw 'Error while fetching products';
        }
    }

    ///
    /// - add all the content of the cart into one order
    /// 
    /// - insert at index 0, meant the most recent orders are gonna be at the beginning of the list
    ///
    Future<void> addOrder(List<CartItemModel> cartProducts, double total) async {
        final url = Uri.parse('${AppConstants.firebaseURL}/orders.json?auth=$authToken');

        final timestamp = DateTime.now();

        try {
            final response = await NetworkManager.post(
                url,
                body: json.encode({
                    'amount': total,
                    'dateTime': timestamp.toIso8601String(),
                    'products': cartProducts.map(
                        (cartProduct) => {
                            'id': cartProduct.id,
                            'title': cartProduct.title,
                            'quantity': cartProduct.quantity,
                            'price': cartProduct.price
                        }
                    ).toList()
                })
            );

            Print.magenta('--------------------added new order --------------------');
            printPrettyJson(json.decode(response.body));
            Print.magenta('----------------------------------------------------------');

            _orders.insert(
                0, 
                OrderItemModel(
                    id: json.decode(response.body)['name'],
                    amount: total, 
                    products: cartProducts, 
                    dateTime: DateTime.now()
                )
            );

            notifyListeners();
        } catch (error) {
            Print.red(error);
            throw 'Error while creating a new order';
        }
    }
}
