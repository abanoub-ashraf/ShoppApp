// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/utils/AppRoutes.dart';
import '../../providers/ProductsProvider.dart';
import '../../widgets/Products/UserProductItem.dart';
import '../../widgets/Components/AppDrawer.dart';

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
            .fetchProductsAndSetProducts(true);
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('Manage Your Products'),
                actions: [
                    IconButton(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25
                        ),
                        icon: const Icon(
                            Icons.add, 
                            size: 40
                        ),
                        onPressed: () {
                            Navigator.of(context).pushNamed(AppRoutes.addNewProductScreenRoute);
                        }
                    )
                ]
            ),
            drawer: const AppDrawer(),
            ///
            /// this is for pulling to refresh
            ///
            body: FutureBuilder(
                future: _refreshProducts(context),
                builder: (ctx, snapshot) => snapshot.connectionState == ConnectionState.waiting 
                    ? const Center(
                        child: CircularProgressIndicator()
                    ) 
                    : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<ProductsProvider>(
                        builder: (ctx, productsData, child) => Padding(
                            padding: const EdgeInsets.all(8),
                            child: ListView.builder(
                                itemCount: productsData.items.length,
                                itemBuilder: (_, index) => UserProductItem(
                                    productsData.items[index].id,
                                    productsData.items[index].title,
                                    productsData.items[index].imageUrl
                                )
                            )
                        ),
                    ),
                ),
            )
        );
    }
}
