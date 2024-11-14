import 'package:flutter/material.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('Exchange App'),
            SizedBox(height: 20),
            Text('Version 1.0'),
            SizedBox(height: 20),
            Text('Developed by [Your Name]'),
          ],
        ),
      ),
    );
  }
}