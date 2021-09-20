class AppConstants {
    /// Routes
    static const homeScreenRoute           = '/';
    static const productDetailsRoute       = '/product-details';
    static const cartScreenRoute           = '/cart-screen';
    static const ordersScreenRoute         = '/orders-screen';
    static const userProductsScreenRoute   = '/user-products-screen';
    static const editProductScreenRoute    = '/edit-product-screen';
    static const addNewProductScreenRoute  = '/add-new-product-screen';

    /// API
    
    ///
    /// the base url shouldn't include the `https://` if i am gonna use Uri.https() method
    ///
    static final firebaseURL             = 'shopapp-flutter-1dfc8-default-rtdb.firebaseio.com';
    ///
    /// /products.json is the products table/collection in the firebase database
    ///
    static final productsDBCollectionURL = Uri.https(firebaseURL, '/products.json');
    ///
    /// /orders.json is the orders table/collection in the firebase database
    ///
    static final ordersDBCollectionURL   = Uri.https(firebaseURL, '/orders.json');
}