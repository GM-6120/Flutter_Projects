import 'dart:async';

import 'package:darzi_app/screens/Homescreen.dart';
import 'package:darzi_app/screens/loginscreen.dart';
import 'package:darzi_app/widgets/custom%20widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class splashscreen extends StatefulWidget {
  const splashscreen({super.key});

  @override
  State<splashscreen> createState() => _splashscreenState();
}

class _splashscreenState extends State<splashscreen> {
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () async {
      await _checkUserSession();
    });
  }

  _checkUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => loginscreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.black
          // gradient: LinearGradient(
          //     colors: [Appcolors.deeppurpleColor, Appcolors.purpleColor],
          //     begin: Alignment.bottomRight,
          //     end: Alignment.centerLeft),
          ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Animate(
              effects: [
                FadeEffect(delay: 300.ms),
              ],
              child: Image.asset(
                color: Colors.white,
                "assets/Icon2.png",
                width: 180,
                height: 250,
              ),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "DARZI",
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  "DIGITAL",
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                )
              ],
            ).animate(delay: 400.ms).slideY(curve: Curves.easeIn)
          ],
        ),
      ),
    ));
  }
}
