import 'dart:convert'; // Add this import for JSON decoding
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:xchange_app/receipt_screen.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({super.key});

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? barcode; // Keep this as Barcode?
  MobileScannerController cameraController = MobileScannerController();
  late Map<String, dynamic> expectedArgs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieve arguments passed to this page
    expectedArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    print("Args received: $expectedArgs");
  }

  Widget _buildBarcode(Barcode? barcodeVal) {
    if (barcodeVal == null) {
      return const Text(
        'Scan something!',
        overflow: TextOverflow.fade,
        style: TextStyle(color: Colors.white),
      );
    }

    return Text(
      barcodeVal.displayValue ?? 'No value found',
      overflow: TextOverflow.fade,
      style: const TextStyle(color: Colors.white),
    );
  }

  void handleBarcode(BarcodeCapture capture) {
    if (capture.barcodes.isNotEmpty) {
      final scannedData = capture.barcodes.first.displayValue;
      if (scannedData != null) {
        setState(() {
          barcode = capture.barcodes.firstOrNull;
        });

        // Verify the scanned data
        _verifyScannedData(scannedData);
      }
    }
  }

  void _verifyScannedData(String scannedData) {
    try {
      final decodedData = jsonDecode(scannedData) as Map<String, dynamic>;

      final isValid = _checkFields(decodedData);

      if (isValid) {
        // Show a loading animation and delay for 3 seconds before navigating
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );

        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pop(context); // Close the loading dialog
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReceiptScreen(receiptData: decodedData),
            ),
          );
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
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Invalid QR Data'),
          content: Text('Error: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
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

  // bool _areMapsEqual(Map<String, dynamic> map1, Map<String, dynamic> map2) {
  //   // Check if the keys and values match exactly
  //   return map1.length == map2.length &&
  //       map1.entries.every((entry) => map2[entry.key] == entry.value);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Snap Proof"),
      ),
      body: Stack(children: [
        MobileScanner(
          onDetect: handleBarcode,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            alignment: Alignment.bottomCenter,
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: Center(child: _buildBarcode(barcode)))
              ],
            ),
          ),
        )
      ]),
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
