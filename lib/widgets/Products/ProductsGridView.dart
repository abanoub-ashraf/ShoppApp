import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/ProductsProvider.dart';

import './ProductItem.dart';

class ProductsGridView extends StatelessWidget {
    final bool showFavorites;

    ProductsGridView(this.showFavorites);

    @override
    Widget build(BuildContext context) {
        ///
        /// - setup a listener between the provider and this child widget of the app
        /// 
        /// - the parent of this child must have a ChangeNotifierProvider, if it doesn't,
        ///   flutter will look for that in the next parent till it finds it
        ///
        final productsDataProvider = Provider.of<ProductsProvider>(context);
        
        ///
        /// get the products data from the provider to use them in here, based on the bool
        /// variable above
        ///
        final products = showFavorites ? productsDataProvider.favorites : productsDataProvider.items;

        return GridView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10
            ),
            itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
                ///
                /// - this is setting up the second provider which is the ProductModel
                /// 
                /// - each product of this array is the data provider i wanna pass to the children
                ///  of it, which is the product item
                /// 
                /// - the listener is gonna be setup inside the product item
                ///
                /// - .value is another constructor if the value i provide
                ///   doesn't depend on the context, this is the recommended approach
                ///
                value: products[index],
                child: ProductItem()
            )
        );
    }
}