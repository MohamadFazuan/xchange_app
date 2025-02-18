import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:xchange_app/cash_checkout_screen.dart';
import 'package:xchange_app/login_screen.dart';
import 'package:xchange_app/login_state.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:xchange_app/match_exchange.dart';
import 'package:xchange_app/transaction_model.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  List<Transaction> _transaction = [];
  String? name;
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchUserAndTransactions();
  }

  Future<void> _fetchUserAndTransactions() async {
    final userData = await LoginState.getUserData();
    
    if (userData != null) {
      setState(() {
        name = userData['name'];
      });
      await _loadMatchExchanges(); // Fetch transactions after name is set
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String formatSqlDate(String sqlDate) {
    // Parse the SQL date string into a DateTime object
    DateTime parsedDate = DateTime.parse(sqlDate);

    // Format the date in a human-readable format (e.g., "Jan 16, 2025")
    String formattedDate = DateFormat('MMM dd, yyyy').format(parsedDate);

    return formattedDate;
  }

  Future<void> _loadMatchExchanges() async {
    var url = Uri.http('app01.karnetif.com', '/transaction/query');
    var response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"name": name}));
    final dynamic jsonData = jsonDecode(response.body);
    setState(() {
      if (jsonData is List) {
          setState(() {
            _transaction = jsonData.map<Transaction>((data) => Transaction.fromJson(data)).toList()..sort((a, b) => DateTime.parse(b.timestamp)
                .compareTo(DateTime.parse(a.timestamp)));;
          });
        } else {
          print('Invalid response format');
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          // Use Column to stack the text and ListView
          children: [
            Expanded(
              // Use Expanded to allow ListView to take the remaining space
              child: _transaction.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _transaction.length,
                      itemBuilder: (context, index) {
                        final selectedMatch = _transaction[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 0), // Add spacing between cards
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation:
                              4, // Add slight shadow for better visual effect
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'From: ${selectedMatch.from}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          'To: ${selectedMatch.to}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      Icons.currency_exchange,
                                      size: 28,
                                      color: Colors.blueAccent,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                    height: 16), // Add spacing between sections
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.attach_money,
                                                size: 18, color: Colors.green),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${selectedMatch.fromAmount} ${selectedMatch.fromCurrency}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.arrow_forward,
                                                size: 18, color: Colors.grey),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${selectedMatch.toAmount} ${selectedMatch.toCurrency}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today,
                                                size: 18, color: Colors.grey),
                                            const SizedBox(width: 8),
                                            Text(
                                              formatSqlDate(
                                                  selectedMatch.timestamp),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
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
