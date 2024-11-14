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
    var url = Uri.http("192.168.8.106:3000", '/postAd/queryAll');
    var response = await http.get(url);
  final jsonData = jsonDecode(response.body);
  setState(() {
    _matchExchanges = jsonData.map<MatchExchange>((data) => MatchExchange.fromJson(data)).toList();
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
        title: const Text('Transaction History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _matchExchanges.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _matchExchanges.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(_matchExchanges[index].role), // or any unique id
                    direction: DismissDirection.horizontal,
                    onDismissed: (direction) {
                      if (direction == DismissDirection.startToEnd) {
                        // Go to other page with
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CashCheckoutScreen()),
                        );
                      } else if (direction == DismissDirection.endToStart) {
                        // Go to other page to
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CashCheckoutScreen()),
                        );
                      }
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      child: const Icon(Icons.arrow_left, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      color: Colors.green,
                      alignment: Alignment.centerRight,
                      child: const Icon(Icons.arrow_right, color: Colors.white),
                    ),
                    child: Card(
                      child: ListTile(
                        title: Text(_matchExchanges[index].name),
                        subtitle: Text('From: ${_matchExchanges[index].fromCurrency} to ${_matchExchanges[index].toCurrency}, Amount: ${_matchExchanges[index].fromAmount} to ${_matchExchanges[index].toAmount}, Due Date: ${_matchExchanges[index].toDate}'),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}