// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///
/// if i only wanna import something specific from this file not the entire file
///
import '../../providers/CartProvider.dart' show CartProvider;
import '../../providers/OrdersProvider.dart';

///
/// i can give a name to the class/file i imported then use it with that name
///
import '../../widgets/Cart/CartItem.dart' as ci;
import '../../widgets/Components/NoItemsWidget.dart';
import '../../widgets/Orders/OrderButton.dart';

class CartScreen extends StatelessWidget {
    const CartScreen({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        final cartProvider   = Provider.of<CartProvider>(context);
        final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);

        return Scaffold(
            appBar: AppBar(
                title: const Text('Your Cart'),
                actions: [
                    IconButton(
                        icon: const Icon(
                            Icons.delete_forever,
                            size: 30
                        ),
                        onPressed: () {
                            cartProvider.clearCart();
                        }
                    )
                ]
            ),
            body: cartProvider.items.length == 0 
                ? NoItemsWidget('Your Cart is Empty\n click on Browse to browse Products')
                : Column(
                    children: [
                        const SizedBox(
                            height: 10
                        ),
                        ///
                        /// - the list of the items inside the cart
                        /// 
                        /// - ListView inside a Column doesn't work
                        /// 
                        /// - Expanded takes as much space left
                        ///
                        Expanded(
                            child: ListView.builder(
                                itemCount: cartProvider.items.length,
                                itemBuilder: (ctx, index) => ci.CartItem(
                                    ///
                                    /// in order for the values of the id or the other properties of the map 
                                    /// to be available, we need to change the items map to list 
                                    /// using .values.toList() to access the values in the map
                                    ///
                                    cartProvider.items.values.toList()[index].id,
                                    cartProvider.items.values.toList()[index].price,
                                    cartProvider.items.values.toList()[index].quantity,
                                    cartProvider.items.values.toList()[index].title,
                                    ///
                                    /// - to access the keys of the map to get the product id use
                                    ///   .keys.toList()
                                    /// 
                                    /// - because the key in the map is the product id that this cart item
                                    ///   belongs to 
                                    ///
                                    cartProvider.items.keys.toList()[index]
                                )
                            )
                        ),
                        ///
                        /// this is a summary card on top of the column
                        ///
                        Card(
                            elevation: 6,
                            margin: EdgeInsets.all(15),
                            child: Padding(
                                padding: EdgeInsets.all(8),
                                ///
                                /// the card contains the total amount and the order now button
                                ///
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                        Text(
                                            'Total Price: ',
                                            style: TextStyle(
                                                fontSize: 20
                                            )
                                        ),
                                        Spacer(),
                                        Chip(
                                            label: Text(
                                                '\$ ${cartProvider.totalAmount.toStringAsFixed(2)}', 
                                                style: TextStyle(
                                                    ///
                                                    /// white color, headline6 is not defined in the main file
                                                    ///
                                                    color: Theme.of(context).primaryTextTheme.headline6?.color
                                                )
                                            ),
                                            backgroundColor: Theme.of(context).primaryColor
                                        )
                                    ]
                                )
                            )
                        ),
                        SizedBox(
                            height: 10
                        ),
                        OrderButton(
                            cartProvider: cartProvider, 
                            ordersProvider: ordersProvider
                        ),
                        SizedBox(
                            height: 40
                        )
                    ]
                )
        );
    }
}
