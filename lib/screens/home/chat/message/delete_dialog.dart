import 'package:flutter/material.dart';

import 'package:nitwixt/services/database/database.dart' as database;

class DeleteDialog extends StatelessWidget {

  const DeleteDialog({
    @required this.chatId,
    @required this.messageId,
  }) : super();

  final String messageId;
  final String chatId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(child: Text('Delete')),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40.0),
      ),
      backgroundColor: const Color(0xFF202020),
      content: const Text(
        'Are you sure you want to delete this message ?\nIt can\'t be undone.',
        textAlign: TextAlign.center,
      ),
      actions: <FlatButton>[
        FlatButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: const Text(
            'Delete',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            final database.DatabaseMessage databaseMessage = database.DatabaseMessage(chatId: chatId);
            databaseMessage.deleteMessage(messageId);
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
