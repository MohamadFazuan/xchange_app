import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xchange_app/login_state.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key});

  @override
  _FriendScreenState createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  List<Map<String, dynamic>> users = []; // This will store the list of users
  String? toAmount, fromAmount, toCurrency, fromCurrency, walletId;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    final userData = await LoginState.getUserData();
    final argsUserState =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    walletId = userData?['walletId'];

    // Retrieve arguments passed from the TransactionScreen
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    setState(() {
      fromCurrency = args['fromCurrency'];
      toCurrency = args['toCurrency'];
      fromAmount = args['fromAmount'];
      toAmount = args['toAmount'];
    });
  }

  // Fetch all users from the backend
  Future<void> _loadAllUsers() async {
    var url =
        Uri.http('app01.karnetif.com', '/users'); // URL to fetch all users
    var response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        users = List<Map<String, dynamic>>.from(jsonData).where((user) {
        // Exclude the logged-in user by comparing names
        return user['walletId'] != walletId;
      }).toList();
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load users')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAllUsers(); // Load all users when the screen is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: users.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final selectedUser = users[index];
                  return Card(
                    child: ListTile(
                      leading:
                          const Icon(Icons.person), // Icon at the left side
                      title: Text(selectedUser['username'] ??
                          'No Name'), // Display username
                      subtitle: Text(
                          'Email: ${selectedUser['email']}'), // Display email
                      trailing:
                          const Icon(Icons.call, size: 18, color: Colors.blue),
                      onTap: () {
                        // Navigate to user details page (implement as needed)
                        Navigator.pushNamed(context, '/checkout/nearby',
                            arguments: {
                              'selectedUser': selectedUser,
                              'fromCurrency': fromCurrency,
                              'toCurrency': toCurrency,
                              'fromAmount': fromAmount,
                              'toAmount': toAmount,
                            });
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
