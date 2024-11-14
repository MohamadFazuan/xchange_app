import 'package:flutter/material.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  String _cardNumber = "", _cardType = "", _cardExpiration = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Card'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a card number';
                  }
                  return null;
                },
                onSaved: (value) => _cardNumber = value!,
              ),
              const SizedBox(height: 20),
                           TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Card Type',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please select a card type';
                  }
                  return null;
                },
                onSaved: (value) => _cardType = value!,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Card Expiration',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a card expiration date';
                  }
                  return null;
                },
                onSaved: (value) => _cardExpiration = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // TODO: Implement add card logic here
                    Navigator.pushNamed(context, '/cards');
                  }
                },
                child: const Text('Add Card'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}