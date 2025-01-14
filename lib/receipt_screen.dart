import 'package:flutter/material.dart';
import 'package:xchange_app/wallet_screen.dart';

class ReceiptScreen extends StatefulWidget {
  final Map<String, dynamic> receiptData;

  const ReceiptScreen({Key? key, required this.receiptData}) : super(key: key);

  @override
  _ReceiptPageState createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Receipt"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaction Receipt',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildReceiptDetail('Name', widget.receiptData['name']),
            _buildReceiptDetail('Wallet ID', widget.receiptData['walletId']),
            _buildReceiptDetail(
                'From Currency', widget.receiptData['fromCurrency']),
            _buildReceiptDetail(
                'To Currency', widget.receiptData['toCurrency']),
            _buildReceiptDetail(
                'From Amount', widget.receiptData['fromAmount']),
            _buildReceiptDetail('To Amount', widget.receiptData['toAmount']),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popAndPushNamed(context, '/wallet');
                },
                child: const Text('Done'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptDetail(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value.toString()),
        ],
      ),
    );
  }
}