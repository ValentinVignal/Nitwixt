import 'package:flutter/material.dart';

import 'package:nitwixt/models/models.dart' as models;

class EditedMessage extends StatelessWidget {
  const EditedMessage({
    @required this.message,
    @required this.onCancel,
  }) : super();

  final models.Message message;
  final void Function() onCancel;

  @override
  Widget build(BuildContext context) {
    const Color _color = Color(0xFFBBBBBB);
    return Container(
      color: const Color(0xFF101010),
      child: Row(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.0),
            child: Icon(
              Icons.edit,
              color: _color,
            ),
          ),
          Expanded(
            child: Text(
              message.text.replaceAll('\n', ' '),
              style: const TextStyle(color: _color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.clear,
              color: _color,
            ),
            onPressed: onCancel,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            constraints: const BoxConstraints(
              minWidth: kMinInteractiveDimension,
              minHeight: kMinInteractiveDimension - 10,
            ),
          ),
        ],
      ),
    );
  }
}
