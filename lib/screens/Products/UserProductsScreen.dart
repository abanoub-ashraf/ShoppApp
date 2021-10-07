// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/ProductsProvider.dart';

import '../../widgets/Products/UserProductItem.dart';
import '../../widgets/Components/AppDrawer.dart';

import '../../utils/AppConstants.dart';

///
/// shows the products of the user
///
class UserProductsScreen extends StatelessWidget {
  
    const UserProductsScreen({Key? key}) : super(key: key);

    Future<void> _refreshProducts(BuildContext context) async {
        ///
        /// - listen is false here cause in here we just wanna trigger the fetch method without
        ///   listening to any products updates
        /// 
        /// - that avoids unnecessary widget rebuilds
        ///
        await Provider.of<ProductsProvider>(context, listen: false)
            .fetchProductsAndSetProducts();
    }

    @override
    Widget build(BuildContext context) {
        final productsProvider = Provider.of<ProductsProvider>(context);

        return Scaffold(
            appBar: AppBar(
                title: const Text('Manage Your Products'),
                actions: [
                    IconButton(
                        padding: EdgeInsets.symmetric(
                            horizontal: 25
                        ),
                        icon: const Icon(
                            Icons.add, 
                            size: 40
                        ),
                        onPressed: () {
                            Navigator.of(context).pushNamed(AppConstants.addNewProductScreenRoute);
                        }
                    )
                ]
            ),
            drawer: AppDrawer(),
            ///
            /// this is for pulling to refresh
            ///
            body: RefreshIndicator(
                child: Padding(
                    padding: EdgeInsets.all(8),
                    child: ListView.builder(
                        itemCount: productsProvider.items.length,
                        itemBuilder: (_, index) => UserProductItem(
                            productsProvider.items[index].id,
                            productsProvider.items[index].title,
                            productsProvider.items[index].imageUrl
                        )
                    )
                ),
                onRefresh: () => _refreshProducts(context)
            )
        );
    }
}
