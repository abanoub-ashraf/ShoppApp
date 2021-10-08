// ignore_for_file: file_names, constant_identifier_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ProductsProvider.dart';
import '../../providers/CartProvider.dart';
import '../../widgets/Products/ProductsGridView.dart';
import '../../widgets/Components/Badge.dart';
import '../../widgets/Components/AppDrawer.dart';
import '../../utils/AppRoutes.dart';

enum FilterOptions {
    Favorites,
    All
}

class ProductsOverviewScreen extends StatefulWidget {
    
    const ProductsOverviewScreen({Key? key}) : super(key: key);

    @override
    _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
    var _showOnlyFavorites = false;

    var _isInit = true;

    var _isLoading = false;

    @override
    void initState() { 
        super.initState();

        ///
        /// THIS DOESN'T WORK HERE 
        /// because the widget is not fully built yet so context is not available yet
        ///
        // Provider.of<ProductsProvider>(context).fetchProductsAndSetProducts();

        ///
        /// this is kinda a hack if i want the line above to work
        ///
        // Future.delayed(Duration.zero).then((_) {
        //     Provider.of<ProductsProvider>(context).fetchProductsAndSetProducts();
        // });
    }

    ///
    /// - this runs after the widget has been fully initialized but before before 
    ///   build() runs for the first time
    /// 
    /// - it also runs multiple times, not only once once the widget gets created
    ///   like initState() so i need a helper to stop it from running many times
    /// 
    /// - the helper is the _isInit variable i created, i set it to true
    ///   then do the logic i want inside this method then set the variable to false
    ///   so this method never runs again
    ///
    @override
    void didChangeDependencies() {
        super.didChangeDependencies();

        ///
        /// - check if this didChangeDependencies() method is running for the first time
        /// 
        /// - execute the logic i wanna do
        ///
        if (_isInit) {
            setState(() {
                _isLoading = true;
            });

            ///
            /// calling this function is important cause the _items list inside the provider
            /// is empty and this methods will get data from the server and fill that list
            /// with that data
            ///
            Provider.of<ProductsProvider>(context)
                .fetchProductsAndSetProducts()
                .catchError((error) {
                    showDialog<Null>(
                        context: context, 
                        builder: (ctx) => AlertDialog(
                            title: const Text('Something went wrong.'),
                            content: Text('$error'),
                            actions: [
                                TextButton(
                                    child: const Text('Okay'),
                                    onPressed: () {
                                        Navigator.of(ctx).pop();
                                    }
                                )
                            ]
                        )
                    );
                })
                .then((value) {
                    setState(() {
                        _isLoading = false;
                    });
                });
        }

        ///
        /// - then set this to false so the condition above never happens again so 
        ///   the entire method doesn't run again
        /// 
        /// - this is like creating the initState function on our own
        /// 
        /// - we can't use initState itself cause context is not available yet when
        ///   initState runs 
        ///
        _isInit = false;
    }

    TextStyle createTextStyle() {
        return TextStyle(
            color: Theme.of(context).colorScheme.secondary
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('ShopApp'),
                actions: [
                    PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        itemBuilder: (_) => [
                            PopupMenuItem(
                                child: Text(
                                    'Favorites', 
                                    style: createTextStyle()
                                ),
                                value: FilterOptions.Favorites
                            ),
                            PopupMenuItem(
                                child: Text(
                                    'All Products', 
                                    style: createTextStyle()
                                ),
                                value: FilterOptions.All
                            )
                        ],
                        onSelected: (FilterOptions selectedValue) {
                            setState(() {
                                if (selectedValue == FilterOptions.Favorites) {
                                    _showOnlyFavorites = true;
                                } else {
                                    _showOnlyFavorites = false;
                                }
                            });
                        }
                    ),
                    Consumer<CartProvider>(
                        ///
                        /// - consumer is another way to set up a listener, allows me to wrap only 
                        ///   the part of the tree that i want to rebuild when the provider changes
                        /// 
                        /// - child param in the builder refers to the child of the consumer and that
                        ///   make that child i define doesn't rebuilt again 
                        ///
                        builder: (ctx, cartProvider, child) => Badge(
                            child: child,
                            value: cartProvider.itemsCount.toString()
                            // value: cartProvider.itemsQuantity.toString()
                        ),
                        ///
                        /// this static child won't rebuilt again when the provider changes 
                        ///
                        child: IconButton(
                            icon: const Icon(Icons.shopping_cart),
                            onPressed: () {
                                Navigator.of(context).pushNamed(AppRoutes.cartScreenRoute);
                            }
                        )
                    )
                ]
            ),
            drawer: const AppDrawer(),
            body: _isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : ProductsGridView(_showOnlyFavorites)
        );
    }
}
