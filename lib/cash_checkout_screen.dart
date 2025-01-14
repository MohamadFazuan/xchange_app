import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:xchange_app/login_state.dart';
import 'package:http/http.dart' as http;
import 'package:xchange_app/match_exchange.dart';

class CashCheckoutScreen extends StatefulWidget {
  const CashCheckoutScreen({super.key});

  @override
  State<CashCheckoutScreen> createState() => _CashCheckoutScreenState();
}

class _CashCheckoutScreenState extends State<CashCheckoutScreen> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  var role = '';
  final TextEditingController name = TextEditingController();
  final TextEditingController walletId = TextEditingController();
  final TextEditingController toAmount = TextEditingController();
  final TextEditingController fromAmount = TextEditingController();
  final TextEditingController toCurrency = TextEditingController();
  final TextEditingController fromCurrency = TextEditingController();
  final TextEditingController fromDate = TextEditingController();
  final TextEditingController toDate = TextEditingController();
  final TextEditingController location = TextEditingController();
  List<MatchExchange> _matchExchanges = [];

  String? selectedId; // To hold the ID passed from TransactionScreen
  Map<String, dynamic>? postData; // To hold the queried post data

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieve arguments passed from the TransactionScreen
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // Set the values from the arguments
    setState(() {
      selectedId = args['id']; // Retrieve the selected ID
    });

    setState(() {
      role = args['role']; // Retrieve the selected ID
    });

    // Call the method to fetch data from the database
    if (selectedId != null) {
      _fetchPostData(selectedId!);
    }
  }

  Future<void> _fetchPostData(String id) async {
    try {
      var url = Uri.http("app01.karnetif.com", '/postAd/queryById', {'id': id});
      var response = await http.get(url);

      if (response.statusCode == 200) {
        // Decode the JSON response into a Map
        final Map<String, dynamic> postData = jsonDecode(response.body);

        setState(() {
          // Set the text fields with the queried data
          name.text = postData['name'] ?? '';
          walletId.text = postData['walletId'] ?? '';
          toCurrency.text = postData['to_currency'] ?? '';
          fromCurrency.text = postData['from_currency'] ?? '';
          toAmount.text = postData['to_amount']?.toString() ?? '';
          fromAmount.text = postData['from_amount']?.toString() ?? '';
          fromDate.text = postData['from_date'] ?? '';
          toDate.text = postData['to_date'] ?? '';
          location.text = postData['location'] ?? '';
        });
      } else {
        // Handle non-200 status codes
        print("Failed to load post data: ${response.statusCode}");
      }
    } catch (e) {
      // Handle any exceptions
      print("Error fetching post data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: const Text("Post Ad"),
          // leading: IconButton(
          //   onPressed: () {
          //     Navigator.pop(context);
          //   },
          //   icon: const Icon(Icons.arrow_back),
          // ),
          ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Cash Checkout",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
              const SizedBox(height: 20),
              const Text(
                "Ad Details",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                readOnly: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                controller: name,
              ),
              const SizedBox(height: 10),
              TextField(
                readOnly: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                controller: walletId,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              // Show date picker dialog
                              final DateTimeRange? dates =
                                  await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2022),
                                lastDate: DateTime(2030),
                              );
                              if (dates != null) {
                                // Update date_from and date_to text fields
                                fromDate.text = dates.start.toString();
                                toDate.text = dates.end.toString();
                              }
                            },
                            child: AbsorbPointer(
                              child: TextField(
                                controller: fromDate,
                                decoration: const InputDecoration(
                                  labelText: "Date From",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AbsorbPointer(
                            child: TextField(
                              controller: toDate,
                              decoration: const InputDecoration(
                                labelText: "Date To",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Expanded(
                          child: Stack(
                            children: [
                              TextField(
                                readOnly: true,
                                decoration: const InputDecoration(
                                  labelText: "Location",
                                  border: OutlineInputBorder(),
                                ),
                                controller: location,
                              ),
                              Positioned(
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.location_on),
                                    onPressed: () async {
                                      bool serviceEnabled;
                                      LocationPermission permission;

                                      serviceEnabled = await Geolocator
                                          .isLocationServiceEnabled();
                                      if (!serviceEnabled) {
                                        Fluttertoast.showToast(
                                            msg:
                                                'Location services are disabled.');
                                        return;
                                      }

                                      permission =
                                          await Geolocator.checkPermission();
                                      if (permission ==
                                          LocationPermission.denied) {
                                        permission = await Geolocator
                                            .requestPermission();
                                        if (permission ==
                                            LocationPermission.denied) {
                                          Fluttertoast.showToast(
                                              msg:
                                                  'Location permissions are denied.');
                                          return;
                                        }
                                      }

                                      if (permission ==
                                          LocationPermission.deniedForever) {
                                        Fluttertoast.showToast(
                                            msg:
                                                'Location permissions are permanently denied, we cannot request permissions.');
                                        return;
                                      }

                                      final position =
                                          await Geolocator.getCurrentPosition(
                                              desiredAccuracy:
                                                  LocationAccuracy.high);
                                      location.text =
                                          "${position.latitude}, ${position.longitude}";
                                    },
                                  ))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomCenter,
                child: role == "RECEIVER"
                    ? ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/qrView', arguments: {
                            'role': "RECEIVER",
                            'name': name,
                            'walletId': walletId,
                            'fromCurrency': fromCurrency,
                            'toCurrency': toCurrency,
                            'fromAmount': fromAmount,
                            'toAmount': toAmount,
                            'fromDate': fromDate,
                            'toDate': toDate,
                            'location': location
                          });
                        },
                        child: const Text("Generate QR Code"),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/qrSnap', arguments: {
                            'role': "PAYER",
                            'name': name.text,
                            'walletId': walletId.text,
                            'fromCurrency': fromCurrency.text,
                            'toCurrency': toCurrency.text,
                            'fromAmount': fromAmount.text,
                            'toAmount': toAmount.text,
                            'fromDate': fromDate.text,
                            'toDate': toDate.text,
                            'location': location.text
                          });
                        },
                        child: const Text("Snap Proof"),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
