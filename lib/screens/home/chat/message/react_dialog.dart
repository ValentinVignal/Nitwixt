import 'package:flutter/material.dart';

import 'package:nitwixt/models/models.dart' as models;

class ReactsDialog extends StatelessWidget {
  ReactsDialog({
    @required this.message,
    @required this.membersMap,
  }) : super();

  final models.Message message;
  final Map<String, models.User> membersMap;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: Text('Reacts')),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40.0),
      ),
      backgroundColor: Color(0xFF202020),
      content: SingleChildScrollView(
        child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: message.reacts.length,
          itemBuilder: (BuildContext buildContext, int index) {
            String userId = message.reacts.keys[index];
            models.User reactUser = membersMap[userId];
            String react = message.reacts[userId];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
                children: <Widget>[
                  Text(
                    react,
                    style: TextStyle(fontSize: 20.0),
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    reactUser.name,
                    style: TextStyle(fontSize: 17.0),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static void showReactsDialog({BuildContext context, models.Message message, Map<String, models.User> membersMap}) {
    showDialog<Widget>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext buildContext) {
        return ReactsDialog(
          message: message,
          membersMap: membersMap,
        );
      },
    );
  }
}
