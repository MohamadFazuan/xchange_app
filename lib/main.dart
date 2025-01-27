import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:xchange_app/about_screen.dart';
import 'package:xchange_app/add_card_screen.dart';
import 'package:xchange_app/add_friend_screen.dart';
import 'package:xchange_app/cash_checkout_screen.dart';
import 'package:xchange_app/cash_checkout_nearby_screen.dart';
import 'package:xchange_app/login_state.dart';
import 'package:xchange_app/change_password_screen.dart';
import 'package:xchange_app/exchange_screen.dart';
import 'package:xchange_app/login_screen.dart';
import 'package:xchange_app/match_screen.dart';
import 'package:xchange_app/notification_screen.dart';
import 'package:xchange_app/notification_state.dart';
import 'package:xchange_app/post_screen.dart';
import 'package:xchange_app/posted_ad.dart';
import 'package:xchange_app/qr_code_content.dart';
import 'package:xchange_app/qr_scanner.dart';
import 'package:xchange_app/register_screen.dart';
import 'package:xchange_app/setting_screen.dart';
import 'package:xchange_app/wallet_screen.dart';
import 'package:xchange_app/transaction_screen.dart';
import 'package:xchange_app/friend_screen.dart';
import 'package:xchange_app/card_screen.dart';
import 'package:xchange_app/account_screen.dart';
import 'package:xchange_app/receipt_screen.dart';
import 'package:xchange_app/posted_ad.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xchange_app/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().initialize();
  
  runApp(const MyApp(isLoggedIn: false));
}

class MyApp extends StatelessWidget {

  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exchange App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: isLoggedIn ? '/wallet' : '/login',
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
        '/checkout': (context) => const CashCheckoutScreen(),
        '/checkout/nearby': (context) => const CashCheckoutNearbyScreen(),
        '/match': (context) => const MatchExchangeScreen(),
        '/qrSnap': (context) => const QRScanner(),
        '/postedAd' : (context) => const PostedAd(),
        '/receipt': (context) => const ReceiptScreen(receiptData: {}),
        '/notification': (context) => NotificationScreen(),
      },
    );
  }
}