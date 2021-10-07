// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/ProductsProvider.dart';

import '../../models/ProductModel.dart';

///
/// this screen will be used for adding new product and also
/// editing an existing one
///
class EditProductScreen extends StatefulWidget {
  
    const EditProductScreen({Key? key}) : super(key: key);

    @override
    _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
    final _priceFocusNode       = FocusNode();
    final _descriptionFocusNode = FocusNode();
    final _imageUrlFocusNode    = FocusNode();

    final _imageUrlController   = TextEditingController();

    ///
    /// this global key to connect to the form to be able to save its new data
    ///
    final _form = GlobalKey<FormState>();

    ///
    /// this will store the new data of the product
    ///
    var _editedProduct = ProductModel(
        id: '', 
        title: '', 
        description: '', 
        imageUrl: '', 
        price: 0
    );

    var _isInit = true;

    var _isLoading = false;

    @override
    void initState() {
        super.initState();

        ///
        /// to update the container that has the image preview of the image url
        /// once the image url text field lose focus
        ///
        _imageUrlFocusNode.addListener(_updateImageUrl);
    }

    @override
    void didChangeDependencies() {
        super.didChangeDependencies();

        ///
        /// - we extracted the id from the arguments here cause initState doesn't have the context
        ///   loaded yet
        /// 
        /// - this if check to stop this function from re calling itself many times
        ///
        if (_isInit) {
            ///
            /// extract the id from the arguments we passed to this screen through the navigator 
            ///
            final productId = ModalRoute.of(context)?.settings.arguments as String;
            
            ///
            /// then fill the _editedProduct variable with the product we just got from the provider
            /// using the product id above
            ///
            _editedProduct = Provider.of<ProductsProvider>(context, listen: false).findById(productId);

            ///
            /// we will use the edited product to fill the text fields with its values
            /// but for the text field of the image url we need to fell this controller
            /// then use it in that text field instead of the edited product value
            ///
            _imageUrlController.text = _editedProduct.imageUrl;
            
        }

        _isInit = false;
    }

    @override
    void dispose() {
        super.dispose();
        
        ///
        /// FocusNode needs to be disposed or it will cause memory leaks
        ///
        _priceFocusNode.dispose();
        _descriptionFocusNode.dispose();
        _imageUrlFocusNode.dispose();
        _imageUrlController.dispose();

        _imageUrlFocusNode.removeListener(_updateImageUrl);
    }

    ///
    /// update the image url preview container
    ///
    void _updateImageUrl() {
        if (!_imageUrlFocusNode.hasFocus) {
            if (
                (!_imageUrlController.text.startsWith('http') && 
                !_imageUrlController.text.startsWith('https')) ||
                (!_imageUrlController.text.endsWith('.png') && 
                !_imageUrlController.text.endsWith('.jpg') && 
                !_imageUrlController.text.endsWith('.jpeg'))
            ) {
                return;
            }
            
            setState(() => {});
        }
    }

    ///
    /// - save the form when the save button in th app bar is clicked, and also when the done button
    ///   on the image url text field is clicked
    /// 
    /// - save the current state of the form by the help of the global key
    /// 
    /// - validate all the inputs in the form before saving them
    /// 
    /// - validate() will return true if all the validators have no error, if one of them returned 
    ///   error then validate() will return false
    ///
    Future<void> _saveForm() async {
        final isValid = _form.currentState?.validate();
        
        ///
        /// if this is false don't save the form current state
        ///
        if (isValid == false) {
            return;
        }

        _form.currentState?.save();

        setState(() {
            _isLoading = true;
        });

        try {
            await Provider.of<ProductsProvider>(context, listen: false)
                .updateProduct(
                    _editedProduct.id, 
                    _editedProduct
                );
        } catch (error) {
            await showDialog<Null>(
                context: context, 
                builder: (ctx) => AlertDialog(
                    title: Text('An Error occurred!'),
                    content: Text('Something went wrong.'),
                    actions: [
                        TextButton(
                            child: Text('Okay'),
                            onPressed: () {
                                Navigator.of(ctx).pop();
                            } 
                        )
                    ]
                )
            );
        } finally {
            setState(() {
                _isLoading = false;
            });

            Navigator.of(context).pop();
        }    
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('Edit Product')
            ),
            body: _isLoading
                ? Center(
                    child: CircularProgressIndicator()
                )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                        ///
                        /// to connect the form to the global key of the form state above
                        /// to be access the form state and save it
                        ///
                        key: _form,
                        child: ListView(
                            children: [
                                TextFormField(
                                    initialValue: _editedProduct.title,
                                    decoration: InputDecoration(
                                        labelText: 'Title'
                                    ),
                                    ///
                                    /// this means when i click on the next button in the keyboard
                                    /// it will go to the next text field
                                    ///
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) {
                                        ///
                                        /// move the focus to the next text field which is the price
                                        ///
                                        FocusScope.of(context).requestFocus(_priceFocusNode);
                                    },
                                    ///
                                    /// onSaved() of each text field updates its field inside the editedProduct
                                    /// variable i created above
                                    ///
                                    onSaved: (value) {
                                        _editedProduct = ProductModel(
                                            title: value!,
                                            price: _editedProduct.price,
                                            description: _editedProduct.description,
                                            imageUrl: _editedProduct.imageUrl,
                                            id: _editedProduct.id,
                                            isFavorite: _editedProduct.isFavorite
                                        );
                                    },
                                    ///
                                    /// - return null means we have no error
                                    /// 
                                    /// - return a string means that string is the error
                                    /// 
                                    /// - value is the value the user typed in the text field 
                                    ///
                                    validator: (value) {
                                        if (value!.isEmpty) {
                                            return 'Please enter a title';
                                        }
                                        return null;
                                    }
                                ),
                                TextFormField(
                                    initialValue: _editedProduct.price.toString(),
                                    decoration: InputDecoration(labelText: 'Price'),
                                    textInputAction: TextInputAction.next,
                                    ///
                                    /// show the numbers keyboard when the keyboard shows up
                                    ///
                                    keyboardType: TextInputType.number,
                                    focusNode: _priceFocusNode,
                                    onFieldSubmitted: (_) {
                                        FocusScope.of(context).requestFocus(_descriptionFocusNode);
                                    },
                                    onSaved: (value) {
                                        _editedProduct = ProductModel(
                                            title: _editedProduct.title,
                                            price: double.parse(value!),
                                            description: _editedProduct.description,
                                            imageUrl: _editedProduct.imageUrl,
                                            id: _editedProduct.id,
                                            isFavorite: _editedProduct.isFavorite
                                        );
                                    },
                                    validator: (value) {
                                        if (value!.isEmpty) {
                                            return 'Please enter a price';
                                        }

                                        ///
                                        /// if try parse returned null then it failed to parse the value
                                        ///
                                        if (double.tryParse(value) == null) {
                                            return 'Please enter a valid price';
                                        }

                                        if (double.parse(value) <= 0) {
                                            return 'Price should be higher than 0';
                                        }

                                        return null;
                                    }
                                ),
                                TextFormField(
                                    initialValue: _editedProduct.description,
                                    decoration: InputDecoration(labelText: 'Description'),
                                    maxLines: 3,
                                    keyboardType: TextInputType.multiline,
                                    focusNode: _descriptionFocusNode,
                                    onSaved: (value) {
                                        _editedProduct = ProductModel(
                                            title: _editedProduct.title,
                                            price: _editedProduct.price,
                                            description: value!,
                                            imageUrl: _editedProduct.imageUrl,
                                            id: _editedProduct.id,
                                            isFavorite: _editedProduct.isFavorite
                                        );
                                    },
                                    validator: (value) {
                                        if (value!.isEmpty) {
                                            return 'Please enter a description';
                                        }

                                        if (value.length < 10) {
                                            return 'Should be at least 10 characters';
                                        }
                                        
                                        return null;
                                    }
                                ),
                                Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                        Container(
                                            width: 100,
                                            height: 100,
                                            margin: EdgeInsets.only(
                                                top: 8, 
                                                right: 10
                                            ),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 1, 
                                                    color: Theme.of(context).primaryColor
                                                )
                                            ),
                                            child: _imageUrlController.text.isEmpty 
                                                ? Text('Enter a URL')
                                                : FittedBox(
                                                    child: Image.network(
                                                        _imageUrlController.text, 
                                                        fit: BoxFit.cover
                                                    )
                                                )
                                        ),
                                        Expanded(
                                            child: TextFormField(
                                                decoration: InputDecoration(
                                                    labelText: 'Image URL'
                                                ),
                                                keyboardType: TextInputType.url,
                                                textInputAction: TextInputAction.done,
                                                ///
                                                /// the controller that contains the value of this text field
                                                ///
                                                controller: _imageUrlController,
                                                ///
                                                /// to update the image preview container once this text field
                                                /// loses focus
                                                ///
                                                focusNode: _imageUrlFocusNode,
                                                onSaved: (value) {
                                                    _editedProduct = ProductModel(
                                                        title: _editedProduct.title,
                                                        price: _editedProduct.price,
                                                        description: _editedProduct.description,
                                                        imageUrl: value!,
                                                        id: _editedProduct.id,
                                                        isFavorite: _editedProduct.isFavorite
                                                    );
                                                },
                                                validator: (value) {
                                                    if (value!.isEmpty) {
                                                        return 'Please enter an Image URL';
                                                    }

                                                    if (
                                                        !value.startsWith('http') && 
                                                        !value.startsWith('https')
                                                    ) {
                                                        return 'Please enter a Valid URL';
                                                    }

                                                    if (
                                                        !value.endsWith('.png') && 
                                                        !value.endsWith('.jpg') && 
                                                        !value.endsWith('.jpeg')
                                                    ) {
                                                        return 'Please enter a valid Image URL';
                                                    }

                                                    return null;
                                                },
                                                onFieldSubmitted: (_) {
                                                    _saveForm();
                                                }
                                            )
                                        )
                                    ]
                                ),
                                SizedBox(height: 10),
                                ElevatedButton(
                                    child: Text('Update'),
                                    onPressed: _saveForm 
                                )
                            ]
                        )
                    )
                )
        );
    }
}
