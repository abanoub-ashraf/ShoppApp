// ignore_for_file: file_names

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shop_app/widgets/Auth/AuthCard.dart';

class AuthScreen extends StatelessWidget {
    
    const AuthScreen({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        final deviceSize = MediaQuery.of(context).size;

        ///
        /// these two lines does what this line does
        ///     - Matrix4.rotationZ(-8 * pi / 180)..translate(-10.0),
        /// x
        // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
        // transformConfig.translate(-10.0);

        return Scaffold(
            body: Stack(
                children: [
                    ///
                    /// this is the gradient in the background of the auth screen
                    ///
                    Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                    const Color.fromRGBO(24, 95, 240, 1).withOpacity(0.9),
                                    const Color.fromRGBO(5, 23, 111, 1).withOpacity(0.5),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                stops: const [0, 1],
                            ),
                        ),
                    ),
                    SingleChildScrollView(
                        child: Container(
                            height: deviceSize.height,
                            width: deviceSize.width,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                    Flexible(
                                        child: Container(
                                            margin: const EdgeInsets.only(bottom: 20.0),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0, 
                                                horizontal: 94.0
                                            ),
                                            ///
                                            /// ..translate() changes in the object that called it then
                                            /// returns what the previous method returns, which is
                                            /// what the rotationZ() returns
                                            ///
                                            transform: Matrix4.rotationZ(-10 * pi / 180)..translate(-7.0),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(20),
                                                color: Colors.indigo.shade900,
                                                boxShadow: const [
                                                    BoxShadow(
                                                        blurRadius: 8,
                                                        color: Colors.black26,
                                                        offset: Offset(0, 2),
                                                    )
                                                ],
                                            ),
                                            child: Text(
                                                'Shop App',
                                                style: TextStyle(
                                                    color: Theme.of(context).primaryColorLight,
                                                    fontSize: 50,
                                                    fontFamily: 'Anton',
                                                    fontWeight: FontWeight.normal,
                                                ),
                                            ),
                                        ),
                                    ),
                                    Flexible(
                                        flex: deviceSize.width > 600 ? 2 : 1,
                                        child: const AuthCard(),
                                    ),
                                ],
                            ),
                        ),
                    ),
                ],
            ),
        );
    }
}
