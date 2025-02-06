import 'dart:convert'; // Add this import for JSON decoding
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:xchange_app/cash_checkout_nearby_screen.dart';
import 'package:xchange_app/receipt_screen.dart';
import 'package:http/http.dart' as http;

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<StatefulWidget> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  Barcode? barcode; // Keep this as Barcode?
  MobileScannerController cameraController = MobileScannerController();
  late Map<String, dynamic> expectedArgs;
  bool isVerified = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieve arguments passed to this page
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    setState(() {
      expectedArgs = args;
    });
  }

  void handleBarcode(BarcodeCapture capture) {
    if (capture.barcodes.isEmpty) {
      Fluttertoast.showToast(
        msg: 'No barcode detected',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    final barcode = capture.barcodes.first;
    final scannedData = barcode.displayValue;

    if (scannedData == null || scannedData.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Invalid QR code data',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    setState(() {
      this.barcode = barcode;
    });

    try {
      _verifyScannedData(scannedData);
    } catch (e) {
      print('Error processing QR code: $e');
      Fluttertoast.showToast(
        msg: 'Error processing QR code',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _verifyScannedData(String scannedData) async {
    print(scannedData);
    try {
      final decodedData = jsonDecode(scannedData) as Map<String, dynamic>;
      final isValid = _checkFields(decodedData);

      if (isValid) {
        print(isValid);

        // Return to the previous screen with arguments
        Navigator.pushNamed(context, '/checkout', arguments: {
          'isVerified': true,
          'from': decodedData['from'],
          'walletId': decodedData['walletId'],
          'to': decodedData['to'],
          'toWalletId': decodedData['toWalletId'],
          'location': decodedData['location'],
          'fromCurrency': decodedData['fromCurrency'],
          'toCurrency': decodedData['toCurrency'],
          'fromAmount': decodedData['fromAmount'],
          'toAmount': decodedData['toAmount'],
          'decodedData': decodedData,
          'role': 'SENDER'
        });
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Verification Failed'),
            content: Text(
                'Scanned data is incomplete or invalid:\n$decodedData\n$expectedArgs'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error processing QR code: ${e.toString()}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  bool _checkFields(Map<String, dynamic> decodedData) {
    // Check if the required fields exist in the scanned data
    if (!decodedData.containsKey('fromCurrency') ||
        !decodedData.containsKey('toCurrency') ||
        !decodedData.containsKey('fromAmount') ||
        !decodedData.containsKey('toAmount')) {
      return false;
    }

    // Compare the necessary fields
    return expectedArgs['fromCurrency'] == decodedData['fromCurrency'] &&
        expectedArgs['toCurrency'] == decodedData['toCurrency'] &&
        expectedArgs['fromAmount'] == decodedData['fromAmount'] &&
        expectedArgs['toAmount'] == decodedData['toAmount'];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Disables back button
      onPopInvoked: (didPop) {
        if (didPop) {
          Navigator.pushReplacementNamed(context, '/checkout', arguments: {
            'isVerified': false,
            'from': expectedArgs['from'],
            'walletId': expectedArgs['walletId'],
            'to': expectedArgs['to'],
            'toWalletId': expectedArgs['toWalletId'],
            'location': expectedArgs['location'],
            'fromCurrency': expectedArgs['fromCurrency'],
            'toCurrency': expectedArgs['toCurrency'],
            'fromAmount': expectedArgs['fromAmount'],
            'toAmount': expectedArgs['toAmount'],
            'role': 'SENDER'
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Snap Proof"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacementNamed(
                  context, '/wallet'); // Navigate to initial page
            },
          ),
        ),
        body: Stack(
          children: [
            MobileScanner(
              onDetect: handleBarcode,
              fit: BoxFit.contain,
              controller: cameraController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _verifyData(String data) {
    try {
      Map<String, dynamic> jsonData = jsonDecode(data);
      return Column(
        children: [
          Text('Name: ${jsonData['name']}'),
          Text('Wallet ID: ${jsonData['walletId']}'),
          Text('From Currency: ${jsonData['fromCurrency']}'),
          Text('To Currency: ${jsonData['toCurrency']}'),
          Text('From Amount: ${jsonData['fromAmount']}'),
          Text('To Amount: ${jsonData['toAmount']}'),
          Text('From Date: ${jsonData['fromDate']}'),
          Text('To Date: ${jsonData['toDate']}'),
          Text('Location: ${jsonData['location']}'),
        ],
      );
    } catch (e) {
      return Text('Invalid data: $e');
    }
  }
}
