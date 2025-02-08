import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:xchange_app/login_state.dart';
import 'package:http/http.dart' as http;
import 'package:xchange_app/match_exchange.dart';
import 'package:xchange_app/qr_code_content.dart';

class CashCheckoutNearbyScreen extends StatefulWidget {
  const CashCheckoutNearbyScreen({super.key});

  @override
  State<CashCheckoutNearbyScreen> createState() =>
      _CashCheckoutNearbyScreenState();
}

class _CashCheckoutNearbyScreenState extends State<CashCheckoutNearbyScreen> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  var role = '';
  final TextEditingController name = TextEditingController();
  TextEditingController toAmount = TextEditingController();
  TextEditingController fromAmount = TextEditingController();
  TextEditingController toCurrency = TextEditingController();
  TextEditingController fromCurrency = TextEditingController();
  final TextEditingController fromDate = TextEditingController();
  final TextEditingController toDate = TextEditingController();
  final TextEditingController location = TextEditingController();
  String? selectedUser, profileImageUrl, walletId, toWalletId, id;
  List<MatchExchange> _matchExchanges = [];
  bool isVerified = false;
  bool _isSending = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieve arguments passed from the previous screen
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    setState(() {
      id = args['id'];
      selectedUser = args['selectedUser'];
      walletId = args['walletId'];
      location.text = args['location'];
      fromCurrency.text = args['fromCurrency'] ?? '';
      toCurrency.text = args['toCurrency'] ?? '';
      fromAmount.text = args['fromAmount'] ?? '';
      toAmount.text = args['toAmount'] ?? '';
      isVerified = args['isVerified'] ?? false;
    });
    print("selectedMatch");
    print(id);
    _getExchangeRate();
  }

  @override
  void initState() {
    super.initState();

    // Show dialog on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInitDialog();
    });
  }

  Future<double> _getExchangeRate() async {
    var url = Uri.http('app01.karnetif.com', '/exchange-rate');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fromCurrency': toCurrency.text,
        'toCurrency': fromCurrency.text,
      }),
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        try {
          final amount = double.parse(toAmount.text);
          final rate = jsonData['exchangeRate'].toDouble();
          final result = amount * rate;
          fromAmount.text = result.toStringAsFixed(2);
        } catch (e) {
          toAmount.text = '0.00';
          print('Error calculating exchange rate: $e');
        }
      });
      return jsonData['exchangeRate'];
    } else {
      throw Exception('Failed to load exchange rate');
    }
  }

  void _showInitDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("ATTENTION !!"),
          content: const Text(
              "Please ensure that the currency exchange details are correct before proceeding."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cash Checkout"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Currency you want",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      controller: toCurrency,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      controller: toAmount,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Currency you have",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      controller: fromCurrency,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      controller: fromAmount,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                "Ad Details",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Image
                  CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        profileImageUrl != null && profileImageUrl!.isNotEmpty
                            ? NetworkImage(profileImageUrl!)
                            : const AssetImage('assets/profile_sample.png')
                                as ImageProvider,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(
                      width: 16), // Add spacing between the image and text
                  // User Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedUser.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4), // Spacing between the texts
                      Text(
                        walletId!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location.text,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 50),
              const Text(
                "Exchange Payment",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Exchange Payment"),
                  Text(toAmount.text),
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Tax Charges"),
                  Text("-"),
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Service Fee"),
                  Text("-"),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("TOTAL"),
                  Text(toAmount.text),
                ],
              ),
              const SizedBox(height: 50),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Confirm Button
                    ElevatedButton.icon(
                      onPressed: _isSending
                          ? null
                          : () async {
                              // Disable button when sending
                              setState(() {
                                _isSending = true; // Prevent multiple requests
                              });

                              var user = await LoginState.getUserData();

                              try {
                                var response = await http.post(
                                  Uri.parse(
                                      'http://app01.karnetif.com/send-message'),
                                  headers: {'Content-Type': 'application/json'},
                                  body: jsonEncode({
                                    'to': selectedUser.toString(),
                                    'title': "Let's Xchange!",
                                    'body':
                                        'Hi I`m ${user?['name']}, \nCan we make currency exchange ${fromAmount.text} ${fromCurrency.text} with ${toAmount.text} ${toCurrency.text}',
                                    'dataQr': jsonEncode({
                                      'from': user?['name'],
                                      'walletId': user?['walletId'],
                                      'to': selectedUser.toString(),
                                      'toWalletId': walletId.toString(),
                                      'fromCurrency': fromCurrency.text,
                                      'toCurrency': toCurrency.text,
                                      'fromAmount': fromAmount.text,
                                      'toAmount': toAmount.text,
                                      'location': location.text
                                    }),
                                  }),
                                );

                                if (response.statusCode == 200) {
                                  Navigator.pushNamed(context, '/qrSnap',
                                      arguments: {
                                        'from': user!['name'],
                                        'walletId': user['walletId'],
                                        'to': selectedUser.toString(),
                                        'toWalletId': toWalletId.toString(),
                                        'fromCurrency': fromCurrency.text,
                                        'toCurrency': toCurrency.text,
                                        'fromAmount': fromAmount.text,
                                        'toAmount': toAmount.text,
                                        'location': location.text
                                      });
                                } else {
                                  Fluttertoast.showToast(
                                    msg:
                                        "Failed to send confirmation. Please try again.",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                  );
                                }
                              } catch (error) {
                                Fluttertoast.showToast(
                                  msg: "An error occurred: $error",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                );
                              } finally {
                                setState(() {
                                  _isSending =
                                      false; // Re-enable button after request completes
                                });
                              }
                            },
                      icon: const Icon(Icons.check, size: 20),
                      label: const Text('Confirm',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        backgroundColor: Colors.green,
                      ),
                    ),
                    // Cancel Button
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/wallet');
                      },
                      icon: const Icon(Icons.cancel, size: 20),
                      label: const Text('Cancel',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
