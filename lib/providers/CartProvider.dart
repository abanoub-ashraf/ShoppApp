import 'package:flutter/material.dart';

import '../models/CartItemModel.dart';

class CartProvider with ChangeNotifier {
    ///
    /// the string is the id of the product that the cart item belongs to 
    ///
    Map<String, CartItemModel> _items = {};

    Map<String, CartItemModel> get items {
        return { ..._items };
    }

    ///
    /// the number of the cart items inside the cart
    ///
    int get itemsCount {
        return _items.length;
    }

    ///
    /// the quantity of products inside the single cart item
    ///
    int get itemsQuantity {
        var total = 0;
        _items.forEach((key, cartItem) {
            total += cartItem.quantity;
        });
        return total;
    }

    ///
    /// the total price of the items in the cart
    ///
    double get totalAmount {
        var total = 0.0;
        _items.forEach((key, cartItem) {
            total += cartItem.price * cartItem.quantity;
        });
        return total;
    }

    ///
    /// add items to the cart if they weren't already there,
    /// if they were then only increase their quantity
    ///
    void addItems(String productId, double price, String title) {
        if (_items.containsKey(productId)) {
            _items.update(
                productId, 
                (existingCartItem) => CartItemModel(
                    id: existingCartItem.id,
                    title: existingCartItem.title,
                    price: existingCartItem.price,
                    quantity: existingCartItem.quantity + 1
                )
            );
        } else {
            _items.putIfAbsent(
                productId, 
                () => CartItemModel(
                    id: DateTime.now().toString(), 
                    title: title, 
                    price: price, 
                    quantity: 1
                )
            );
        }

        notifyListeners();
    }

    ///
    /// remove item from the cart by its product id cause that product id belongs to the cart
    ///
    void removeItem(String productId) {
        _items.remove(productId);

        notifyListeners();
    }

    ///
    /// remove a single quantity of the cart item from the cart, 
    /// not the entire cart item
    ///
    void removeSingleItem(String productId) {
        ///
        /// if we don't have that product id in the items then do nothing
        ///
        if (!_items.containsKey(productId)) {
            return;
        }

        ///
        /// - if the quantity of the cart item is more than one then reduce it by one
        /// 
        /// - if it's just one then remove the cart item
        ///
        if (_items[productId]!.quantity > 1) {
            _items.update(
                productId, 
                (existingCartItem) => CartItemModel( 
                    id: existingCartItem.id, 
                    title: existingCartItem.title, 
                    quantity: existingCartItem.quantity - 1, 
                    price: existingCartItem.price
                )
            );
        } else {
            _items.remove(productId);
        }

        notifyListeners();
    }

    ///
    /// to clear the cart after clicking on the order now button
    ///
    void clearCart() {
        _items = {};
        notifyListeners();
    }
}
