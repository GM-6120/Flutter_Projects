import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_route.dart';
import 'package:flutter/material.dart';

class Appcolors {
  static const Color blueColor = Colors.blue;
  static const Color redColor = Colors.red;
  static const Color purpleColor = Colors.green;
  static const Color black = Colors.black;
}

void showFlashMessage(BuildContext context, String message) {
  showFlushbar(
      context: context,
      flushbar: Flushbar(
        message: message,
        backgroundColor: Colors.red,
        forwardAnimationCurve: Curves.decelerate,
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        flushbarPosition: FlushbarPosition.BOTTOM,
        duration: Duration(seconds: 3),
        padding: EdgeInsets.all(10),
        messageColor: Colors.black,
        reverseAnimationCurve: Curves.easeInOut,
        borderRadius: BorderRadius.circular(20),
        positionOffset: 20,
        icon: const Icon(
          Icons.error,
          size: 28,
          color: Colors.white,
        ),
      )..show(context));
}
