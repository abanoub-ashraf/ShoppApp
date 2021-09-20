import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
    final Widget? child;
    final String value;

    const Badge({
        Key? key, 
        required this.child,
        required this.value
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Stack(
            alignment: Alignment.center,
            children: [
                child!,
                ///
                /// this creates a widget that controls where the child of the stack 
                /// is positioned
                ///
                Positioned(
                    right: 8,
                    top: 8,
                    ///
                    /// this container is gonna be on top of the child i gave to the constructor
                    /// of this badge file
                    ///
                    child: Container(
                        padding: EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Theme.of(context).colorScheme.secondary
                        ),
                        constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16
                        ),
                        child: Text(
                            value,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10
                            )
                        )
                    )
                )
            ]
        );
    }
}
