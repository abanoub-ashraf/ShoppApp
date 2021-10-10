// ignore_for_file: file_names

import 'package:shop_app/utils/Config.dart';

class AppConstants {
    /// Strings
    
    static const appName            = 'ShopApp';
    
    /// API
    
    static const apiBaseURL         = 'https://identitytoolkit.googleapis.com/v1';

    static final signupEndpoint     = Uri.parse('$apiBaseURL/accounts:signUp?key=${Config.APIKey}');

    static final signInEndpoint     = Uri.parse('$apiBaseURL/accounts:signInWithPassword?key=${Config.APIKey}');

    /// DB
    
    ///
    /// the base url shouldn't include the `https://` if i am gonna use Uri.https() method
    ///
    static const firebaseURL                = 'https://shopapp-flutter-1dfc8-default-rtdb.firebaseio.com';
}