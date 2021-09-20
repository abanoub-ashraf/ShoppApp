class CartItemModel {
    ///
    /// this is the id of the cart item and it's not the same as 
    /// the id of the product
    ///
    final String id;
    final String title;
    final int quantity;
    final double price;

    CartItemModel({
        required this.id,
        required this.title,
        required this.quantity,
        required this.price
    });
}