// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/ProductsProvider.dart';

class ProductDetailsScreen extends StatelessWidget {
  
    const ProductDetailsScreen({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        final productId = ModalRoute.of(context)?.settings.arguments as String;

        ///
        /// - get the product we wanna load in this screen from the products 
        ///   we got from the provider using the id
        /// 
        /// - listen: false means if i want this widget to not listen to any data change happens
        ///   inside the provider cause this place won't get affected so it's no need to 
        ///
        final loadedProduct = Provider.of<ProductsProvider>(
            context, 
            listen: false
        ).findById(productId);

        return Scaffold(
            appBar: AppBar(
                title: Text(loadedProduct.title),
                actions: [
                    Container(
                        padding: EdgeInsets.all(10), 
                        child: Icon(
                            loadedProduct.isFavorite ? Icons.favorite : Icons.favorite_outline, 
                            size: 28
                        )
                    )
                ]
            ),
            body: SingleChildScrollView(
                child: Column(
                    children: [
                        Container(
                            height: 700,
                            width: double.infinity,
                            child: Image.network(
                                loadedProduct.imageUrl,
                                fit: BoxFit.cover
                            )
                        ),
                        const SizedBox(
                            height: 10
                        ),
                        Text(
                            '\$ ${loadedProduct.price}',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 22
                            )
                        ),
                        const SizedBox(
                            height: 10
                        ),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10
                            ),
                            width: double.infinity,
                            child: Text(
                                loadedProduct.description, 
                                textAlign: TextAlign.center,
                                softWrap: true,
                                style: TextStyle(
                                    fontSize: 24
                                )
                            )
                        )
                    ]
                )
            )
        );
    }
}
