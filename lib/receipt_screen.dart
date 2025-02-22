import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xchange_app/login_state.dart';
import 'package:xchange_app/transaction_model.dart';

class ReceiptScreen extends StatefulWidget {
  final Map<String, dynamic> receiptData;

  const ReceiptScreen({Key? key, required this.receiptData}) : super(key: key);

  @override
  _ReceiptScreenState createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  String? from, to, fromCurrency, toCurrency, fromAmount, toAmount, name;
  late Map<String, dynamic> expectedArgs;
  List<Transaction> _transaction = [];
  bool _isLoading = true; // Loading state
  int? postId;

  @override
  void initState() {
    super.initState();
    _fetchUserAndTransactions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieve arguments passed from the previous screen
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        postId = args['postId'];
        from = args['from'];
        to = args['to'];
        fromCurrency = args['fromCurrency'] ?? '';
        toCurrency = args['toCurrency'] ?? '';
        fromAmount = args['fromAmount'] ?? '';
        toAmount = args['toAmount'] ?? '';
      });
    }
  }

  Future<void> _fetchUserAndTransactions() async {
    final userData = await LoginState.getUserData();

    if (userData != null) {
      setState(() {
        name = userData['name'];
      });
      await _loadMatchExchanges(); // Fetch transactions after name is set
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMatchExchanges() async {
    var url = Uri.http('app01.karnetif.com', '/transaction/query/success');
    var response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"postId": postId}));
    final dynamic jsonData = jsonDecode(response.body);
    setState(() {
      if (jsonData is List) {
        setState(() {
          _transaction = jsonData
              .map<Transaction>((data) => Transaction.fromJson(data))
              .toList()
            ..sort((a, b) => DateTime.parse(b.timestamp)
                .compareTo(DateTime.parse(a.timestamp)));
          ;
        });
      } else {
        print('Invalid response format');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final receiptData = widget.receiptData;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Receipt"),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: const [
                          Text(
                            'XCHANGE APP',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Transaction Receipt',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const Divider(thickness: 2, height: 30),
                    _buildReceiptDetail('From', from),
                    _buildReceiptDetail('To', to),
                    _buildReceiptDetail('From Currency', fromCurrency),
                    _buildReceiptDetail('To Currency', toCurrency),
                    _buildReceiptDetail('From Amount', fromAmount),
                    _buildReceiptDetail('To Amount', toAmount),
                    const Divider(thickness: 2, height: 30),
                    const SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/wallet');
                        },
                        child: const Text('Confirm'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptDetail(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Flexible(
            child: Text(
              value?.toString() ?? 'N/A',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
