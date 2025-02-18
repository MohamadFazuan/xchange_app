import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:xchange_app/login_state.dart';
import 'package:xchange_app/match_exchange.dart';
import 'package:xchange_app/receipt_screen.dart';
import 'package:xchange_app/transaction_model.dart';

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
  List<Transaction> _transaction = [];
  String? name;

  Future<void> _loadMatchExchanges() async {
    var url = Uri.http('app01.karnetif.com', '/transaction/query/success');
    var response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"name": name}));
    final dynamic jsonData = jsonDecode(response.body);
    setState(() {
      if (jsonData is List) {
        _transaction = jsonData
            .map<Transaction>((data) => Transaction.fromJson(data))
            .toList()
          ..sort((a, b) => DateTime.parse(b.timestamp)
              .compareTo(DateTime.parse(a.timestamp)));
      } else {
        print('Invalid response format');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,  // Center the entire column
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "1. Please make sure QR Code scanned \n2. Make the exchange after scanned\n3. Click confirm after complete the exchange",
                textAlign: TextAlign.center,  // Center the text
                style: TextStyle(fontSize: 14),  // Optional: Adjust font size
              ),
            ),
            Flexible(  // Use Flexible instead of Expanded
              fit: FlexFit.loose,  // Ensures that the QR code doesn't stretch excessively
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
                      '/receipt',
                      arguments: {
                        'postId': decodedData['postId'],
                        'from': decodedData['from'],
                        'walletId': decodedData['walletId'],
                        'to': decodedData['to'],
                        'fromCurrency': decodedData['fromCurrency'],
                        'toCurrency': decodedData['toCurrency'],
                        'fromAmount': decodedData['fromAmount'],
                        'toAmount': decodedData['toAmount'],
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
