// ignore_for_file: file_names, library_prefixes

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as NetworkManager;
import 'package:pretty_json/pretty_json.dart';
import 'package:print_color/print_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
            /// store the data we got from the response in these variables we created above
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

            ///
            /// - make sure to use async await keywords 
            ///
            /// - store the login data on teh device to use it for auto login
            ///   using shared preferences
            ///
            final localStorage = await SharedPreferences.getInstance();

            ///
            /// if i have many data types i wanna store, then convert them into json
            /// then save that json as a string
            ///
            final userData = json.encode({
                'token': _token,
                'userId': _userId,
                'expiryDate': _expiryDate.toIso8601String()
            });
            
            ///
            /// this is how to save the data in shared preferences
            ///
            localStorage.setString('userData', userData);

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

    ///
    /// check if the stored token in the device is still valid
    ///
    Future<bool> tryAutoLogin() async {
        final localStorage = await SharedPreferences.getInstance();

        ///
        /// if the saved data doesn't have this key then return false cause 
        /// the data we look for in the device is not exist
        ///
        if (!localStorage.containsKey('userData')) {
            return false;
        }
        
        ///
        /// now we have data saved in the device, extract that data into a variable
        ///
        final extractedUserData = json.decode(localStorage.getString('userData')!) as Map<String, dynamic>;
        
        ///
        /// extract the expiry date we saved from that data
        ///
        final expiryDate = DateTime.parse(extractedUserData['expiryDate'].toString());

        ///
        /// if that date is in the past then the token we saved in the device is not valid
        ///
        if (expiryDate.isBefore(DateTime.now())) {
            return false;
        }

        ///
        /// - else, now that token is valid
        /// 
        /// - populate the variable we created at the beginning with the saved data,
        ///   call auto logout again to reset the timer that will lead to the auto logout to happen,
        ///   then return true
        ///
        _token          = extractedUserData['token'].toString();
        _userId         = extractedUserData['userId'].toString();
        _expiryDate     = expiryDate;

        notifyListeners();
        _autoLogout();

        return true;
    }

    Future<void> logout() async {
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
    
        ///
        /// clear the local storage as well
        ///
        final localStorage = await SharedPreferences.getInstance();
        localStorage.clear();
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