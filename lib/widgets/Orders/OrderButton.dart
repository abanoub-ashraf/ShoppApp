import 'package:flutter/material.dart';

import '../../providers/CartProvider.dart';
import '../../providers/OrdersProvider.dart';

import '../../utils/AppConstants.dart';

class OrderButton extends StatefulWidget {
    final CartProvider cartProvider;
    final OrdersProvider ordersProvider;
    
    const OrderButton({
        Key? key,
        required this.cartProvider,
        required this.ordersProvider,
    }) : super(key: key);

    @override
    _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
    var _isLoading = false;

    @override
    Widget build(BuildContext context) {
        return ElevatedButton(
            child: _isLoading 
                ? CircularProgressIndicator() 
                : Text('ORDER NOW'),
            style: ButtonStyle(
                backgroundColor: _isLoading 
                    ? MaterialStateProperty.all(Colors.white) 
                    : MaterialStateProperty.all(Theme.of(context).primaryColor),
                foregroundColor: MaterialStateProperty.all(Colors.white)
            ),
            onPressed: widget.cartProvider.totalAmount <= 0
                ? null 
                : () async {
                    try {
                        setState(() {
                            _isLoading = true;
                        });

                        await widget.ordersProvider.addOrder(
                            ///
                            /// we need the values of the items map from the cart that's why 
                            /// we converted it into a list of values like this
                            ///
                            widget.cartProvider.items.values.toList(), 
                            widget.cartProvider.totalAmount
                        );

                        setState(() {
                            _isLoading = false;
                        });

                        widget.cartProvider.clearCart();

                        Navigator.of(context).pushNamed(AppConstants.ordersScreenRoute);
                    } catch (error) {
                        await showDialog<Null>(
                            context: context, 
                            builder: (ctx) => AlertDialog(
                                title: Text('An Error occurred!'),
                                content: Text('Something went wrong.'),
                                actions: [
                                    TextButton(
                                        child: Text('Okay'),
                                        onPressed: () {
                                            Navigator.of(ctx).pop();
                                        }
                                    )
                                ]
                            )
                        );
                    }
                }
        );
    }
}