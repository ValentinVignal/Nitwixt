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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF000000),
                  Color(0xFF080808),
                  Color(0xFF101010),
                  Color(0xFF181818),
                  Color(0xFF202020),
                  Color(0xFF282828),
                  Color(0xFF202020),
                  Color(0xFF181818),
                  Color(0xFF101010),
                  Color(0xFF080808),
                  Color(0xFF000000),
                ],
                stops: [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 80.0,
            ),
            child: Container(
              alignment: Alignment.bottomCenter,
              child: Text(
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
