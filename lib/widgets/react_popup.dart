import 'package:flutter/material.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:emoji_picker/emoji_picker.dart';

class ReactPopup extends StatefulWidget {
  const ReactPopup({
    this.message,
    this.onReactSelected,
  }) : super();

  final models.Message message;
  final void Function(models.Message, String react) onReactSelected;

  @override
  _ReactPopupState createState() => _ReactPopupState();
}

class _ReactPopupState extends State<ReactPopup> {
  bool showEmojiPicker = false;

  @override
  Widget build(BuildContext context) {
    Widget emojiButton(String value) {
      return GestureDetector(
        child: Container(
          padding: const EdgeInsets.all(5.0),
          child: Text(value),
        ),
        onTap: () {
          widget.onReactSelected(widget.message, value);
        },
      );
    }

    return Container(
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: Colors.black),
          padding: showEmojiPicker ? null : const EdgeInsets.symmetric(horizontal: 5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
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
              if (showEmojiPicker)
                Container(
                  color: Colors.black,
                  child: EmojiPicker(
                    bgColor: Color(0x00000000),
                    rows: 4,
                    columns: 12,
                    onEmojiSelected: (emoji, category) {
                      widget.onReactSelected(widget.message, emoji.emoji);
                    },
                    buttonMode: ButtonMode.CUPERTINO,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
