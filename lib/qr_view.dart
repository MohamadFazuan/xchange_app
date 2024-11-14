import 'dart:convert'; // Add this import for JSON decoding
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({super.key});

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result; // Keep this as Barcode?
  MobileScannerController cameraController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Snap Proof"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: cameraController,
              onDetect: (BarcodeCapture barcodeCapture) {
                setState(() {
                  result = barcodeCapture.barcodes.first; // Extract the first barcode
                });
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (result != null)
                    Text(
                        'Barcode Type: ${result!.format}   Data: ${result!.rawValue}')
                  else
                    const Text('Scan a code'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () {
                            cameraController.toggleTorch();
                            setState(() {});
                          },
                          child: const Text('Toggle Flash'),
                        ),
                      ),
                    ],
                  ),
                  if (result != null)
                    _verifyData(result!.rawValue!)
                  else
                    const Text(''),
                ],
              ),
            ),
          )
        ],
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