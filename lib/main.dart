import 'dart:io';

import 'package:flutter/material.dart';
import 'package:xchange_app/about_screen.dart';
import 'package:xchange_app/add_card_screen.dart';
import 'package:xchange_app/add_friend_screen.dart';
import 'package:xchange_app/cash_checkout_screen.dart';
import 'package:xchange_app/change_password_screen.dart';
import 'package:xchange_app/exchange_screen.dart';
import 'package:xchange_app/login_screen.dart';
import 'package:xchange_app/match_screen.dart';
import 'package:xchange_app/post_screen.dart';
import 'package:xchange_app/qr_code_screen.dart';
import 'package:xchange_app/qr_view.dart';
import 'package:xchange_app/register_screen.dart';
import 'package:xchange_app/setting_screen.dart';
import 'package:xchange_app/wallet_screen.dart';
import 'package:xchange_app/transaction_screen.dart';
import 'package:xchange_app/friend_screen.dart';
import 'package:xchange_app/card_screen.dart';
import 'package:xchange_app/account_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
  }
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();

  // Change the default factory. On iOS/Android, if not using `sqlite_flutter_lib` you can forget
  // this step, it will use the sqlite version available on the system.
  databaseFactory = databaseFactoryFfi;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exchange App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/exchange': (context) => const ExchangeScreen(),
        '/friends': (context) => const FriendScreen(),
        '/add_friend': (context) => const AddFriendScreen(),
        '/cards': (context) => const CardScreen(),
        '/add_card': (context) => const AddCardScreen(),
        '/account': (context) => const AccountScreen(),
        '/settings': (context) => const SettingScreen(),
        '/change_password': (context) => const ChangePasswordScreen(),
        '/about': (context) => const AboutScreen(),
        '/wallet': (context) => const WalletScreen(),
        '/transaction': (context) => const TransactionScreen(),
        '/post': (context) => const PostAdScreen(),
        '/checkout':(context) => const CashCheckoutScreen(),
        '/match': (context) => const MatchExchangeScreen(),
        '/qrView': (context) => const QRCodeScreen(),
        '/qrSnap': (context) => const QRViewExample(),
      },
    );
  }
}