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
import 'package:xchange_app/post_model.dart';
import 'package:xchange_app/transaction_model.dart';

class PostDrawerScreen extends StatefulWidget {
  const PostDrawerScreen({super.key});

  @override
  _PostDrawerScreenState createState() => _PostDrawerScreenState();
}

class _PostDrawerScreenState extends State<PostDrawerScreen> {
  List<Post> _post = [];
  String? username;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final userData = await LoginState.getUserData();

    setState(() {
      username = userData?['name'];
    });
    _loadMatchExchanges();
  }

  String formatSqlDate(String sqlDate) {
    // Parse the SQL date string into a DateTime object
    DateTime parsedDate = DateTime.parse(sqlDate);

    // Format the date in a human-readable format (e.g., "Jan 16, 2025")
    String formattedDate = DateFormat('MMM dd, yyyy').format(parsedDate);

    return formattedDate;
  }

  Future<void> _loadMatchExchanges() async {
    try {
      var url = Uri.http('app01.karnetif.com', '/postAd/queryByUser');
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"username": username}),
      );

      if (response.statusCode == 200) {
        final dynamic jsonData = jsonDecode(response.body);
        if (jsonData is List) {
          setState(() {
            _post = jsonData.map<Post>((data) => Post.fromJson(data)).toList();
          });
        } else {
          print('Invalid response format');
        }
      }
    } catch (e) {
      print('Error loading posts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          // Use Column to stack the text and ListView
          children: [
            Text("Click list to edit"),
            Expanded(
              // Use Expanded to allow ListView to take the remaining space
              child: _post.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _post.length,
                      itemBuilder: (context, index) {
                        final selectedMatch = _post[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/post', arguments: {
                              'isEdit': true,
                              'role': "SENDER",
                              'id': selectedMatch.id,
                              'fromCurrency': selectedMatch.fromCurrency,
                              'toCurrency': selectedMatch.toCurrency,
                              'fromAmount': selectedMatch.fromAmount,
                              'toAmount': selectedMatch.toAmount,
                              'fromDate': selectedMatch.fromDate,
                              'toDate': selectedMatch.toDate,
                              'name': selectedMatch.name,
                              'walletId': selectedMatch.walletId,
                            });
                          },
                          child: Card(
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
                                            'Name: ${selectedMatch.name}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            'ID: ${selectedMatch.walletId}',
                                            style: const TextStyle(
                                              fontSize: 10,
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
                                      height:
                                          16), // Add spacing between sections
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
                                                  size: 18,
                                                  color: Colors.green),
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
                                                    selectedMatch.toDate),
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
