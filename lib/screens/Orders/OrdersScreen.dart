// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/OrdersProvider.dart';

import '../../widgets/Orders/OrderItem.dart';
import '../../widgets/Components/AppDrawer.dart';
import '../../widgets/Components/NoItemsWidget.dart';

class OrdersScreen extends StatefulWidget {
  
    const OrdersScreen({Key? key}) : super(key: key);

    @override
    State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
    ///
    /// - first i was using this line
    ///   Provider.of<OrdersProvider>(context, listen: false).fetchOrdersAndSetOrders() 
    ///   inside the future of the FutureBuilder Widget down there
    /// 
    /// - but if i had something else in the widget that caused it to rebuild again like 
    ///   another state managing then fetchOrdersAndSetOrders() will be executed again
    ///   and that means a new future will be obtained which means the http request inside 
    ///   of it will be executed again and that something we want to avoid
    /// 
    /// - so to avoid that, obtain the future and store it in a late variable
    ///   inside the initState() then use that variable inside the future of 
    ///   the FutureBuilder Widget
    ///
    late Future _ordersFuture;

    Future _obtainOrdersFuture() {
        return Provider.of<OrdersProvider>(context, listen: false).fetchOrdersAndSetOrders();
    }

    @override
    void initState() {
        super.initState();
        _ordersFuture = _obtainOrdersFuture();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('Your Orders')
            ),
            drawer: const AppDrawer(),
            ///
            /// - this creates a widget that builds itself based on the latest snapshot 
            ///   of interaction with a [Future]
            /// 
            /// - it takes a future 
            /// 
            /// - the data that we get back in the builder is the data the future gives us
            /// 
            /// - FutureBuilder allows us to control the loading spinner in a better way rather than
            ///   changing into stateful widget 
            ///
            body: FutureBuilder(
                future: _ordersFuture,
                builder: (ctx, dataSnapShot) {
                    if (dataSnapShot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator()
                        );
                    } else {
                        if (dataSnapShot.error != null) {
                            if (Provider.of<OrdersProvider>(context).orders.length == 0) {
                                return const NoItemsWidget(
                                    'There\'s no Orders in here\n click on Browse to browse Products'
                                );
                            }

                            return const NoItemsWidget('An Error occurred!');
                        } else {
                            if (Provider.of<OrdersProvider>(context).orders.length == 0) {
                                return const NoItemsWidget(
                                    'There\'s no Orders in here\n click on Browse to browse Products'
                                );
                            }
                            return Consumer<OrdersProvider>(
                                builder: (ctx, orderData, child) => ListView.builder(
                                    itemCount: orderData.orders.length,
                                    itemBuilder: (ctx, index) => OrderItem(
                                        orderData.orders[index]
                                    )
                                )
                            );
                        }
                    }
                }
            )
        );
    }
}
