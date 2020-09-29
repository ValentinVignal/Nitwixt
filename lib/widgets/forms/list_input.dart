import 'package:flutter/material.dart';
import 'package:nitwixt/shared/constants.dart';

import '../button_simple.dart';

class ListInputController {

  ListInputController({
    List<String> values,
  }) {
    values = values ?? <String>[];
    textEditingControllerList = <TextEditingController>[];
    values.forEach((String value) {
      textEditingControllerList.add(_createTextEditingController(value));
    });
  }

  List<TextEditingController> textEditingControllerList;

  TextEditingController _createTextEditingController(String value) {
    final TextEditingController textEditingController = TextEditingController();
    if (value != null) {
      textEditingController.text = value;
    }
    return textEditingController;
  }

  void add(String value) {
    textEditingControllerList.add(_createTextEditingController(value));
  }

  void removeAt(int index) {
    TextEditingController textEditingController = textEditingControllerList.removeAt(index);
//    textEditingController.dispose();
  }

  int get length {
    return textEditingControllerList.length;
  }

  List<String> get values {
    return textEditingControllerList.map((TextEditingController textEditingController) {
      return textEditingController.text;
    }).toList();
  }

  void dispose() {
    for (final TextEditingController value in textEditingControllerList) {
      value.dispose();
    }
  }

  bool get isEmpty {
    return textEditingControllerList.isEmpty;
  }

  bool get isNotEmpty {
    return textEditingControllerList.isNotEmpty;
  }
}

class ListInput extends StatefulWidget {

  const ListInput({
    @required this.controller,
    this.physics,
    this.shrinkWrap = true,
    this.hintText,
    this.validator,
  }) : super();

  final ListInputController controller;
  final ScrollPhysics physics;
  final bool shrinkWrap;
  final String hintText;
  final String Function(String) validator;


  @override
  _ListInputState createState() => _ListInputState();
}

class _ListInputState extends State<ListInput> {

//  @override
//  void dispose() {
//    widget.controller.dispose();
//    super.dispose();
//  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListView.builder(
          physics: widget.physics,
          shrinkWrap: widget.shrinkWrap,
          itemCount: widget.controller.length,
          itemBuilder: (BuildContext buildContextList, int index) {
            return Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    style: const TextStyle(color: Colors.white),
                    decoration: textInputDecoration.copyWith(
                      hintText: widget.hintText,
                    ),
                    validator: widget.validator,
                    controller: widget.controller.textEditingControllerList[index],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    size: 30.0,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      widget.controller.removeAt(index);
                    });
                  },
                ),
              ],
            );
          },
        ),
        ButtonSimple(
          onTap: () {
            setState(() {
              widget.controller.add('');
            });
          },
          icon: Icons.add,
          color: Colors.blue,
          text: 'Add',
          withBorder: false,
          fontSize: 16.0,
        ),
      ],
    );
  }
}
