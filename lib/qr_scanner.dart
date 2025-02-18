import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:xchange_app/user_display.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<StatefulWidget> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  Barcode? barcode;
  MobileScannerController cameraController = MobileScannerController();
  late Map<String, dynamic> expectedArgs;
  bool isVerified = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    setState(() {
      expectedArgs = args;
    });
  }

  Future<void> _showExitConfirmation() async {
    bool? exit = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Scanner?'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Stay
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true); // Close dialog
              Navigator.pushReplacementNamed(
                  context, '/wallet'); // Go to wallet
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (exit == true) {
      Navigator.pushReplacementNamed(context, '/wallet');
    }
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
      Fluttertoast.showToast(
        msg: 'Error processing QR code',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _verifyScannedData(String scannedData) async {
    try {
      final decodedData = jsonDecode(scannedData) as Map<String, dynamic>;
      final isValid = _checkFields(decodedData);

      if (isValid) {
        Navigator.pushNamed(context, '/checkout', arguments: {
          'isVerified': true,
          'postId': decodedData['postId'],
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
    return expectedArgs['fromCurrency'] == decodedData['fromCurrency'] &&
        expectedArgs['toCurrency'] == decodedData['toCurrency'] &&
        expectedArgs['fromAmount'] == decodedData['fromAmount'] &&
        expectedArgs['toAmount'] == decodedData['toAmount'];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _showExitConfirmation();
        }
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: const Text("Snap Proof"),
              ),
              body: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Text('Scan the QR code to verify the transaction'),
                  const SizedBox(height: 10),
                  MobileScanner(
                    controller: cameraController,
                    onDetect: (capture) {
                      Future.delayed(const Duration(milliseconds: 100))
                          .then((_) {
                        handleBarcode(capture);
                      });
                    },
                    fit: BoxFit.fitWidth,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
