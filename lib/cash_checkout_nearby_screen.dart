import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:xchange_app/login_state.dart';
import 'package:http/http.dart' as http;
import 'package:xchange_app/match_exchange.dart';

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
  final TextEditingController walletId = TextEditingController();
  TextEditingController toAmount = TextEditingController();
  TextEditingController fromAmount = TextEditingController();
  TextEditingController toCurrency = TextEditingController();
  TextEditingController fromCurrency = TextEditingController();
  final TextEditingController fromDate = TextEditingController();
  final TextEditingController toDate = TextEditingController();
  final TextEditingController location = TextEditingController();
  List<MatchExchange> _matchExchanges = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieve arguments passed from the previous screen
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    print("Args received: $args");

    setState(() {
      final selectedUser = args['selectedUser'];
      fromCurrency.text = args['fromCurrency'] ?? '';
      toCurrency.text = args['toCurrency'] ?? '';
      fromAmount.text = args['fromAmount'] ?? '';
      toAmount.text = args['toAmount'] ?? '';

      print("Selected user: $selectedUser (args: ${fromCurrency.text})");

      if (selectedUser is Set) {
        final user = selectedUser.first as Map<String, dynamic>;
        _setData(user, fromCurrency, toCurrency, fromAmount, toAmount);
        _getLocation();
      } else if (selectedUser is Map<String, dynamic>) {
        _setData(selectedUser, fromCurrency, toCurrency, fromAmount, toAmount);
      } else {
        print(
            "Invalid data type for selectedUser: ${selectedUser.runtimeType}");
      }
    });
  }

  Future<void> _setData(
      dynamic users,
      TextEditingController fromCurrency,
      TextEditingController toCurrency,
      TextEditingController fromAmount,
      TextEditingController toAmount) async {
    try {
      if (users.isNotEmpty) {
        // Example of setting text fields from the first user in the list
        setState(() {
          // Assuming you want to set the first user's details in the fields
          name.text = users['username'] ?? '';
          walletId.text = users['walletId'] ?? '';
          toCurrency.text = toCurrency.text ?? '';
          fromCurrency.text = users[0]['from_currency'] ?? '';
          toAmount.text = users[0]['to_amount']?.toString() ?? '';
          fromAmount.text = users[0]['from_amount']?.toString() ?? '';
          fromDate.text = users[0]['from_date'] ?? '';
          toDate.text = users[0]['to_date'] ?? '';
          location.text = users[0]['location'] ?? '';
        });
      }
    } catch (e) {
      // Handle any exceptions
      print("Error fetching post data: $e");
    }
  }

  Future<void> _getLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Fluttertoast.showToast(msg: 'Location services are disabled.');
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Fluttertoast.showToast(msg: 'Location permissions are denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Fluttertoast.showToast(
            msg:
                'Location permissions are permanently denied, we cannot request permissions.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      location.text = "${position.latitude}, ${position.longitude}";
    } catch (e) {
      print("Error fetching location data: $e");
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
              // Row(
              //   children: [
              //     Expanded(
              //       child: Row(
              //         children: [
              //           Expanded(
              //             child: GestureDetector(
              //               onTap: () async {
              //                 // Show date picker dialog
              //                 final DateTimeRange? dates =
              //                     await showDateRangePicker(
              //                   context: context,
              //                   firstDate: DateTime(2022),
              //                   lastDate: DateTime(2030),
              //                 );
              //                 if (dates != null) {
              //                   // Update date_from and date_to text fields
              //                   fromDate.text = dates.start.toString();
              //                   toDate.text = dates.end.toString();
              //                 }
              //               },
              //               child: AbsorbPointer(
              //                 child: TextField(
              //                   controller: fromDate,
              //                   decoration: const InputDecoration(
              //                     labelText: "Date From",
              //                     border: OutlineInputBorder(),
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           ),
              //           const SizedBox(width: 10),
              //           Expanded(
              //             child: AbsorbPointer(
              //               child: TextField(
              //                 controller: toDate,
              //                 decoration: const InputDecoration(
              //                   labelText: "Date To",
              //                   border: OutlineInputBorder(),
              //                 ),
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //     const SizedBox(width: 10),
              //     Expanded(
              //       child: Row(
              //         children: [
              //           const SizedBox(width: 10),
              //           Expanded(
              //             child: Stack(
              //               children: [
              //                 TextField(
              //                   readOnly: true,
              //                   decoration: const InputDecoration(
              //                     labelText: "Location",
              //                     border: OutlineInputBorder(),
              //                   ),
              //                   controller: location,
              //                 ),
              //                 Positioned(
              //                     right: 0,
              //                     child: IconButton(
              //                       icon: const Icon(Icons.location_on),
              //                       onPressed: () async {
              //                         bool serviceEnabled;
              //                         LocationPermission permission;

              //                         serviceEnabled = await Geolocator
              //                             .isLocationServiceEnabled();
              //                         if (!serviceEnabled) {
              //                           Fluttertoast.showToast(
              //                               msg:
              //                                   'Location services are disabled.');
              //                           return;
              //                         }

              //                         permission =
              //                             await Geolocator.checkPermission();
              //                         if (permission ==
              //                             LocationPermission.denied) {
              //                           permission = await Geolocator
              //                               .requestPermission();
              //                           if (permission ==
              //                               LocationPermission.denied) {
              //                             Fluttertoast.showToast(
              //                                 msg:
              //                                     'Location permissions are denied.');
              //                             return;
              //                           }
              //                         }

              //                         if (permission ==
              //                             LocationPermission.deniedForever) {
              //                           Fluttertoast.showToast(
              //                               msg:
              //                                   'Location permissions are permanently denied, we cannot request permissions.');
              //                           return;
              //                         }

              //                         final position =
              //                             await Geolocator.getCurrentPosition(
              //                                 desiredAccuracy:
              //                                     LocationAccuracy.high);
              //                         location.text =
              //                             "${position.latitude}, ${position.longitude}";
              //                       },
              //                     ))
              //               ],
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Generate QR Code Button
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.qr_code,
                              size: 40), // QR Code icon
                          onPressed: () {
                            Navigator.pushNamed(context, '/qrView', arguments: {
                              'id': "",
                              'role': "",
                              'name': name.text,
                              'walletId': walletId.text,
                              'fromCurrency': fromCurrency.text,
                              'toCurrency': toCurrency.text,
                              'fromAmount': fromAmount.text,
                              'toAmount': toAmount.text,
                              'fromDate': fromDate.text,
                              'toDate': toDate.text,
                              'location': location.text,
                            });
                          },
                        ),
                        const Text(
                          "Generate QR Code",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    // Snap Proof Button
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.camera_alt,
                              size: 40), // Camera icon
                          onPressed: () {
                            Navigator.pushNamed(context, '/qrSnap', arguments: {
                              'name': name.text,
                              'walletId': walletId.text,
                              'fromCurrency': fromCurrency.text,
                              'toCurrency': toCurrency.text,
                              'fromAmount': fromAmount.text,
                              'toAmount': toAmount.text,
                              'fromDate': fromDate.text,
                              'toDate': toDate.text,
                              'location': location.text,
                            });
                          },
                        ),
                        const Text(
                          "Snap Proof",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/receipt');
                      },
                      child: const Text('Pay'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/wallet');
                      },
                      child: const Text('Cancel'),
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
