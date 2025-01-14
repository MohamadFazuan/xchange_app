import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:xchange_app/login_state.dart';
import 'package:xchange_app/match_exchange.dart';
import 'package:xchange_app/receipt_screen.dart';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({super.key});

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var dataQr = '';
  late MatchExchange matchExchange;
  Map<String, dynamic> userData = {};
  Map<String, dynamic> exchange = {};
  final String apiUrl =
      'http://app01.karnetif.com/transaction/add'; // Backend API URL

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();

    // Retrieve user data from LoginState
    userData = (await LoginState.getUserData()) ?? {};
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    matchExchange = MatchExchange(
      id: args['id'],
      role: args['role'],
      name: args['name'],
      walletId: args['walletId'],
      fromCurrency: args['fromCurrency'],
      toCurrency: args['toCurrency'],
      fromAmount: args['fromAmount'],
      toAmount: args['toAmount'],
      fromDate: args['fromDate'],
      toDate: args['toDate'],
      location: args['location'],
    );

    // Convert matchExchange to JSON for QR code
    final jsonString = jsonEncode(matchExchange.toJson());
    exchange = matchExchange.toJson();
    setState(() {
      dataQr = jsonString;
    });
  }

  Future<void> addTransaction() async {
    try {
      // Retrieve the receiverWalletId from userData
      final receiverWalletId = userData['walletId'];

      if (receiverWalletId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receiver wallet ID not found')),
        );
        return;
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'from': matchExchange.walletId,
          'to': receiverWalletId,
          'fromAmount': matchExchange.fromAmount,
          'toAmount': matchExchange.toAmount,
          'fromCurrency': matchExchange.fromCurrency,
          'toCurrency': matchExchange.toCurrency,
        }),
      );

      if (response.statusCode == 201) {
        final receiptData = jsonDecode(response.body);

        // Navigate to the ReceiptScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiptScreen(receiptData: exchange),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to add transaction: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Receiver QR Code"),
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
                return const Center(
                  child: Text(
                    'Uh oh! Something went wrong...',
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addTransaction,
              child: const Text('RECEIVED'),
            ),
          ],
        ),
      ),
    );
  }
}
