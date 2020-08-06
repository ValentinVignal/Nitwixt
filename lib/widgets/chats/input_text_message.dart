import 'dart:io';
import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nitwixt/shared/constants.dart';
import 'package:nitwixt/src/shortcuts/shortcuts.dart' as sc;
import 'package:nitwixt/widgets/widgets.dart';

class InputTextMessage extends StatefulWidget {
  Function sendMessage;

  InputTextMessage({
    @required this.sendMessage,
  }) : super();

  @override
  _InputTextMessageState createState() => _InputTextMessageState();
}

class _InputTextMessageState extends State<InputTextMessage> {
  TextEditingController _textController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  File image;

  bool get showSendButton {
    return _textController.text.trim().isNotEmpty || image != null;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _activateSendButton() {
    setState(() {
//      showSendButton = _textController.text.trim().isNotEmpty || image != null;
    });
  }

  @override
  void initState() {
    _textController.addListener(_activateSendButton);
    super.initState();
  }

  Future _getImage() async {
    PickedFile pickedFile = await _imagePicker.getImage(source: ImageSource.gallery, maxHeight: 512.0, maxWidth: 512.0);
    setState(() {
      image = File(pickedFile.path);
    });
  }

  _removeImage() async {
    setState(() {
      image = null;
    });
  }

  void _showSelectedImage(BuildContext context) {
    showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext buildContext) {
          Image _image = Image.file(image, height: 300.0);
          return SizedBox(
//            width: _image.width,
//            height: _image.height,
            child: Dialog(
              child: Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: _image,
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ButtonSimple(
                          icon: Icons.arrow_back_ios,
                          backgroundcolor: Colors.black,
                          onTap: () => Navigator.of(buildContext).pop(),
                        ),
                        SizedBox(width: 100.0),
                        ButtonSimple(
                          icon: Icons.delete,
                          color: Colors.red,
                          backgroundcolor: Colors.black,
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
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Row(
        children: <Widget>[
          Container(
            child: Badge(
              position: BadgePosition.topRight(top: 0, right: 0),
              badgeContent: Text('1'),
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
              style: TextStyle(color: Colors.white),
              controller: _textController,
              decoration: textInputDecorationMessage.copyWith(
                hintText: 'Type your message',
              ),
            ),
          ),
          SizedBox(width: 5.0),
          showSendButton
              ? IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    String parsedText = sc.TextParser.parse(_textController.text).trim();
                    widget.sendMessage(
                      text: parsedText,
                      image: image,
                    );
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _textController.clear();
                      image = null;
                    });
                  },
                )
              : SizedBox(width: 0.0),
          SizedBox(width: _textController.text.isEmpty ? 0.0 : 5.0),
        ],
      ),
    );
  }
}
//image != null
//? Container(
//height: 50.0,
//child: ClipRRect(
//borderRadius: BorderRadius.circular(5.0),
//child: Image.file(image, height: 40.0),
//),
//)
//: SizedBox.shrink(),
