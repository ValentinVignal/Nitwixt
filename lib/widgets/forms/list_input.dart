import 'package:flutter/material.dart';
import 'package:nitwixt/shared/constants.dart';

import '../button_simple.dart';

class ListInputController {
  List<TextEditingController> textEditingControllerList;

  ListInputController({
    List<String> values,
  }) {
    values = values ?? List<String>.from([]);
    this.textEditingControllerList = List<TextEditingController>();
    values.forEach((String value) {
      this.textEditingControllerList.add(_createTextEditingController(value));
    });
  }

  TextEditingController _createTextEditingController(String value) {
    TextEditingController textEditingController = TextEditingController();
    if (value != null) {
      textEditingController.text = value;
    }
    return textEditingController;
  }

  void add(value) {
    this.textEditingControllerList.add(_createTextEditingController(value));
  }

  void removeAt(index) {
    TextEditingController textEditingController = this.textEditingControllerList.removeAt(index);
//    textEditingController.dispose();
  }

  int get length {
    return this.textEditingControllerList.length;
  }

  List<String> get values {
    return this.textEditingControllerList.map((TextEditingController textEditingController) {
      return textEditingController.text;
    }).toList();
  }

  void dispose() {
    for (var value in textEditingControllerList) {
      value.dispose();
    }
  }

  bool get isEmpty {
    return this.textEditingControllerList.isEmpty;
  }

  bool get isNotEmpty {
    return this.textEditingControllerList.isNotEmpty;
  }
}

class ListInput extends StatefulWidget {
  ListInputController controller;
  ScrollPhysics physics;
  bool shrinkWrap;
  String hintText;
  Function validator;

  ListInput({
    @required this.controller,
    this.physics,
    this.shrinkWrap = true,
    this.hintText,
    this.validator,
  }) : super();

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
                    style: TextStyle(color: Colors.white),
                    decoration: textInputDecoration.copyWith(
                      hintText: widget.hintText,
                    ),
                    validator: widget.validator,
                    controller: widget.controller.textEditingControllerList[index],
                  ),
                ),
                IconButton(
                  icon: Icon(
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
