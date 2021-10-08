// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/ProductsProvider.dart';

import '../../utils/AppRoutes.dart';

class UserProductItem extends StatelessWidget {
    final String id;
    final String title;
    final String imageUrl;

    UserProductItem(this.id, this.title, this.imageUrl);

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
        final scaffold = ScaffoldMessenger.of(context);
        final theme = Theme.of(context);
        
        final productsProvider = Provider.of<ProductsProvider>(context, listen: false);

        return Card(
            color: Colors.white60,
            margin: const EdgeInsets.all(5),
            shadowColor: Theme.of(context).primaryColor,
            elevation: 20,
            child: ListTile(
                title: Text(title),
                leading: CircleAvatar(
                    backgroundImage: NetworkImage(imageUrl)
                ),
                trailing: Container(
                    width: 100,
                    child: Row(
                        children: [
                            IconButton(
                                color: Theme.of(context).primaryColor,
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                    ///
                                    /// go to the edit product screen, pass the product id to it
                                    ///
                                    Navigator.of(context).pushNamed(
                                        AppRoutes.editProductScreenRoute,
                                        arguments: id
                                    );
                                }
                            ),
                            IconButton(
                                color: Theme.of(context).errorColor,
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                    try {
                                        await productsProvider.deleteProduct(id);
                                        scaffold.showSnackBar(
                                            createSnackBar(
                                                'Product is deleted Successfully!', 
                                                theme
                                            )
                                        );
                                    } catch (error) {
                                        ///
                                        /// using ScaffoldManager.of(context) here gives error cause 
                                        /// we are updating the widget inside a future so the context is
                                        /// not the same 
                                        ///
                                        scaffold.showSnackBar(
                                            createSnackBar(
                                                error.toString(), 
                                                theme
                                            )
                                        );
                                    }
                                }
                            )
                        ]
                    )
                )
            )
        );
    }
}
