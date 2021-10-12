// ignore_for_file: file_names, library_prefixes

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as NetworkManager;
import 'package:pretty_json/pretty_json.dart';
import 'package:print_color/print_color.dart';
import 'package:shop_app/models/ProductModel.dart';
import 'package:shop_app/models/HTTPException.dart';
import 'package:shop_app/utils/AppConstants.dart';

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
    /// the token we gonna use with every request to authenticate 
    /// the user who is making that request
    /// 
    final String authToken;
    /// 
    /// - the user id is for fetching the user favorites
    ///
    final String userId;

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

    ProductsProvider(this.authToken, this.userId, this._items);

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
    Future<void> fetchProductsAndSetProducts([bool filterByUser = false]) async {
        final filterString = filterByUser ? '&orderBy="userId"&equalTo="$userId"' : '';
        ///
        /// to fetch only the products that belongs to the current user
        ///
        final queryParams = 'auth=$authToken$filterString';

        ///
        /// /products.json is the products table/collection in the firebase database
        ///
        var url = Uri.parse('${AppConstants.firebaseURL}/products.json?$queryParams');

        try {
            final response = await NetworkManager.get(url);

            Print.green('------------- fetched products --------------');
            printPrettyJson(json.decode(response.body));
            Print.yellow('---------------------------------------------------------------------------');
            Print.yellow(authToken);
            Print.yellow('---------------------------------------------------------------------------');
 
            final extractedData = json.decode(response.body) as Map<String, dynamic>?;

            if (extractedData == null) {
                throw 'there is no Products right now!';
            }

            ///
            /// fetch the user favorites
            ///
            url = Uri.parse('${AppConstants.firebaseURL}/userFavorites/$userId.json?auth=$authToken');
            
            final favoriteResponse = await NetworkManager.get(url);
            
            final favoriteData = json.decode(favoriteResponse.body);

            final List<ProductModel> loadedProducts = [];

            extractedData.forEach((productId, productData) {
                loadedProducts.add(
                    ProductModel(
                        id: productId,
                        title: productData['title'],
                        description: productData['description'], 
                        imageUrl: productData['imageUrl'], 
                        price: productData['price'],
                        ///
                        /// if the favorite is null then the user doesn't have any favorites yet
                        ///
                        isFavorite: favoriteData == null ? false : favoriteData[productId] ?? false
                    )
                );

                _items = loadedProducts;

                notifyListeners();
            });
        } catch (error) {
            Print.red(error);
            throw 'Error while fetching products';
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
        ///
        /// /products.json is the products table/collection in the firebase database
        ///
        final url = Uri.parse('${AppConstants.firebaseURL}/products.json?auth=$authToken');

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
                    'userId': userId
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
            Print.blue('-------------------- add product -------------------------');
            printPrettyJson(json.decode(response.body));

            Print.magenta(authToken);

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
            Print.red(error);

            ///
            /// throw means that if there's an error while we calling this add product from another place
            /// the error will be passed to that place to deal with it with the help of the ui
            ///
            throw 'Error while adding New Product';
        }
    }

    ///
    /// update the product of the given id with the new given product
    ///
    Future<void> updateProduct(String id, ProductModel newProduct) async {
        final productIndex = _items.indexWhere((product) => product.id == id);
        
        if (productIndex >= 0) {
            final url = Uri.parse('${AppConstants.firebaseURL}/products/$id.json?auth=$authToken');

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

                Print.yellow('------------- update product --------------');
                printPrettyJson(json.decode(response.body));
                Print.yellow('-------------------------------------------');

                _items[productIndex] = newProduct;
                notifyListeners();
            } catch (error) {
                Print.red(error);
                throw 'Error while updating a Product';
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
        final url = Uri.parse('${AppConstants.firebaseURL}/products/$id.json?auth=$authToken');

        final existingProductIndex = _items.indexWhere((product) => product.id == id);
        
        ProductModel? existingProduct = _items[existingProductIndex];
        
        _items.removeAt(existingProductIndex);
        notifyListeners();
       
        final response = await NetworkManager.delete(url);

        Print.white('------------- delete product --------------');
        printPrettyJson(json.decode(response.body));
        Print.white('-------------------------------------------');
    
        if (response.statusCode >= 400) {
            _items.insert(existingProductIndex, existingProduct);
            notifyListeners();
            
            printPrettyJson(json.decode(response.body));
            
            throw HTTPException('Deleting Failed! Please try again.').message;
        }

        existingProduct = null;
    }
}
