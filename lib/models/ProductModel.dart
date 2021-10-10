// ignore_for_file: file_names, library_prefixes

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as NetworkManager;
import 'package:shop_app/models/HTTPException.dart';
import 'package:shop_app/utils/AppConstants.dart';

///
/// - with keyword is mixin, like inheritance but not actually so
///
/// - this is like the provider, the global place that is gonna provide the app with data
/// 
/// - now this ProductModel can notify listeners when they change 
///
class ProductModel with ChangeNotifier {
    final String id;
    final String title;
    final String description;
    final double price;
    final String imageUrl;
    bool isFavorite;

    ProductModel({
        required this.id,
        required this.title,
        required this.description,
        required this.imageUrl,
        required this.price,
        this.isFavorite = false
    });

    void _setFavValue(bool newValue) {
        isFavorite = newValue;
        notifyListeners();
    }

    ///
    /// - toggle the favorite status using the optimistic update
    /// 
    /// - rollback to the old status if updating to the new status is failed
    ///
    Future<void> toggleFavoriteStatus(String token) async {
        ///
        /// store a copy of the old status first so we can roll back to it 
        /// if the updating failed
        ///
        final oldStatus = isFavorite;

        isFavorite = !isFavorite;

        notifyListeners();
        
        final url = Uri.parse('${AppConstants.firebaseURL}/products/$id.json?auth=$token');
        
        try {
            final response = await NetworkManager.patch(
                url,
                ///
                /// the body can have the only fields we wanna update on the server 
                ///
                body: json.encode({
                    'isFavorite': isFavorite
                })
            );

            if (response.statusCode >= 400) {
                _setFavValue(oldStatus);
                throw HTTPException('Something went wrong! Please try again.').message;
            }
        } catch (error) {
            _setFavValue(oldStatus);
            rethrow;
        }
    }
}
