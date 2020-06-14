import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:nitwixt/widgets/button_simple.dart';

class MessageOptionDialog extends StatefulWidget {
  final models.Message message;

  MessageOptionDialog({
    @required this.message,
  }) : super();

  @override
  _MessageOptionDialogState createState() => _MessageOptionDialogState();
}

class _MessageOptionDialogState extends State<MessageOptionDialog> {
  final EmojiParser emojiParser = EmojiParser();
  bool showEmojiPicker = false;

  Widget emojiButton(value) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.all(5.0),
        child: Text(value),
      ),
      onTap: () {
        print(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: MediaQuery.of(context).viewInsets + const EdgeInsets.symmetric(horizontal: 0.0, vertical: 24.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40.0),
      ),
      backgroundColor: Colors.black,
      content: Container(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  emojiButton(
                    '❤',
                  ),
                  emojiButton(
                    '😆',
                  ),
                  emojiButton(
                    '😮',
                  ),
                  emojiButton(
                    '😢',
                  ),
                  emojiButton(
                    '😠',
                  ),
                  emojiButton(
                    '👍',
                  ),
                  emojiButton(
                    '👎',
                  ),
                  IconButton(
                    icon: Icon(showEmojiPicker ? Icons.remove_circle : Icons.add_circle_outline, color: Colors.grey[700]),
                    onPressed: () {
                      setState(() {
                        showEmojiPicker = !showEmojiPicker;
                      });
                    },
                  ),
                ],
              ),
              showEmojiPicker
                  ? EmojiPicker(
                      bgColor: Color(0x00000000),
                      rows: 3,
                      columns: 7,
                      onEmojiSelected: (emoji, category) {
                        print('$emoji - $category');
                      },
                    )
                  : SizedBox(
                      height: 0.0,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
