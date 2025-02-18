import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:xchange_app/custom_drawer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:xchange_app/login_state.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:xchange_app/user_display.dart';

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  _ExchangeScreenState createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _fromCurrency = 'MYR';
  String? _toCurrency = 'USD';
  String? _exchangeAmount = "";
  String? _amount = "";
  List<String> currencies = ['MYR', 'USD', 'EUR', 'GBP', 'JPY'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<double> _getExchangeRate() async {
    var url = Uri.http('app01.karnetif.com', '/exchange-rate');
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
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: TextEditingController(text: _fromCurrency),
                        decoration: const InputDecoration(
                          labelText: 'Currency you have',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        readOnly: true,
                        onTap: () {
                          showCurrencyPicker(
                            context: context,
                            showFlag: true,
                            showCurrencyName: true,
                            showCurrencyCode: true,
                            onSelect: (Currency currency) {
                              setState(() {
                                _fromCurrency = currency.code;
                                _updateExchangeAmount();
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: TextEditingController(text: _toCurrency),
                        decoration: const InputDecoration(
                          labelText: 'Currency you want',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        readOnly: true,
                        onTap: () {
                          showCurrencyPicker(
                            context: context,
                            showFlag: true,
                            showCurrencyName: true,
                            showCurrencyCode: true,
                            onSelect: (Currency currency) {
                              setState(() {
                                _toCurrency = currency.code;
                                _updateExchangeAmount();
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Amount you have',
                          border: const OutlineInputBorder(),
                          suffixText: _fromCurrency, // Add currency suffix
                          suffixStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
                          const Text("Amount you get : "),
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
                            Navigator.pushNamed(context, '/postedAd',
                                arguments: {
                                  'fromCurrency': _fromCurrency,
                                  'toCurrency': _toCurrency,
                                  'fromAmount': _amount,
                                  'toAmount': _exchangeAmount
                                });
                          }
                        },
                        child: const Text('Find Nearby'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_exchangeAmount != null) {
                            var user = await LoginState.getUserData();

                            Navigator.pushNamed(context, '/post', arguments: {
                              'isEdit': false,
                              'role': "RECEIVER",
                              'id': null,
                              'fromCurrency': _fromCurrency,
                              'toCurrency': _toCurrency,
                              'fromAmount': _amount,
                              'toAmount': _exchangeAmount,
                              'fromDate': "",
                              'toDate': "",
                              'name': user?['name'],
                              'walletId': user?['walletId'],
                            });
                          }
                        },
                        child: const Text('Post Ad'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const UsernameDisplay(),
        ],
      ),
    );
  }
}
