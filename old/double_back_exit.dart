import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DoubleBackExitApp extends StatefulWidget {
  final Widget child;

  const DoubleBackExitApp({Key? key, required this.child}) : super(key: key);

  @override
  _DoubleBackExitAppState createState() => _DoubleBackExitAppState();
}

class _DoubleBackExitAppState extends State<DoubleBackExitApp> {
  DateTime? lastPressed;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        final backButtonHasNotBeenPressedOrSnackBarHasBeenClosed =
            lastPressed == null ||
                now.difference(lastPressed!) > Duration(seconds: 2);

        if (backButtonHasNotBeenPressedOrSnackBarHasBeenClosed) {
          lastPressed = DateTime.now();
          Fluttertoast.showToast(
            msg: 'برای خروج دوباره دکمه بازگشت را فشار دهید',
            backgroundColor: Colors.black,
            textColor: Colors.white,
          );
          return false;
        }

        return true;
      },
      child: widget.child,
    );
  }
}
