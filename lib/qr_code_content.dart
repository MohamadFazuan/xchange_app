import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:xchange_app/login_state.dart';
import 'package:xchange_app/match_exchange.dart';
import 'package:xchange_app/receipt_screen.dart';

class QRCodeContent extends StatefulWidget {
  final String dataQr;

  const QRCodeContent({
    required this.dataQr,
    super.key,
  });

  @override
  _QRCodeContentState createState() => _QRCodeContentState();
}

class _QRCodeContentState extends State<QRCodeContent> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Receiver QR Code',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: QrImageView(
                  data: widget.dataQr,
                  version: QrVersions.auto,
                  size: 300,
                  gapless: false,
                  errorStateBuilder: (cxt, err) {
                    return const Center(
                      child: Text(
                        'Uh oh! Something went wrong...',
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final decodedData = jsonDecode(widget.dataQr);

                    Navigator.popAndPushNamed(
                      context,
                      '/checkout',
                      arguments: {
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
                        'role': 'RECEIVER'
                      },
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error decoding QR data: $e')),
                    );
                  }
                },
                child: const Text('CONFIRM'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
