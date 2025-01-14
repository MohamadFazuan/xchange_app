import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xchange_app/cash_checkout_screen.dart';
import 'dart:convert';

import 'package:xchange_app/match_exchange.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  List<MatchExchange> _matchExchanges = [];

  Future<void> _loadMatchExchanges() async {
    var url = Uri.http("app01.karnetif.com", '/postAd/queryAll');
    var response = await http.get(url);
    final jsonData = jsonDecode(response.body);
    setState(() {
      _matchExchanges = jsonData
          .map<MatchExchange>((data) => MatchExchange.fromJson(data))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadMatchExchanges();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Ad'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          // Use Column to stack the text and ListView
          children: [
            const Text(
              'Swipe left to receive and right to pay',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    Colors.black54, // Optional: Change the color to your liking
              ),
            ),
            const SizedBox(
                height: 20), // Add some space between the text and the ListView
            Expanded(
              // Use Expanded to allow ListView to take the remaining space
              child: _matchExchanges.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _matchExchanges.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: Key(_matchExchanges[index].id), // or any unique id
                          direction: DismissDirection.horizontal,
                          onDismissed: (direction) {
                            MatchExchange selectedExchange = _matchExchanges[index]; // Get the selected exchange
                            
                            String role;
                            if (direction == DismissDirection.startToEnd) {
                              role = "PAYER"; // Swiped right
                            } else {
                              role = "RECEIVER"; // Swiped left
                            }

                            // Create a map with the data you want to pass
                            Map<String, dynamic> args = {
                              'role': role,
                              'id': (index+1).toString(),
                              'fromCurrency': selectedExchange.fromCurrency,
                              'toCurrency': selectedExchange.toCurrency,
                              'fromAmount': selectedExchange.fromAmount,
                              'toAmount': selectedExchange.toAmount,
                              'fromDate': selectedExchange
                                  .fromDate, // Assuming you have these properties
                              'toDate': selectedExchange.toDate,
                              'location': selectedExchange
                                  .location, // Assuming you have a location property
                            };

                            // Navigate to CashCheckoutScreen with arguments
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CashCheckoutScreen(),
                                settings: RouteSettings(arguments: args),
                              ),
                            );
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  ' PAY',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 8), // Space between text and icon
                                Icon(Icons.arrow_left, color: Colors.white),
                              ],
                            ),
                          ),
                          secondaryBackground: Container(
                            color: Colors.green,
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: const [
                                Icon(Icons.arrow_right, color: Colors.white),
                                SizedBox(width: 8), // Space between icon and text
                                Text(
                                  'RECEIVE ',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          child: Card(
                            child: ListTile(
                              title: Text(_matchExchanges[index].name),
                              subtitle: Text(
                                  'From: ${_matchExchanges[index].fromCurrency} to ${_matchExchanges[index].toCurrency}, Amount: ${_matchExchanges[index].fromAmount} to ${_matchExchanges[index].toAmount}, Due Date: ${_matchExchanges[index].toDate}'),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
