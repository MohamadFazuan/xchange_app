import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:xchange_app/login_state.dart';
import 'package:xchange_app/wallet_screen.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  Future<String> getWalletId() async {
    var url = Uri.http("app01.karnetif.com", '/getWalletId');
    var response = await http.post(url, headers: {
      'Content-Type': 'application/json',
    }, body: jsonEncode({
      "username": _username.text,
      "password": _password.text,
    }));

    return "null";
  }

  Future login() async {
    var url = Uri.http("app01.karnetif.com", '/login');
    var response = await http.post(url, headers: {
      'Content-Type': 'application/json',
    }, body: jsonEncode({
      "username": _username.text,
      "password": _password.text,
    }));
    Map<String, dynamic> data = json.decode(response.body);

    if (data["message"] == "Failed to login") {
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: 'Username and password invalid',
        toastLength: Toast.LENGTH_SHORT,
      );
    } else {
      await LoginState.setLoggedIn(true);
      await LoginState.setUserData({
        'name': data["username"],
        'walletId': data["walletId"]
      });
      Fluttertoast.showToast(
        msg: 'Login Successful',
        backgroundColor: Colors.green,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const WalletScreen(),
        ),
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
              TextFormField(
                controller: _username,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
                // onSaved: (value) => _username = value!,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _password,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
                // onSaved: (value) => _password = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // TODO: Implement login logic here
                    login();
                  }
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 20),
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