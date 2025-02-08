import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:parties/screens/splash.dart';

import '../components/global.dart';
import '../main.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  final store = GetStorage();
  _startRun() async {
    await GetStorage.init();
    Timer(const Duration(seconds: 3), () {
      bool? boarding = store.read('onBoarding');
      boarding == null ? _navigateToSplash() : _navigateToSplash();
    });
  }

  _navigateToSplash() {
    if (currentUserId == null) {
      // home screen
      Navigator.of(context).pushNamedAndRemoveUntil(
        // HomeWidget.routeName,
        SplashScreen.routeName,
        (route) => false,
      );
    } else {
      // auth screen
      Navigator.of(context).pushNamedAndRemoveUntil(
        // Auth.routeName,
        HomeWidget.routeName,
        (route) => false,
      );
    }
  }

  @override
  initState() {
    super.initState();
    _startRun();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(height: 110, 'assets/images/logo.jpg'),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
