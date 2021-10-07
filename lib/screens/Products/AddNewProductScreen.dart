// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/ProductsProvider.dart';

import '../../models/ProductModel.dart';

class AddNewProductScreen extends StatefulWidget {
  
    const AddNewProductScreen({Key? key}) : super(key: key);

    @override
    _AddNewProductScreenState createState() => _AddNewProductScreenState();
}

class _AddNewProductScreenState extends State<AddNewProductScreen> {
    final _priceFocusNode       = FocusNode();
    final _descriptionFocusNode = FocusNode();
    final _imageUrlFocusNode    = FocusNode();

    final _titleController       = TextEditingController();
    final _priceController       = TextEditingController();
    final _descriptionController = TextEditingController();
    final _imageUrlController    = TextEditingController();

    final _form = GlobalKey<FormState>();

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
    void dispose() {
        super.dispose();
        
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
        
        if (isValid == false) {
            return;
        }

        final _newProduct = ProductModel(
            id: DateTime.now().toString(),
            title: _titleController.text, 
            description: _descriptionController.text, 
            imageUrl: _imageUrlController.text, 
            price: double.parse(_priceController.text),
            isFavorite: false
        );

        _form.currentState?.save();

        setState(() {
            _isLoading = true;
        });

        try {
            await Provider.of<ProductsProvider>(context, listen: false)
                .addProduct(_newProduct);
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
            ///
            /// finally block runs no matter the code succeeded or not
            ///
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
                title: Text('Add New Product')
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
                                    controller: _titleController,
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
                                        _titleController.text = value!;
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
                                    controller: _priceController,
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
                                        _priceController.text = value!;
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
                                    controller: _descriptionController,
                                    decoration: InputDecoration(labelText: 'Description'),
                                    maxLines: 3,
                                    keyboardType: TextInputType.multiline,
                                    focusNode: _descriptionFocusNode,
                                    onSaved: (value) {
                                        _descriptionController.text = value!;
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
                                                    _imageUrlController.text = value!;
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
                                    child: Text('Add Product'),
                                    onPressed: _saveForm 
                                )
                            ]
                        )
                    )
                )
        );
    }
}
