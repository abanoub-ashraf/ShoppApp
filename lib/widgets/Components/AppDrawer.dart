import 'package:flutter/material.dart';

import '../../utils/AppConstants.dart';

class AppDrawer extends StatelessWidget {
    TextStyle createStyle(BuildContext context) {
        return TextStyle(
            fontSize: 20, 
            color: Colors.black
        );
    } 

    @override
    Widget build(BuildContext context) {
        return Drawer(
            elevation: 5,
            child: Column(
                children: [
                    AppBar(
                        title: Container(
                            alignment: Alignment.centerLeft, 
                            child: Text('Side Menu')
                        ),
                        ///
                        /// this means we will never add a back button in this appbar
                        /// cause it wouldn't work
                        ///
                        automaticallyImplyLeading: false
                    ),
                    Divider(),
                    ListTile(
                        leading: Icon(
                            Icons.shop, 
                            size: 40,
                            color: Theme.of(context).primaryColor
                        ),
                        title: Text(
                            'Browse', 
                            style: createStyle(context)
                        ),
                        onTap: () {
                            ///
                            /// go to the products overview screen
                            ///
                            Navigator.of(context).pushReplacementNamed(AppConstants.homeScreenRoute);
                        }
                    ),
                    ListTile(
                        leading: Icon(
                            Icons.shopping_cart, 
                            size: 40, 
                            color: Theme.of(context).primaryColor
                        ),
                        title: Text(
                            'My Cart',
                            style: createStyle(context)
                        ),
                        onTap: () {
                            ///
                            /// go to the carts screen
                            ///
                            Navigator.of(context).pushNamed(AppConstants.cartScreenRoute);
                        }
                    ),
                    ListTile(
                        leading: Icon(
                            Icons.payment, 
                            size: 40,
                            color: Theme.of(context).primaryColor
                        ),
                        title: Text(
                            'My Orders',
                            style: createStyle(context)
                        ),
                        onTap: () {
                            ///
                            /// go to the orders screen
                            ///
                            Navigator.of(context).pushReplacementNamed(AppConstants.ordersScreenRoute);
                        }
                    ),
                    ListTile(
                        leading: Icon(
                            Icons.settings, 
                            size: 40,
                            color: Theme.of(context).primaryColor
                        ),
                        title: Text(
                            'My Products',
                            style: createStyle(context)
                        ),
                        onTap: () {
                            ///
                            /// go to the user products screen
                            ///
                            Navigator.of(context).pushReplacementNamed(AppConstants.userProductsScreenRoute);
                        }
                    )
                ]
            )
        );
    }
}