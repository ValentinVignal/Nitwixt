import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0xFF000000),
                  Color(0xFF282828),
                  Color(0xFF000000),
                ],
                stops: <double>[0.0, 0.5, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 80.0,
            ),
            child: Container(
              alignment: Alignment.bottomCenter,
              child: const Text(
                'Nitwixt',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 40.0,
                ),
              ),
            ),
          ),
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              scale: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}
