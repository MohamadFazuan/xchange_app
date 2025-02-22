import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:xchange_app/login_state.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:xchange_app/match_screen.dart';
import 'package:xchange_app/wallet_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PostAdScreen extends StatefulWidget {
  const PostAdScreen({super.key});

  @override
  State<PostAdScreen> createState() => _PostAdScreenState();
}

class _PostAdScreenState extends State<PostAdScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController name = TextEditingController();
  final TextEditingController walletId = TextEditingController();
  final TextEditingController toAmount = TextEditingController();
  final TextEditingController fromAmount = TextEditingController();
  final TextEditingController toCurrency = TextEditingController();
  final TextEditingController fromCurrency = TextEditingController();
  final TextEditingController fromDate = TextEditingController();
  final TextEditingController toDate = TextEditingController();
  final TextEditingController location = TextEditingController();
  String? _exchangeAmount, _amount;
  int? id;
  bool isEdit = false;

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();

    final userData = await LoginState.getUserData();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    setState(() {
      isEdit = args['isEdit'];
      id = args['id'];
      fromCurrency.text = args['fromCurrency'];
      toCurrency.text = args['toCurrency'];
      fromAmount.text = args['fromAmount'];
      toAmount.text = args['toAmount'];
      name.text = userData!['name'];
      walletId.text = userData['walletId'];
      fromDate.text = userData['fromDate'];
      toDate.text = userData['toDate'];
    });
    _updateExchangeAmount();
  }

  Future postAd(
      String fromCurrency,
      String fromAmount,
      String toCurrency,
      String toAmount,
      String name,
      String walletId,
      String fromDate,
      String toDate,
      String location,
      String exchangePayment,
      String taxCharges,
      String serviceFee,
      String total) async {
    var url = Uri.http('app01.karnetif.com', '/postAd/add');
    var response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "fromCurrency": fromCurrency,
          "toCurrency": toCurrency,
          "fromAmount": fromAmount,
          "toAmount": toAmount,
          "name": name,
          "walletId": walletId,
          "fromDate": fromDate,
          "toDate": toDate,
          "location": location,
          "exchangePayment": exchangePayment,
          "taxCharges": taxCharges,
          "serviceFee": serviceFee,
          "total": total
        }));
    Map<String, dynamic> data = json.decode(response.body);

    if (data["message"] == "Failed to post") {
      Fluttertoast.showToast(
        backgroundColor: Colors.orange,
        textColor: Colors.white,
        msg: 'Failed to post!',
        toastLength: Toast.LENGTH_SHORT,
      );
    } else {
      Fluttertoast.showToast(
        backgroundColor: Colors.green,
        textColor: Colors.white,
        msg: 'Posted',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WalletScreen(),
      ),
    );
  }

  Future updateAd(
      String id,
      String fromCurrency,
      String fromAmount,
      String toCurrency,
      String toAmount,
      String name,
      String walletId,
      String fromDate,
      String toDate,
      String location,
      String exchangePayment,
      String taxCharges,
      String serviceFee,
      String total) async {
    var url = Uri.http('app01.karnetif.com', '/postAd/updatePost');
    var response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "id": id,
          "fromCurrency": fromCurrency,
          "toCurrency": toCurrency,
          "fromAmount": fromAmount,
          "toAmount": toAmount,
          "name": name,
          "walletId": walletId,
          "fromDate": fromDate,
          "toDate": toDate,
          "location": location,
          "exchangePayment": exchangePayment,
          "taxCharges": taxCharges,
          "serviceFee": serviceFee,
          "total": total
        }));

    if (response.statusCode == 201) {
      Fluttertoast.showToast(
        backgroundColor: Colors.green,
        textColor: Colors.white,
        msg: 'Posted',
        toastLength: Toast.LENGTH_SHORT,
      );
    } else {
      Fluttertoast.showToast(
        backgroundColor: Colors.orange,
        textColor: Colors.white,
        msg: 'Failed to post!',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WalletScreen(),
      ),
    );
  }

  Future<double> _getExchangeRate() async {
    var url = Uri.http('app01.karnetif.com', '/exchange-rate');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fromCurrency': fromCurrency.text,
        'toCurrency': toCurrency.text,
      }),
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData['exchangeRate'];
    } else {
      throw Exception('Failed to load exchange rate');
    }
  }

  void _updateExchangeAmount() async {
    if (fromAmount.text != null && fromCurrency != null && toCurrency != null) {
      final exchangeRate = await _getExchangeRate();
      double amount =
          double.parse(fromAmount.text.replaceAll(RegExp(r'[^\d\.]'), ''));
      if (amount == 0) {
        amount = 1.0; // set default value to 1.0 if amount is 0
      }
      final exchangeAmount = amount * exchangeRate;
      setState(() {
        toAmount.text = exchangeAmount.toStringAsFixed(2);
        fromAmount.text = amount.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cash Checkout (Ad)"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const Text(
                  //   "Cash Checkout (Ad)",
                  //   style: TextStyle(
                  //     fontSize: 24,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
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
                          readOnly: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Amount',
                          ),
                          controller:
                              toAmount, // Use your TextEditingController
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() => fromAmount.text = value);
                            _updateExchangeAmount();
                          },
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
                          readOnly: false,
                          decoration: const InputDecoration(
                            labelText: "Amount",
                            border: OutlineInputBorder(),
                          ),
                          controller: fromAmount,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() => toAmount.text = value);
                            _updateExchangeAmount();
                          },
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
                    decoration: const InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(),
                    ),
                    controller: name,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "Wallet ID",
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
                                  child: TextFormField(
                                    controller: fromDate,
                                    decoration: const InputDecoration(
                                      labelText: "Date From",
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter a date';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: toDate,
                                  decoration: const InputDecoration(
                                    labelText: "Date To",
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter a date';
                                    }
                                    return null;
                                  },
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
                                  TextFormField(
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: "Location",
                                      border: OutlineInputBorder(),
                                    ),
                                    controller: location,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter location';
                                      }
                                      return null;
                                    },
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

                                          permission = await Geolocator
                                              .checkPermission();
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
                                              LocationPermission
                                                  .deniedForever) {
                                            Fluttertoast.showToast(
                                                msg:
                                                    'Location permissions are permanently denied, we cannot request permissions.');
                                            return;
                                          }

                                          final position = await Geolocator
                                              .getCurrentPosition(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to another screen or perform other actions
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            // TODO: Implement post logic here
                            try {
                              print(
                                  '${id}, ${fromCurrency.text}, ${fromAmount.text}, ${toCurrency.text}, ${toAmount.text}, ${name.text}, ${walletId.text}, ${fromDate.text}, ${toDate.text}, ${location.text}, ${toAmount.text}, 0, 0, ${toAmount.text}');
                              if (isEdit) {
                                updateAd(
                                    id.toString(),
                                    fromCurrency.text,
                                    fromAmount.text,
                                    toCurrency.text,
                                    toAmount.text,
                                    name.text,
                                    walletId.text,
                                    fromDate.text,
                                    toDate.text,
                                    location.text,
                                    toAmount.text,
                                    "0",
                                    "0",
                                    toAmount.text);
                              } else {
                                postAd(
                                    fromCurrency.text,
                                    fromAmount.text,
                                    toCurrency.text,
                                    toAmount.text,
                                    name.text,
                                    walletId.text,
                                    fromDate.text,
                                    toDate.text,
                                    location.text,
                                    toAmount.text,
                                    "0",
                                    "0",
                                    toAmount.text);
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to post ads: $e'),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text("Post"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to another screen or perform other actions
                        },
                        child: const Text("Cancel"),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
