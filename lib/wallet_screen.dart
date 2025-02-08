import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:xchange_app/custom_drawer.dart';
import 'package:xchange_app/login_state.dart';
import 'package:badges/badges.dart' as badges;
import 'package:xchange_app/notification_state.dart';
import 'package:xchange_app/services/notification_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int selectedOption = 1;
  bool selected = false;
  String? _selectedCurrency;
  String? _selectedAmount;
  String? walletId, userName;
  bool hasUnreadNotifications = false;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    final userData = await LoginState.getUserData();

    if (userData != null) {
      setState(() {
        userName = userData['name'];
        walletId = userData['walletId'];
      });
    } else {
      print('No user data found or name key is missing.');
    }
  }

  void _onCardSelect(String currency, String amount) {
    setState(() {
      _selectedCurrency = currency;
      _selectedAmount = amount;
    });
  }

  void _logout() async {
    await LoginState.setLoggedIn(false);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBarTitle: "",
      appBar: AppBar(
        title: const Text('Wallet'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Title
              const Text(
                'XCHANGE',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Copyright MFY',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 150),

              // Buttons
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/exchange');
                },
                style: ElevatedButton.styleFrom(
                  // backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 32.0),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    // fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text('Cash Exchange'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  // backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 32.0),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    // fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text('eCash Exchange'),
              ),
              const SizedBox(height: 100),

              // Logout Button
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // Implement logout functionality here
                    if (await LoginState.isLoggedIn()) {
                      await LoginState.setLoggedIn(false);
                      Fluttertoast.showToast(
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        msg: 'User logged out',
                        toastLength: Toast.LENGTH_SHORT,
                      );
                    }
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    // backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 32.0),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      // fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('Logout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CurrencyCard extends StatefulWidget {
  final String currency;
  final String amount;
  final Function onSelect;

  const CurrencyCard(
      {super.key,
      required this.currency,
      required this.amount,
      required this.onSelect});

  @override
  _CurrencyCardState createState() => _CurrencyCardState();
}

class _CurrencyCardState extends State<CurrencyCard> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSelected = !_isSelected;
        });
        widget.onSelect(widget.currency, widget.amount);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: _isSelected
              ? const BorderSide(width: 2, color: Colors.blue)
              : BorderSide.none,
        ),
        elevation: 5,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.currency,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _isSelected ? Colors.blue : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.amount,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _isSelected ? Colors.blue : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
