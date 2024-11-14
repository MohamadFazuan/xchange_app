import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:xchange_app/match_exchange.dart';

class MatchExchangeScreen extends StatefulWidget {
  const MatchExchangeScreen({super.key});

  @override
  _MatchScreenState createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchExchangeScreen> {
  List<MatchExchange> _matchExchanges = [];

  Future<void> _loadMatchExchanges() async {
    var url = Uri.http("192.168.8.106:3000", '/postAd/queryAll');
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
        title: const Text('Cash Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _matchExchanges.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _matchExchanges.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(_matchExchanges[index].name),
                    direction: DismissDirection.horizontal,
                    onDismissed: (direction) {
                      if (direction == DismissDirection.startToEnd) {
                        Navigator.pushNamed(context, '/checkout', arguments: {
                          'role': "RECEIVER",
                          'fromCurrency': _matchExchanges[index].fromCurrency,
                          'toCurrency': _matchExchanges[index].toCurrency,
                          'fromAmount': _matchExchanges[index].fromAmount,
                          'toAmount': _matchExchanges[index].toAmount,
                          'fromDate': _matchExchanges[index].fromDate,
                          'toDate': _matchExchanges[index].toDate,
                          'location': _matchExchanges[index].location
                        });
                        
                      } else if (direction == DismissDirection.endToStart) {
                        Navigator.pushNamed(context, '/checkout', arguments: {
                          'role': "SENDER",
                          'fromCurrency': _matchExchanges[index].fromCurrency,
                          'toCurrency': _matchExchanges[index].toCurrency,
                          'fromAmount': _matchExchanges[index].fromAmount,
                          'toAmount': _matchExchanges[index].toAmount,
                          'fromDate': _matchExchanges[index].fromDate,
                          'toDate': _matchExchanges[index].toDate,
                          'location': _matchExchanges[index].location
                        });
                      }
                    },
                    background: Container(
                      color: Colors.green,
                      alignment: Alignment.centerRight,
                      child: const Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.arrow_right, color: Colors.white),
                            Text('Receiver',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('Sender',
                                style: TextStyle(color: Colors.white)),
                            Icon(Icons.arrow_left, color: Colors.white),
                          ],
                        ),
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
    );
  }
}
