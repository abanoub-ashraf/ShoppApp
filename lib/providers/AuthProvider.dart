// ignore_for_file: file_names, library_prefixes

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as NetworkManager;
import 'package:pretty_json/pretty_json.dart';
import 'package:print_color/print_color.dart';
import 'package:shop_app/models/HTTPException.dart';
import 'package:shop_app/utils/AppConstants.dart';

class AuthProvider extends ChangeNotifier {
    String _token           = '';
    DateTime _expiryDate    = DateTime.now();
    String _userId          = '';
    Timer? _authTimer;

    bool get isAuth {
        ///
        /// if we have a valid token that we are authenticated
        ///
        return token != null;
    }

    String? get token {
        ///
        /// if we have an expire date, and that date is in the future (still valid) and we have a token
        ///
        if (_expiryDate.isAfter(DateTime.now())) {
            return _token;
        }

        return null;
    }

    String? get userId {
        if (_expiryDate.isAfter(DateTime.now())) {
            return _userId;
        }

        return null;
    }

    Future<void> _authenticate(String email, String password, Uri endpoint) async {
        try {
            final response = await NetworkManager.post(
                endpoint,
                body: json.encode({
                    'email': email, 
                    'password': password, 
                    'returnSecureToken': true
                })
            );
            
            final responseData = json.decode(response.body);

            Print.cyan('------------- Authentication --------------');
            printPrettyJson(json.decode(response.body));

            if (responseData['error'] != null) {
                Print.red('----------------- authentication response error -------------------------');
                printPrettyJson(json.decode(response.body));

                throw HTTPException(responseData['error']['message']);
            }

            ///
            /// save the data we got from the response in memory to use it for authentication
            ///
            _token          = responseData['idToken'];
            _userId         = responseData['localId'];
            _expiryDate     = DateTime.now().add(
                Duration(seconds: int.parse(responseData['expiresIn']))
            );

            ///
            /// start the count down for auto logout the moment we log in
            ///
            _autoLogout();

            notifyListeners();

            Print.green('----------------- authentication done -------------------------');
            printPrettyJson(json.decode(response.body));

        } catch(error) {
            Print.red('authentication error: $error');
            rethrow;
        }
    }

    Future<void> signup(String email, String password) async {        
        return _authenticate(email, password, AppConstants.signupEndpoint);
    }

    Future<void> signIn(String email, String password) async {        
        return _authenticate(email, password, AppConstants.signInEndpoint);
    }

    void logout() {
        _token          = '';
        _userId         = '';
        _expiryDate     = DateTime.now();

        ///
        /// if there's auth timer that's already counting then cancel it then set it to null
        ///
        if (_authTimer != null) {
            _authTimer!.cancel();

            _authTimer = null;
        }
        
        notifyListeners();
    }

    ///
    /// - the timer execute a function after some time
    /// 
    /// - the time is the difference between the expiry data and the current time
    ///   and the function is the logout() function
    ///
    void _autoLogout() {
        ///
        /// if there's any timer that's counting cancel it before starting a new one
        ///
        if (_authTimer != null) {
            _authTimer!.cancel();
        }
        final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
        _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
    }
}