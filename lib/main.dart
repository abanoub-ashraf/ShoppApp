import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/ProductsProvider.dart';
import './providers/CartProvider.dart';
import './providers/OrdersProvider.dart';

import './screens/Products/ProductsOverviewScreen.dart';
import './screens/Products/ProductDetailsScreen.dart';
import './screens/Cart/CartScreen.dart';
import './screens/Orders/OrdersScreen.dart';
import './screens/Products/UserProductsScreen.dart';
import './screens/Products/EditProductScreen.dart';
import './screens/Products/AddNewProductScreen.dart';

import './utils/AppConstants.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        ///
        /// - to connect the provider with the app through the root widget
        ///
        /// - ChangeNotifierProvider provides an instance of the provider so that when any change in it 
        ///   happens, all the child widgets that registered listeners to it rebuild again, 
        ///   not the entire app
        /// 
        /// - not using the .value constructor when instantiating a class is good, using .value is good
        ///  in cases like when the value i provide is getting recycled like inside gird or list
        /// 
        /// - using create constructor if i am creating a new instance of the data provider
        /// 
        /// - MultiProvider is good if i wanna use many providers, instead of nesting them
        ///
        return MultiProvider(
            ///
            /// these two providers are added to the entire app, which means anywhere in the app
            /// can listen to them as long as those places has listeners
            ///
            providers: [
                ChangeNotifierProvider(create: (ctx) => ProductsProvider()),
                ChangeNotifierProvider(create: (ctx) => CartProvider()),
                ChangeNotifierProvider(create: (ctx) => OrdersProvider())
            ],
            child: MaterialApp(
                title: 'ShopApp',
                theme: ThemeData(
                    fontFamily: 'Lato', 
                    colorScheme: ColorScheme
                        .fromSwatch(primarySwatch: Colors.indigo)
                        .copyWith(secondary: Colors.indigoAccent)
                ),
                // home: ProductsOverviewScreen(),
                routes: {
                    AppConstants.homeScreenRoute: (ctx) => ProductsOverviewScreen(),
                    AppConstants.productDetailsRoute: (ctx) => ProductDetailsScreen(),
                    AppConstants.cartScreenRoute: (ctx) => CartScreen(),
                    AppConstants.ordersScreenRoute: (ctx) => OrdersScreen(),
                    AppConstants.userProductsScreenRoute: (ctx) => UserProductsScreen(),
                    AppConstants.editProductScreenRoute: (ctx) => EditProductScreen(),
                    AppConstants.addNewProductScreenRoute: (ctx) => AddNewProductScreen()
                }
            )
        );
    }
}