// ignore_for_file: file_names

import 'package:flutter/material.dart';

import '../../utils/AppRoutes.dart';

class NoItemsWidget extends StatelessWidget {
    
    final String textString;

    const NoItemsWidget(this.textString, {Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Container(
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.center,
                    child: Text(
                        textString,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 22
                        )
                    ) 
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    child: const Text(
                        'Browse',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24
                        )
                    ),
                    onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.productsOverviewScreenRoute);
                    } 
                )
            ]
        );
    }
}
