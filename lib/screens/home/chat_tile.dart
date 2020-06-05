import 'package:flutter/material.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/screens/chat/chat_provider.dart';
import 'package:provider/provider.dart';

class ChatTile extends StatelessWidget {
  final models.Chat chat;

  ChatTile({this.chat});

  @override
  Widget build(BuildContext context) {

    models.User user = Provider.of<models.User>(context);

    return GestureDetector(
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.chat_bubble, color: Colors.blue[800], size: 50.0,),
            SizedBox(width: 20.0,),
            FutureBuilder<String>(
              future: chat.nameToDisplay(user),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('...', style: TextStyle(color: Colors.grey, fontSize: 18.0),);
                } else {
                  if (snapshot.hasError) {
                    return Text('Could not display name', style: TextStyle(color: Colors.red, fontSize: 18.0),);
                  } else {
                    return Text(snapshot.data, style: TextStyle(color: Colors.white, fontSize: 18.0));
                  }
                }
              },
            ),
          ],
        ),
        margin: EdgeInsets.symmetric(vertical: 6.0, horizontal:20.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.blueGrey[800]),
          )
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatProvider(id: chat.id)),
          );
      },
    );
  }
}
