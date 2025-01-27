import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Modal Popup Example")),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              
            },
            child: Text("Show Popup"),
          ),
        ),
      ),
    );
  }
}