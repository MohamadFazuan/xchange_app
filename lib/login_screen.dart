import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:xchange_app/login_state.dart';
import 'package:xchange_app/wallet_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  

  /// Fetch the wallet ID using the username and password.
  Future<String?> getWalletId() async {
    var url = Uri.http('app01.karnetif.com', '/getWalletId');
    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": _username.text,
          "password": _password.text,
        }),
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data["walletId"];
      }
    } catch (e) {
      debugPrint("Error fetching wallet ID: $e");
    }
    return null;
  }

  Future<void> updateFcmToken(String? token) async {
    var url = Uri.http('app01.karnetif.com', '/update-fcm-token');
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "username": _username.text,
        "newFcmToken": token,
      }),
    );

    if (response.statusCode == 200) {
      print("FCM token updated successfully");
    } else {
      print("Failed to update FCM token");
    }
  }

  /// Handle the login process.
  Future<void> login() async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    var url = Uri.http('app01.karnetif.com', '/login');
    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": _username.text,
          "password": _password.text,
        }),
      );

      var data = json.decode(response.body);

      if (data["status"] == 201) {
        Fluttertoast.showToast(
          msg: 'Invalid username or password',
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
        );
      } else {
        await LoginState.setLoggedIn(true);
        await LoginState.setUserData({
          'name': data["username"],
          'walletId': data["walletId"],
        });
        Fluttertoast.showToast(
          msg: 'Login Successful',
          backgroundColor: Colors.green,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
        );
        updateFcmToken(fcmToken);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const WalletScreen(),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error during login: $e");
      Fluttertoast.showToast(
        msg: 'Login failed. Please try again.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Username TextField
              TextFormField(
                controller: _username,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Password TextField
              TextFormField(
                controller: _password,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Login Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    login();
                  }
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 20),

              // Register Section
              const Text('Don\'t have an account?'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
