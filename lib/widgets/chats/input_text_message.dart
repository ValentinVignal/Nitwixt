import 'dart:io';
import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nitwixt/shared/constants.dart';
import 'package:nitwixt/src/shortcuts/shortcuts.dart' as sc;
import 'package:nitwixt/widgets/widgets.dart';

class InputTextMessage extends StatefulWidget {
  const InputTextMessage({
    @required this.sendMessage,
    this.isEditing,
    this.onEdit,
    this.initialText,
    this.allowImages,
  }) : super();

  final Function sendMessage;
  final bool isEditing;
  final void Function() onEdit;
  final String initialText;
  final bool allowImages;

  @override
  _InputTextMessageState createState() => _InputTextMessageState();
}

class _InputTextMessageState extends State<InputTextMessage> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  String _previousInitialText;

  File image;

  IconData get icon {
    if (_textController.text.trim().isNotEmpty || image != null) {
      if (widget.isEditing) {
        return Icons.check;
      } else {
        return Icons.send;
      }
    } else {
      if (widget.onEdit != null) {
        return Icons.edit;
      } else {
        return null;
      }
    }
  }

  void Function() get onPressed {
    if (_textController.text.trim().isNotEmpty || image != null) {
      return () {
        final String parsedText = sc.TextParser.parse(_textController.text).trim();
        widget.sendMessage(
          text: parsedText,
          image: image,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _textController.clear();
          image = null;
        });
      };
    } else {
      return widget.onEdit;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _activateSendButton() {
    setState(() {});
  }

  @override
  void initState() {
    _textController.addListener(_activateSendButton);
    _previousInitialText = widget.initialText;
    super.initState();
  }

  Future<void> _getImage() async {
    final PickedFile pickedFile = await _imagePicker.getImage(source: ImageSource.gallery, maxHeight: 512.0, maxWidth: 512.0);
    setState(() {
      image = File(pickedFile.path);
    });
  }

  void _removeImage() {
    setState(() {
      image = null;
    });
  }

  void _showSelectedImage(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext buildContext) {
        final Image _image = Image.file(image, height: 300.0);
        return SizedBox(
          child: Dialog(
            child: Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: _image,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ButtonSimple(
                        icon: Icons.arrow_back_ios,
                        backgroundColor: Colors.black,
                        onTap: () => Navigator.of(buildContext).pop(),
                      ),
                      const SizedBox(width: 100.0),
                      ButtonSimple(
                        icon: Icons.delete,
                        color: Colors.red,
                        backgroundColor: Colors.black,
                        onTap: () {
                          _removeImage();
                          Navigator.of(buildContext).pop();
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_previousInitialText != widget.initialText) {
      _previousInitialText = widget.initialText;
      if (widget.initialText != null && widget.initialText.isNotEmpty) {
        _textController.text = widget.initialText;
        _textController.selection = TextSelection.fromPosition(TextPosition(offset: _textController.text.length));
      }
    }

    return Container(
      color: Colors.black,
      child: Row(
        children: <Widget>[
          if (widget.allowImages)
            Container(
              child: Badge(
                position: BadgePosition.topEnd(top: 0, end: 0),
                badgeContent: const Text('1'),
                showBadge: image != null,
                child: IconButton(
                  icon: Icon(
                    Icons.image,
                    color: image == null ? Colors.white : Colors.blue,
                  ),
                  onPressed: () {
                    if (image == null) {
                      _getImage();
                    } else {
                      _showSelectedImage(context);
                    }
                  },
                ),
              ),
            ),
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              minLines: 1,
              maxLines: 7,
              style: const TextStyle(color: Colors.white),
              controller: _textController,
              decoration: textInputDecorationMessage.copyWith(
                hintText: 'Type your message',
              ),
            ),
          ),
          const SizedBox(width: 5.0),
          if (icon != null)
            IconButton(
              icon: Icon(
                icon,
                color: Colors.blue,
              ),
              onPressed: onPressed,
            ),
          SizedBox(width: _textController.text.isEmpty ? 0.0 : 5.0),
        ],
      ),
    );
  }
}
