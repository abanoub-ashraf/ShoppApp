import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/CartProvider.dart';

class CartItem extends StatelessWidget {
    final String? id;
    final double? price;
    final int? quantity;
    final String? title;
    final String productId;

    CartItem(
        this.id, 
        this.price, 
        this.quantity, 
        this.title, 
        this.productId
    );

    @override
    Widget build(BuildContext context) {
        final cartProvider = Provider.of<CartProvider>(context, listen: false);

        ///
        /// this allows us to swipe to delete the entire cart item widget
        /// we're currently in
        ///
        return Dismissible(
            ///
            /// delete the cart item by its product id from the map inside the cart provider
            /// when we swipe from right to left
            ///
            onDismissed: (direction) {
                cartProvider.removeItem(productId);
            },
            ///
            /// - tell the user to confirm the delete process they wanna make by showing an 
            ///   alert dialog to them 
            ///
            confirmDismiss: (direction) {
                return showDialog(
                    context: context, 
                    builder: (ctx) => AlertDialog(
                        elevation: 8,
                        title: Text(
                            'Are you sure?',
                            textAlign: TextAlign.center
                        ),
                        content: Text(
                            'Do you want to remove the Item from the Cart?', 
                            textAlign: TextAlign.center
                        ),
                        actions: [
                            Container(
                                alignment: Alignment.bottomCenter,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                        SizedBox(width: 2),
                                        TextButton(
                                            child: Text('Yes I\'m sure'),
                                            onPressed: () {
                                                Navigator.of(ctx).pop(true);
                                            } 
                                        ),
                                        TextButton(
                                            child: Text('No, Never mind'),
                                            onPressed: () {
                                                Navigator.of(ctx).pop(false);
                                            }
                                        ),
                                        SizedBox(width: 2)
                                    ]
                                )
                            )
                        ]
                    )
                );
            },
            ///
            /// to specify the swipe direction from right to left only
            ///
            direction: DismissDirection.endToStart,
            ///
            /// this key is required with Dismissible
            ///
            key: ValueKey(id),
            ///
            /// this is the widget that appears behind the cart item when the swiping starts
            ///
            background: Container(
                ///
                /// this errorColor is used for errors
                ///
                child: Icon(
                    Icons.delete, 
                    color: Colors.white, 
                    size: 40
                ),
                color: Theme.of(context).errorColor,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20),
                margin: EdgeInsets.symmetric(
                    horizontal: 15, 
                    vertical: 6
                )
            ),
            child: Card(
                shadowColor: Theme.of(context).primaryColor,
                elevation: 10,
                margin: EdgeInsets.symmetric(
                    horizontal: 15, 
                    vertical: 6
                ),
                child: Padding(
                    padding: EdgeInsets.all(8),
                    child: ListTile(
                        leading: Container(
                            width: 75, 
                            height: 200, 
                            child: CircleAvatar(
                                child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: FittedBox(
                                        child: Text('\$ $price')
                                    )
                                )
                            )
                        ),
                        title: Text(
                            title ?? 'Nothing',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor, 
                                fontSize: 18
                            )
                        ),
                        subtitle: Text(
                            'Total: \$ ${(price ?? 0) * (quantity ?? 0)}'
                        ),
                        trailing: Text(
                            '$quantity x'
                        )
                    )
                )
            ),
        );
    }
}