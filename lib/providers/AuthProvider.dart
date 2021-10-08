// ignore_for_file: file_names, library_prefixes

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as NetworkManager;
import 'package:pretty_json/pretty_json.dart';
import 'package:shop_app/utils/AppConstants.dart';

class AuthProvider extends ChangeNotifier {
    String _token = '';
    DateTime _expiryDate = DateTime.now();
    String _userId = '';

    Future<void> signup(String email, String password) async {        
        final response = await NetworkManager.post(
            AppConstants.signupEndpoint,
            body: json.encode({
                'email': email, 
                'password': password, 
                'returnSecureToken': true
            })
        );
        
        printPrettyJson(json.decode(response.body));
    }
}
