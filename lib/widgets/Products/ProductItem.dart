// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/CartProvider.dart';

import '../../models/ProductModel.dart';

import '../../utils/AppRoutes.dart';

class ProductItem extends StatelessWidget {
    SnackBar createSnackBar(String textString, ThemeData theme) {
        return SnackBar(
            content: Text(
                textString,
                textAlign: TextAlign.center
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: theme.primaryColor
        );
    }

    @override
    Widget build(BuildContext context) {
        ///
        /// - listen to the changes that happens inside the ProductModel provider
        /// 
        /// - that provider is wrapping this widget from inside the ProductsGridView
        /// 
        /// - listen: false means i don't want this listener to listen to the provider changes
        ///
        final productModelProvider = Provider.of<ProductModel>(context, listen: false);

        ///
        /// - listen to the changes that happens inside the Cart provider
        /// 
        /// - that provider is wrapping this widget from inside the main file
        /// 
        /// - this is the cart provider container
        ///
        final cartProvider = Provider.of<CartProvider>(context, listen: false);

        final scaffold = ScaffoldMessenger.of(context);

        final theme = Theme.of(context);

        return ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: GridTile(
                child: GestureDetector(
                    onTap: () {
                        Navigator.of(context).pushNamed(
                            AppRoutes.productDetailsRoute,
                            arguments: productModelProvider.id
                        );
                    },
                    child: Image.network(
                        productModelProvider.imageUrl,
                        fit: BoxFit.cover
                    )
                ),
                footer: GridTileBar(
                    backgroundColor: Colors.black87,
                    ///
                    /// - Consumer is another way to listen to to the changes  that happens 
                    ///   inside the provider
                    /// 
                    /// - Consumer<ProductModel> is same as Provider.of<ProductModel>
                    /// 
                    /// - it helps when i want only specific part of the tree of this widget to listen
                    ///   to the provider changes instead of having the entire tree as a listener
                    ///
                    leading: Consumer<ProductModel>(
                        // child: const Text(''),
                        
                        ///
                        /// child param means if i have something inside the builder: that i don't want
                        /// it to rebuild, i can refer to that something as `child` and above builder:
                        /// i define that child to whatever static thing i want
                        ///
                        builder: (ctx, productModel, child) => IconButton(
                            color: Theme.of(context).colorScheme.secondary,
                            icon: Icon(
                                productModel.isFavorite 
                                    ? Icons.favorite 
                                    : Icons.favorite_border
                            ),
                            onPressed: () async {
                                try {
                                    await productModel.toggleFavoriteStatus();
                                } catch (error) {
                                    scaffold.showSnackBar(
                                        createSnackBar(
                                            error.toString(), 
                                            theme
                                        )
                                    );
                                }
                            }
                        )
                    ),
                    title: FittedBox(
                        child: Text(
                            productModelProvider.title, 
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor
                            )
                        )
                    ),
                    trailing: IconButton(
                        color: Theme.of(context).colorScheme.secondary,
                        icon: const Icon(Icons.shopping_cart),
                        onPressed: () {
                            ///
                            /// - add the item to the cart
                            ///
                            cartProvider.addItems(
                                productModelProvider.id, 
                                productModelProvider.price, 
                                productModelProvider.title
                            );

                            ///
                            /// remove the current snack bar if there is one on the screen
                            ///
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            
                            ///
                            /// - show a snack bar at the bottom that tells the user that 
                            ///   the item is added to the cart
                            /// 
                            /// - add an option inside of it for the user to undo that 
                            ///   adding to the cart using a snack bar action 
                            ///
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('${productModelProvider.title} is added to the Cart!'),
                                duration: const Duration(seconds: 2),
                                backgroundColor: Theme.of(context).primaryColor,
                                action: SnackBarAction(
                                    textColor: Colors.indigo.shade200,
                                    label: 'UNDO',
                                    onPressed: () {
                                        cartProvider.removeSingleItem(productModelProvider.id);
                                    }
                                )
                            ));
                        }
                    )
                )
            )
        );
    }
}
