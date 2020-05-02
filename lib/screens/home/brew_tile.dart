import 'package:flutter/material.dart';
import 'package:textwit/models/brew.dart';

class BrewTile extends StatelessWidget {
  final Brew brew;
  BrewTile({ this.brew });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top:8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Colors.blue[brew.strength],
            backgroundImage: AssetImage('assets/images/message.png'),
          ),
          title: Text(brew.name),
          subtitle: Text('Takes ${brew.sugars} sugar(s)'),
        ),
      ),
    );
  }
}
