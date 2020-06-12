import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingCircle extends StatelessWidget {
  double size;

  LoadingCircle({
    this.size = 50.0,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: SpinKitRing(
          color: Colors.blue[500],
          size: this.size,
        ),
      ),
    );
  }
}
