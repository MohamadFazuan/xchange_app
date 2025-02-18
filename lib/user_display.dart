import 'package:flutter/material.dart';
import 'package:xchange_app/login_state.dart';

class UsernameDisplay extends StatelessWidget {
  const UsernameDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the username from the login state or wherever it is stored
    Future<Map<String, dynamic>?> userData = LoginState.getUserData(); // Example method for getting username

    return FutureBuilder<Map<String, dynamic>?>(
      future: userData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Error loading username');
        } else if (snapshot.hasData) {
          String username = snapshot.data?['name'] ?? 'Unknown User';
          return Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue,
              child: Text(
                username, // Show the actual username
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        } else {
          return const Text('No user data available');
        }
      },
    );
  }
}