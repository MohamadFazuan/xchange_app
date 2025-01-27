import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:xchange_app/login_state.dart';
import 'package:http/http.dart' as http;
import 'package:xchange_app/match_exchange.dart';
import 'package:xchange_app/qr_code_content.dart';

class CashCheckoutScreen extends StatefulWidget {
  const CashCheckoutScreen({super.key});

  @override
  State<CashCheckoutScreen> createState() => _CashCheckoutScreenState();
}

class _CashCheckoutScreenState extends State<CashCheckoutScreen> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  var role = '';
  TextEditingController toAmount = TextEditingController();
  TextEditingController fromAmount = TextEditingController();
  TextEditingController toCurrency = TextEditingController();
  TextEditingController fromCurrency = TextEditingController();
  final TextEditingController fromDate = TextEditingController();
  final TextEditingController toDate = TextEditingController();
  final TextEditingController location = TextEditingController();
  String? from, to, walletId, toWalletId, profileImageUrl, id;
  List<MatchExchange> _matchExchanges = [];
  bool isVerified = false;
  late Map<String, dynamic> expectedArgs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieve arguments passed from the previous screen
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        print("CashCheckoutScreen");
    print(args);

    setState(() {
      from = args['from'];
      walletId = args['walletId'];
      to = args['to'];
      toWalletId = args['toWalletId'];
      location.text = args['location'];
      if (args['role'] == 'RECEIVER') {
        fromCurrency.text = args['fromCurrency'] ?? '';
        toCurrency.text = args['toCurrency'] ?? '';
        fromAmount.text = args['fromAmount'] ?? '';
        toAmount.text = args['toAmount'] ?? '';
      } else {
        fromCurrency.text = args['toCurrency'] ?? '';
        toCurrency.text = args['fromCurrency'] ?? '';
        fromAmount.text = args['toAmount'] ?? '';
        toAmount.text = args['fromAmount'] ?? '';
      }
      expectedArgs = args['decodedData'];
      isVerified = args['isVerified'] ?? false;
      role = args['role'];
    });
  }

  @override
  void initState() {
    super.initState();

    // Show dialog on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInitDialog();
    });
  }

  Future<bool> _addTransaction(Map<String, dynamic> data) async {
    print(" add Transaction data");
    print(data);

    try {
      // Add transaction
      var transactionUrl = Uri.http('192.168.0.20:3000', '/transaction/add');
      var transactionResponse = await http.post(
        transactionUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "from": data['from'],
          "to": data['to'],
          "fromCurrency": data['fromCurrency'],
          "toCurrency": data['toCurrency'],
          "fromAmount": data['fromAmount'],
          "toAmount": data['toAmount'],
        }),
      );
      print(transactionResponse.statusCode);
      if (transactionResponse.statusCode == 201) {
        // Delete post after successful transaction
        var deleteUrl = Uri.http(
            '192.168.0.20:3000', '/postAd/delete/${expectedArgs['id']}');
        var deleteResponse = await http.post(
          deleteUrl,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({"id": data['id']}),
        );
        if (deleteResponse.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Transaction completed successfully!')),
          );
          return true;
        } else {
          print('Failed to delete post: ${deleteResponse.body}');
        }
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to add transaction: ${transactionResponse.body}')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      return false;
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
                "Currency Exchange",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Currency',
                          ),
                          controller: fromCurrency,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Amount',
                          ),
                          controller: fromAmount,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.currency_exchange,
                          size: 30,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Currency',
                          ),
                          controller: toCurrency,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Amount',
                          ),
                          controller: toAmount,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                "Details",
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
                        from.toString(),
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
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
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
                        to.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4), // Spacing between the texts
                      Text(
                        toWalletId!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
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
                  Text(fromAmount.text),
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
                  Text(fromAmount.text),
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
                      onPressed: () async {
                        var user = await LoginState.getUserData();

                        try {
                          _addTransaction(expectedArgs);
                          // Navigate to Receipt Screen
                          Navigator.pushNamed(context, '/receipt', arguments: {
                            'id': id,
                            'from': from.toString(),
                            'walletId': walletId,
                            'to': to.toString(),
                            'toWalletId': toWalletId.toString(),
                            'fromCurrency': fromCurrency.text,
                            'toCurrency': toCurrency.text,
                            'fromAmount': fromAmount.text,
                            'toAmount': toAmount.text,
                          });
                        } catch (error) {
                          Fluttertoast.showToast(
                            msg: "An error occurred: $error",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                          );
                        }
                      },
                      icon: const Icon(Icons.check, size: 20),
                      label: const Text('Pay',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: Colors.blue,
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
