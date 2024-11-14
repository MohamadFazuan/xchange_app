import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:xchange_app/match_exchange.dart';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({super.key});


  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var dataQr = '';
  final String key = 'Xchange';

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final matchExchange = MatchExchange(
        name: args['name'].text,
        walletId: args['walletId'].text,
        fromCurrency: args['fromCurrency'].text,
        toCurrency: args['toCurrency'].text,
        fromAmount: args['fromAmount'].text,
        toAmount: args['toAmount'].text,
        fromDate: args['fromDate'].text,
        toDate: args['toDate'].text,
        location: args['location'].text,
        role: '');

    // Now you can use the matchExchange object
    // For example, you can convert it to JSON:
    final jsonString = jsonEncode(matchExchange.toJson());
    print(jsonString);
    setState(() {
      dataQr = jsonString.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generate QR Code"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            QrImageView(
              data: dataQr,
              version: QrVersions.auto,
              size: 200,
              gapless: false,
              errorStateBuilder: (cxt, err) {
                return Container(
                  child: const Center(
                    child: Text(
                      'Uh oh! Something went wrong...',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // TextField(
            //   controller: TextEditingController()..text = _dataString,
            //   decoration: const InputDecoration(
            //     labelText: "Enter QR Code data",
            //     border: OutlineInputBorder(),
            //   ),
            //   onChanged: (value) => setState(() => _dataString = value),
            // ),
          ],
        ),
      ),
    );
  }
}
