import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:xchange_app/login_state.dart';

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
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('XCHANGE'),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/wallet');
              },
            ),
            // ListTile(
            //   leading: Icon(Icons.swap_horiz),
            //   title: Text('Exchange'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     Navigator.pushNamed(context, '/exchange');
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Post'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/transaction');
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Account'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/account');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Friends'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/friends');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Setting'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/setting');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                _logout();
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login', (Route<dynamic> route) => false);
              },
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
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
              'Copyright SDIT 2020',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 100),

            // Currency Carousel
            SizedBox(
              height: 150,
              child: PageView(
                children: [
                  CurrencyCard(
                    currency: 'MYR',
                    amount: 'RM 100.00',
                    onSelect: _onCardSelect,
                  ),
                  CurrencyCard(
                    currency: 'USD',
                    amount: '\$ 100.00',
                    onSelect: _onCardSelect,
                  ),
                  CurrencyCard(
                    currency: 'EUR',
                    amount: '€ 100.00',
                    onSelect: _onCardSelect,
                  ),
                  CurrencyCard(
                    currency: 'GBP',
                    amount: '£ 100.00',
                    onSelect: _onCardSelect,
                  ),
                  CurrencyCard(
                    currency: 'JPY',
                    amount: 'Y 100.00',
                    onSelect: _onCardSelect,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),

            // Buttons
            ElevatedButton(
              onPressed: () {
                if (_selectedCurrency != null && _selectedAmount != null) {
                  Navigator.pushNamed(context, '/exchange', arguments: {
                    'currency': _selectedCurrency,
                    'amount': _selectedAmount,
                  });
                } else {
                  // Show an error message if no card is selected
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a card')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                // backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                // backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 12.0, horizontal: 32.0),
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
    );
  }
}

class CurrencyCard extends StatefulWidget {
  final String currency;
  final String amount;
  final Function onSelect;

  const CurrencyCard(
      {super.key, required this.currency, required this.amount, required this.onSelect});

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
