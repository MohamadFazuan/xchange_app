import 'package:flutter/material.dart';

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  _CardScreenState createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cards'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add_card');
              },
              child: const Text('Add Card'),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              itemCount: 10, // Replace with actual card data
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text('Card ${index + 1}'),
                    subtitle: const Text('Type: '),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        // TODO: Implement delete card logic here
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}