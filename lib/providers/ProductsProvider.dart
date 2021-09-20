import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as NetworkManager;
import 'package:pretty_json/pretty_json.dart';

import '../models/ProductModel.dart';
import '../models/HTTPException.dart';

import '../utils/AppConstants.dart';

///
/// - with keyword is mixin, like inheritance but not actually so
///
/// - this is the global place that is gonna provide the app with data
/// 
/// - when any change in the data inside of it happens, only the widgets that
///   registered a listener to that change will rebuild, not the entire app
/// 
/// - ChangeNotifier to notify the listeners when any changes happen inside this provider
///
class ProductsProvider with ChangeNotifier {
    List<ProductModel> _items = [];

    ///
    /// this gets a copy of the items, the latest copy with the latest changes
    ///
    List<ProductModel> get items {
        return [..._items];
    }

    ///
    /// this gets a copy of the favorites, the latest copy with the latest changes
    ///
    List<ProductModel> get favorites {
        return _items.where(
            (product) => product.isFavorite == true
        ).toList();
    }

    ///
    /// return a product by its given id
    ///
    ProductModel findById(String id) {
        return _items.firstWhere(
            (product) => product.id == id
        );
    }

    ///
    /// fetch data from the server and fill the _items list with that data
    ///
    Future<void> fetchProductsAndSetProducts() async {
        final url = AppConstants.productsDBCollectionURL;

        try {
            final response = await NetworkManager.get(url);

            printPrettyJson(json.decode(response.body));
            
            final extractedData = json.decode(response.body) as Map<String, dynamic>?;

            if (extractedData == null) {
                throw 'There is no Products right now!';
            }

            final List<ProductModel> loadedProducts = [];

            extractedData.forEach((productId, productData) {
                loadedProducts.add(
                    ProductModel(
                        id: productId,
                        title: productData['title'],
                        description: productData['description'], 
                        imageUrl: productData['imageUrl'], 
                        price: productData['price'],
                        isFavorite: productData['isFavorite']
                    )
                );

                _items = loadedProducts;

                notifyListeners();
            });
        } catch (error) {
            print('Error while fetching products');
            throw error;
        }
    } 

    ///
    /// - in then catch blocks:
    ///     - the response i get from the server is inside the then block
    ///     - the error i get from the server is inside the catchError block
    ///     - inside errorCatch block i throw the error to be able to use it inside 
    ///       the place where i call this addProduct function
    /// 
    /// - in the async await concept:
    ///     - no need for adding then catch blocks like above
    ///     - we add async in the function definition
    ///     - we add await to the post() and turn its response into a variable
    ///       which is the response that comes from the server
    ///     - the code in the next line after the await line will execute once the
    ///       the await line is done because the code in the next line is invisibly
    ///       wrapped in a then block behind the scenes
    ///     - for handling errors, instead of then catch blocks we use try catch blocks
    ///
    Future<void> addProduct(ProductModel product) async {
        final url = AppConstants.productsDBCollectionURL;

        try {
            final response = await NetworkManager.post(
                url,
                ///
                /// json is available only after importing dart convert built-in package 
                ///
                body: json.encode({
                    'title': product.title,
                    'description': product.description,
                    'price': product.price,
                    'imageUrl': product.imageUrl,
                    'isFavorite': product.isFavorite
                })
            );

            ///
            /// - response comes from firebase not us
            /// 
            /// - using then() here cause post() returns a future
            /// 
            /// - to see the response we get from firebase we need to decode its json format
            ///   into a map in dart language
            /// 
            /// - response.body is the whole json that will be converted into map
            /// 
            /// - json is available after importing dart convert built-in package
            ///
            print('adding new product: ${json.decode(response.body)}');

            final newProduct = ProductModel(
                id: json.decode(response.body)['name'],
                title: product.title, 
                description: product.description, 
                imageUrl: product.imageUrl,
                price: product.price
            );

            _items.add(newProduct);

            notifyListeners();
        } catch (error) {
            print('Error while adding New Product: $error');

            ///
            /// throw means that if there's an error while we calling this add product from another place
            /// the error will be passed to that place to deal with it with the help of the ui
            ///
            throw error;
        }
    }

    ///
    /// update the product of the given id with the new given product
    ///
    Future<void> updateProduct(String id, ProductModel newProduct) async {
        final productIndex = _items.indexWhere((product) => product.id == id);
        
        if (productIndex >= 0) {
            final url = Uri.https(AppConstants.firebaseURL, '/products/$id.json');

            try {
                final response = await NetworkManager.patch(
                    url,
                    body: json.encode({
                        'title': newProduct.title,
                        'description': newProduct.description,
                        'price': newProduct.price,
                        'imageUrl': newProduct.imageUrl
                    })
                );

                print(response.statusCode);

                _items[productIndex] = newProduct;
                notifyListeners();
            } catch (error) {
                print('Error while updating a Product: $error');
                throw error;
            }
        } else {
            throw 'Can\'t find the product you wanna update';
        }
    }

    ///
    /// - we gonna delete the product using a pattern called optimistic update
    /// 
    /// - it means if the deletion failed the product will be re-added again
    ///
    Future<void> deleteProduct(String id) async {
        final url = Uri.https(AppConstants.firebaseURL, '/products/$id.json');

        final existingProductIndex = _items.indexWhere((product) => product.id == id);
        
        ProductModel? existingProduct = _items[existingProductIndex];
        
        _items.removeAt(existingProductIndex);
        notifyListeners();
       
        final response = await NetworkManager.delete(url);
    
        if (response.statusCode >= 400) {
            _items.insert(existingProductIndex, existingProduct);
            notifyListeners();
            
            throw HTTPException('Deleting Failed! Please try again.').message;
        }

        existingProduct = null;
    }
}