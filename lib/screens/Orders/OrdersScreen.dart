import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/OrdersProvider.dart';

import '../../widgets/Orders/OrderItem.dart';
import '../../widgets/Components/AppDrawer.dart';
import '../../widgets/Components/NoItemsWidget.dart';

class OrdersScreen extends StatefulWidget {
    @override
    _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
    var _isLoading = false;
    
    @override
    void initState() { 
        super.initState();

        Future.delayed(Duration.zero)
            .then((_) async {
                setState(() {
                    _isLoading = true;
                });

                await Provider.of<OrdersProvider>(context, listen: false).fetchOrdersAndSetOrders();

                setState(() {
                    _isLoading = false;
                });
            });
    }

    @override
    Widget build(BuildContext context) {
        final ordersProvider = Provider.of<OrdersProvider>(context);

        return Scaffold(
            appBar: AppBar(
                title: Text('Your Orders'),
                actions: [
                    IconButton(
                        icon: Icon(
                            Icons.delete_forever,
                            size: 30
                        ),
                        onPressed: () {
                            ordersProvider.clearOrders();
                        }
                    )
                ]
            ),
            drawer: AppDrawer(),
            body: ordersProvider.orders.length == 0 
                ? NoItemsWidget(
                    'There\'s no Orders in here\n click on Browse to browse Products'
                ) 
                : _isLoading 
                    ? Center(child: CircularProgressIndicator()) 
                    : ListView.builder(
                        itemCount: ordersProvider.orders.length,
                        itemBuilder: (ctx, index) => OrderItem(
                            ordersProvider.orders[index]
                        )
                    )
        );
    }
}