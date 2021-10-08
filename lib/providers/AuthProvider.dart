// ignore_for_file: file_names, library_prefixes

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as NetworkManager;
import 'package:print_color/print_color.dart';
import 'package:shop_app/utils/AppConstants.dart';
import 'package:shop_app/utils/ConsoleLogger.dart';

class AuthProvider extends ChangeNotifier {
    late String _token;
    late DateTime _expiryDate;
    late String _userId;

    Future<void> _authenticate(String email, String password, Uri endpoint) async {
        final response = await NetworkManager.post(
            endpoint,
            body: json.encode({
                'email': email, 
                'password': password, 
                'returnSecureToken': true
            })
        );

        ConsoleLogger.logger.i(json.decode(response.body));
    }

    Future<void> signup(String email, String password) async {        
        return _authenticate(email, password, AppConstants.signupEndpoint);
    }

    Future<void> signIn(String email, String password) async {        
        return _authenticate(email, password, AppConstants.signInEndpoint);
    }
}