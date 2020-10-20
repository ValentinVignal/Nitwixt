import 'package:flutter/material.dart';

import 'package:nitwixt/models/models.dart' as models;

class ReactsDialog extends StatelessWidget {
  const ReactsDialog({
    @required this.message,
    @required this.membersMap,
  }) : super();

  final models.Message message;
  final Map<String, models.User> membersMap;

  @override
  Widget build(BuildContext context) {
    print('member map');
    print(membersMap);
    membersMap.forEach((String key, models.User value) { print('${value.username} - ${value.id}');});
    return AlertDialog(
      title: const Center(child: Text('Reacts')),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40.0),
      ),
      backgroundColor: const Color(0xFF202020),
      content: SingleChildScrollView(
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: message.reacts.length,
          itemBuilder: (BuildContext buildContext, int index) {
            final String userId = message.reacts.keys[index];
            final models.User reactUser = membersMap[userId];
            final String react = message.reacts[userId];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
                children: <Widget>[
                  Text(
                    react,
                    style: const TextStyle(fontSize: 20.0),
                  ),
                  const SizedBox(width: 10.0),
                  Text(
                    reactUser.name,
                    style: const TextStyle(fontSize: 17.0),
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
