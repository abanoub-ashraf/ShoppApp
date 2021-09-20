import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/OrderItemModel.dart';

class OrderItem extends StatefulWidget {
    final OrderItemModel orderModel;

    OrderItem(this.orderModel);

    @override
    _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
    var _expanded = false;

    @override
    Widget build(BuildContext context) {
        return Card(
            elevation: 8,
            shadowColor: Theme.of(context).primaryColor,
            margin: EdgeInsets.all(10),
            child: Column(
                children: [
                    ListTile(
                        contentPadding: EdgeInsets.all(6),
                        title: Text(
                            'Total Cost:  \$ ${widget.orderModel.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 18, 
                                color: Theme.of(context).colorScheme.secondary
                            )
                        ),
                        subtitle: Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                                'Ordered At: ${DateFormat('dd-MM-yyyy hh:mm a').format(widget.orderModel.dateTime)}',
                                style: TextStyle(fontSize: 15)
                            )
                        ),
                        ///
                        /// this button is gonna expand more details about this order item
                        /// we currently at
                        ///
                        trailing: IconButton(
                            icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                            onPressed: () {
                                setState(() {
                                    _expanded = !_expanded;
                                });
                            }
                        )
                    ),
                    if (_expanded)
                        ///
                        /// we gonna make this order item card expandable by adding more ui to it
                        /// if this bool variable is true
                        ///
                        Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 4, 
                                horizontal: 15
                            ),
                            height: min(
                                widget.orderModel.products.length * 20.0 + 30, 
                                100
                            ),
                            child: ListView(
                                children: widget.orderModel.products
                                    .map(
                                        (product) => Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                                Text(
                                                    product.title, 
                                                    style: TextStyle(
                                                        fontSize: 16, 
                                                        fontWeight: FontWeight.w300
                                                    )
                                                ),
                                                Text(
                                                    '${product.quantity}x \$ ${product.price}',
                                                    style: TextStyle(
                                                        fontSize: 16, 
                                                        color: Theme.of(context).colorScheme.secondary
                                                    )
                                                )
                                            ]
                                        )
                                    ).toList()
                                
                            )
                        )
                ]
            )
        );
    }
}