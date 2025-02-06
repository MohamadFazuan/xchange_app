import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:xchange_app/cash_checkout_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:xchange_app/login_state.dart';
import 'dart:convert';

import 'package:xchange_app/match_exchange.dart';

class PostedAd extends StatefulWidget {
  const PostedAd({super.key});

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<PostedAd> {
  List<MatchExchange> _matchExchanges = [];
  String? toCurrency, fromCurrency, fromAmount, toAmount, selectedUser;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    // Retrieve arguments passed from the TransactionScreen
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    setState(() {
      fromCurrency = args['fromCurrency'];
      toCurrency = args['toCurrency'];
      fromAmount = args['fromAmount'];
      toAmount = args['toAmount'];
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
      // Parse `toAmount` to an integer
      final double parsedDouble = double.parse(toAmount.toString());
      final int parsedAmount = parsedDouble.round();

      if (parsedAmount <= 0) {
        throw Exception("Invalid amount provided");
      }

      var url = Uri.http('app01.karnetif.com', '/postAd/queryByExchange');
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "from": fromCurrency.toString(),
          "to": toCurrency.toString(),
          "fromAmount": fromAmount.toString(),
          "toAmount": toAmount.toString(),
        }),
      );

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);

        // Get the logged-in user's name
        final userData = await LoginState.getUserData();
        final String? loggedInUserName = userData?['name'];

        // Filter out exchanges with a matching name
        final filteredExchanges = jsonData
            .map<MatchExchange>((data) => MatchExchange.fromJson(data))
            .toList();

        setState(() {
          _matchExchanges = filteredExchanges;
        });
      } else {
        throw Exception("Failed to load data: ${response.body}");
      }
    } catch (error) {
      debugPrint("Error loading match exchanges: $error");
      setState(() {
        _matchExchanges = []; // Clear previous data in case of error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Nearby'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          // Use Column to stack the text and ListView
          children: [
            Expanded(
                // Use Expanded to allow ListView to take the remaining space
                child: _matchExchanges.isEmpty
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset('assets/no_ads.png', width: 200),
                                const SizedBox(height: 16),
                                const Text(
                                  "No Ads Found",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        itemCount: _matchExchanges.length,
                        itemBuilder: (context, index) {
                          final selectedMatch = _matchExchanges[index];

                          return Card(
                            child: Card(
                              // margin: const EdgeInsets.symmetric(
                              //     vertical: 8, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              // elevation: 4,
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Column(
                                  children: [
                                    Text(
                                      selectedMatch.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      selectedMatch.walletId,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on,
                                            size: 16, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Location: ${selectedMatch.location}',
                                          style: const TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.currency_exchange,
                                            size: 16, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Currency: ${selectedMatch.fromCurrency} → ${selectedMatch.toCurrency}',
                                          style: const TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.monetization_on,
                                            size: 16, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Amount: ${selectedMatch.fromAmount} ${selectedMatch.fromCurrency} → ${selectedMatch.toAmount} ${selectedMatch.toCurrency}',
                                          style: const TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            size: 16, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Due Date: ${formatSqlDate(selectedMatch.toDate)}',
                                          style: const TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 16, color: Colors.grey),
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, '/checkout/nearby',
                                      arguments: {
                                        'id': selectedMatch.id,
                                        'selectedUser': selectedMatch.name,
                                        'walletId': selectedMatch.walletId,
                                        'location': selectedMatch.location,
                                        'fromCurrency':
                                            selectedMatch.fromCurrency,
                                        'toCurrency': selectedMatch.toCurrency,
                                        'fromAmount': selectedMatch.fromAmount,
                                        'toAmount': selectedMatch.toAmount,
                                      });
                                },
                              ),
                            ),
                          );
                        },
                      )),
          ],
        ),
      ),
    );
  }
}
