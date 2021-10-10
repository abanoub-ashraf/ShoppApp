import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/AuthProvider.dart';
import 'package:shop_app/providers/ProductsProvider.dart';
import 'package:shop_app/providers/CartProvider.dart';
import 'package:shop_app/providers/OrdersProvider.dart';
import 'package:shop_app/screens/Auth/AuthScreen.dart';
import 'package:shop_app/screens/Products/ProductsOverviewScreen.dart';
import 'package:shop_app/screens/Products/ProductDetailsScreen.dart';
import 'package:shop_app/screens/Cart/CartScreen.dart';
import 'package:shop_app/screens/Orders/OrdersScreen.dart';
import 'package:shop_app/screens/Products/UserProductsScreen.dart';
import 'package:shop_app/screens/Products/EditProductScreen.dart';
import 'package:shop_app/screens/Products/AddNewProductScreen.dart';
import 'package:shop_app/utils/AppConstants.dart';
import 'package:shop_app/utils/AppRoutes.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  
    const MyApp({Key? key}) : super(key: key);

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
                ChangeNotifierProvider.value(value: AuthProvider()),
                ///
                /// - this provider depends on another provider that's already defined above it
                /// 
                /// - when the provider that this one depends on changes, this one only will rebuild
                ///   not the entire providers array
                /// 
                /// - it takes that provider and another provider which is the data you will provide
                /// 
                /// - in the update: it gives me the auth provider that it depends on so i can use it
                ///   and the previous state of the data i use to provide
                /// 
                /// - when this provider rebuild due to auth provider changing, pass the previous
                ///   products state so we don't lose them after the rebuilt
                ///
                ChangeNotifierProxyProvider<AuthProvider, ProductsProvider>(
                    update: (ctx, authProvider, previousProductsProvider) => ProductsProvider(
                        authProvider.token ?? 'no token', 
                        previousProductsProvider == null ? [] : previousProductsProvider.items
                    ), 
                    create: (ctx) => ProductsProvider('', []),
                ),
                ChangeNotifierProvider(create: (ctx) => CartProvider()),
                ChangeNotifierProvider(create: (ctx) => OrdersProvider()),
            ],
            child: Consumer<AuthProvider>(
                builder: (ctx, auth, _) => MaterialApp(
                    title: AppConstants.appName,
                    theme: ThemeData(
                        fontFamily: 'Lato', 
                        colorScheme: ColorScheme
                            .fromSwatch(primarySwatch: Colors.indigo)
                            .copyWith(secondary: Colors.indigoAccent)
                    ),
                    home: auth.isAuth 
                        ? const ProductsOverviewScreen() 
                        : const AuthScreen(),
                    routes: {
                        AppRoutes.productsOverviewScreenRoute:   (ctx) => const ProductsOverviewScreen(),
                        AppRoutes.productDetailsRoute:           (ctx) => const ProductDetailsScreen(),
                        AppRoutes.cartScreenRoute:               (ctx) => const CartScreen(),
                        AppRoutes.ordersScreenRoute:             (ctx) => const OrdersScreen(),
                        AppRoutes.userProductsScreenRoute:       (ctx) => const UserProductsScreen(),
                        AppRoutes.editProductScreenRoute:        (ctx) => const EditProductScreen(),
                        AppRoutes.addNewProductScreenRoute:      (ctx) => const AddNewProductScreen(),
                        AppRoutes.authScreenRoute:               (ctx) => const AuthScreen(),
                    }
                )
            ),
        );
    }
}