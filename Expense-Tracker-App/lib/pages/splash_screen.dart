import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../utils/app_utils.dart';
import 'login_page.dart';
import 'navbar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AppUtils appUtils = AppUtils();

  fetchData() async {
    AppUtils.data = await appUtils.readUserData();
    if (AppUtils.data != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Navbar(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () async {
      await fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [g1, g2],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: Transform.scale(
                  scale: 0.6,
                  child: Image.asset("assets/logo.png"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
