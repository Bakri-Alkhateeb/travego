import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Image(
          image: AssetImage('assets/logo.png'),
          width: MediaQuery.of(context).size.width / 2,
          height: MediaQuery.of(context).size.height / 5,
        ),
      ),
    );
  }
}
