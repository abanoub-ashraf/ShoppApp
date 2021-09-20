import 'package:flutter/material.dart';

import '../../utils/AppConstants.dart';

class NoItemsWidget extends StatelessWidget {
    final String textString;

    NoItemsWidget(this.textString);

    @override
    Widget build(BuildContext context) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Container(
                    padding: EdgeInsets.all(10),
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
                SizedBox(height: 20),
                ElevatedButton(
                    child: Text(
                        'Browse',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24
                        )
                    ),
                    onPressed: () {
                        Navigator.of(context).pushNamed(AppConstants.homeScreenRoute);
                    } 
                )
            ]
        );
    }
}