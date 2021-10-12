// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/AuthProvider.dart';
import 'package:shop_app/utils/AppRoutes.dart';

class AppDrawer extends StatelessWidget {
  
    const AppDrawer({Key? key}) : super(key: key);

    TextStyle createStyle(BuildContext context) {
        return const TextStyle(
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
                            child: const Text('Side Menu')
                        ),
                        ///
                        /// this means we will never add a back button in this appbar
                        /// cause it wouldn't work
                        ///
                        automaticallyImplyLeading: false
                    ),
                    const Divider(),
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
                            Navigator.of(context).pushReplacementNamed(AppRoutes.productsOverviewScreenRoute);
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
                            Navigator.of(context).pushNamed(AppRoutes.cartScreenRoute);
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
                            Navigator.of(context).pushReplacementNamed(AppRoutes.ordersScreenRoute);
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
                            Navigator.of(context).pushReplacementNamed(AppRoutes.userProductsScreenRoute);
                        }
                    ),
                    ListTile(
                        leading: Icon(
                            Icons.logout,
                            size: 40,
                            color: Theme.of(context).primaryColor
                        ),
                        title: Text(
                            'Logout',
                            style: createStyle(context)
                        ),
                        onTap: () {
                            Navigator.of(context).pop();
                            
                            Provider.of<AuthProvider>(context, listen: false).logout();
                        }
                    )
                ]
            )
        );
    }
}
