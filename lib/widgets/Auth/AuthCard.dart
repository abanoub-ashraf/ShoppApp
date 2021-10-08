// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/HTTPException.dart';
import 'package:shop_app/providers/AuthProvider.dart';
import 'package:shop_app/utils/ErrorMessages.dart';
import 'package:cool_alert/cool_alert.dart';

enum AuthMode { 
    signUp, 
    login
}

class AuthCard extends StatefulWidget {
    const AuthCard({
        Key? key,
    }) : super(key: key);

    @override
    _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {

    final GlobalKey<FormState> _formKey = GlobalKey();

    AuthMode _authMode = AuthMode.login;
    
    final Map<String, String> _authData = {
        'email': '',
        'password': '',
    };
    
    var _isLoading = false;
    
    final _passwordController = TextEditingController();

    Future<void> _submit() async {
        final isValid = _formKey.currentState?.validate();

        if (isValid == false) {
            // Invalid!
            return;
        }

        // Valid!
        _formKey.currentState?.save();
        
        setState(() {
            _isLoading = true;
        });
        
        try {
            if (_authMode == AuthMode.login) {
                await Provider.of<AuthProvider>(context, listen: false)
                    .signIn(
                        _authData['email']!, 
                        _authData['password']!
                    );
            } else {
                await Provider.of<AuthProvider>(context, listen: false)
                    .signup(
                        _authData['email']!, 
                        _authData['password']!
                    );
            }
        } on HTTPException catch(error) {
            var errorMessage = ErrorMessages.authFailed;

            if (error.toString().contains('EMAIL_EXISTS')) {
                errorMessage = ErrorMessages.emailAlreadyExists;
            } else if (error.toString().contains('INVALID_EMAIL')) {
                errorMessage = ErrorMessages.invalidEmail;
            } else if (error.toString().contains('WEAK_PASSWORD')) {
                errorMessage = ErrorMessages.weakPassword;
            } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
                errorMessage = ErrorMessages.emailNotFound;
            } else if (error.toString().contains('INVALID_PASSWORD')) {
                errorMessage = ErrorMessages.invalidPassword;
            }

            _showErrorDialog(errorMessage);
        } catch (error) {
            const errorMessage = ErrorMessages.couldntAuth;

            _showErrorDialog(errorMessage);
        }
        
        setState(() {
            _isLoading = false;
        });
    }

    void _showErrorDialog(String errorMessage) {
        CoolAlert.show(
            context: context,
            title: 'Oops...',
            type: CoolAlertType.error,
            text: errorMessage,
            confirmBtnText: 'Ok',
            onConfirmBtnTap: () { Navigator.of(context).pop(); },
            barrierDismissible: true,
            confirmBtnColor: Colors.indigo.shade900,
            animType: CoolAlertAnimType.rotate,
            backgroundColor: Theme.of(context).primaryColorDark,
            loopAnimation: true,
            borderRadius: 20,
        );
    }

    void _switchAuthMode() {
        if (_authMode == AuthMode.login) {
            setState(() {
                _authMode = AuthMode.signUp;
            });
        } else {
            setState(() {
                _authMode = AuthMode.login;
            });
        }
    }

    @override
    Widget build(BuildContext context) {
        
        final deviceSize = MediaQuery.of(context).size;

        return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 8.0,
            child: Container(
                height: _authMode == AuthMode.signUp ? 320 : 260,
                constraints: BoxConstraints(minHeight: _authMode == AuthMode.signUp ? 320 : 260),
                width: deviceSize.width * 0.75,
                padding: const EdgeInsets.all(16.0),
                child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                        child: Column(
                            children: [
                                TextFormField(
                                    decoration: const InputDecoration(labelText: 'E-Mail'),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                        if (value!.isEmpty || !value.contains('@')) {
                                            return 'Invalid email!';
                                        }
                                        return null;
                                    },
                                    onSaved: (value) {
                                        _authData['email'] = value!;
                                    },
                                ),
                                TextFormField(
                                    decoration: const InputDecoration(labelText: 'Password'),
                                    obscureText: true,
                                    controller: _passwordController,
                                    validator: (value) {
                                        if (value!.isEmpty || value.length < 5) {
                                            return 'Password is too short!';
                                        }
                                    },
                                    onSaved: (value) {
                                        _authData['password'] = value!;
                                    },
                                ),
                                if (_authMode == AuthMode.signUp)
                                    TextFormField(
                                        enabled: _authMode == AuthMode.signUp,
                                        decoration: const InputDecoration(labelText: 'Confirm Password'),
                                        obscureText: true,
                                        validator: _authMode == AuthMode.signUp
                                            ? (value) {
                                                if (value != _passwordController.text) {
                                                    return 'Passwords do not match!';
                                                }
                                            }
                                            : null,
                                    ),
                                const SizedBox(
                                    height: 20,
                                ),
                                if (_isLoading)
                                    CircularProgressIndicator(
                                        backgroundColor: Theme.of(context).primaryColorLight,
                                    )
                                else
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(30),
                                            ), 
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 30.0, 
                                                vertical: 8.0
                                            ),
                                            primary: Colors.indigo.shade900,
                                        ),
                                        child: Text(
                                            _authMode == AuthMode.login ? 'LOGIN' : 'SIGN UP',
                                            style: TextStyle(
                                                color: Theme.of(context).primaryColorLight,
                                            ),
                                        ),
                                        onPressed: _submit,
                                    ),
                                TextButton(
                                    style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30.0, 
                                            vertical: 4
                                        ),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        textStyle: TextStyle(
                                            color: Theme.of(context).primaryColor,
                                        ),
                                    ),
                                    child: Text(
                                        '${_authMode == AuthMode.login ? 'SIGNUP' : 'LOGIN'} INSTEAD',
                                    ),
                                    onPressed: _switchAuthMode,
                                ),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }
}
