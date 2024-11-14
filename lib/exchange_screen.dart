import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  _ExchangeScreenState createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _fromCurrency;
  String? _toCurrency = 'USD';
  String? _exchangeAmount = "";
  String? _amount = "";
  List<String> currencies = ['MYR', 'USD', 'EUR', 'GBP', 'JPY'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _fromCurrency = args['currency'];
    _amount = args['amount'];
  }

  Future<double> _getExchangeRate() async {
    var url = Uri.http("192.168.8.106:3000", '/exchange-rate');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fromCurrency': _fromCurrency,
        'toCurrency': _toCurrency,
      }),
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData['exchangeRate'];
    } else {
      throw Exception('Failed to load exchange rate');
    }
  }

  void _updateExchangeAmount() async {
    if (_amount != null && _fromCurrency != null && _toCurrency != null) {
      final exchangeRate = await _getExchangeRate();
      double amount = double.parse(_amount!.replaceAll(RegExp(r'[^\d\.]'), ''));
      if (amount == 0) {
        amount = 1.0; // set default value to 1.0 if amount is 0
      }
      final exchangeAmount = amount * exchangeRate;
      setState(() {
        _exchangeAmount = exchangeAmount.toStringAsFixed(2);
        _amount = amount.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Exchange'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Text(
              //   'Cash Exchange',
              //   style: TextStyle(
              //     fontSize: 30,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              const SizedBox(height: 30),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'From Currency',
                  border: OutlineInputBorder(),
                ),
                value: _fromCurrency,
                hint: const Text('Select Currency'),
                onChanged: (value) => setState(() => _fromCurrency = value),
                items: currencies.map((currency) {
                  return DropdownMenuItem<String>(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'To Currency',
                  border: OutlineInputBorder(),
                ),
                value: _toCurrency,
                hint: const Text('Select Currency'),
                onChanged: (value) {
                  setState(() {
                    _toCurrency = value;
                    _updateExchangeAmount(); // Call _updateExchangeAmount here
                  });
                },
                items: currencies.map((currency) {
                  return DropdownMenuItem<String>(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) => _amount = value!,
                onChanged: (value) {
                  setState(() => _amount = value);
                  _updateExchangeAmount();
                },
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text("Exchange Amount : "),
                  Text(_toCurrency!),
                  Text(_exchangeAmount!)
                ],
              ),
              const SizedBox(height: 100),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // TODO: Implement exchange logic here
                    Navigator.pushNamed(context, '/friends');
                  }
                },
                child: const Text('Find Nearby'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_exchangeAmount != null) {
                    Navigator.pushNamed(context, '/post', arguments: {
                      'fromCurrency': _fromCurrency,
                      'toCurrency': _toCurrency,
                      'fromAmount': _amount,
                      'toAmount': _exchangeAmount,
                    });
                  }
                },
                child: const Text('Post Ad'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
