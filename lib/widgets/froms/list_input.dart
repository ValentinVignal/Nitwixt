import 'package:flutter/material.dart';
import 'package:nitwixt/shared/constants.dart';

import '../button_simple.dart';

class ListInputController {
  List<String> values;

  ListInputController({
    this.values,
  }) {
    this.values = this.values ?? [];
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
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListView.builder(
          physics: widget.physics,
          shrinkWrap: widget.shrinkWrap,
          itemCount: widget.controller.values.length,
          itemBuilder: (BuildContext buildContextList, int index) {
            return Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    style: TextStyle(color: Colors.white),
                    decoration: textInputDecoration.copyWith(
                      hintText: widget.hintText,
                    ),
                    initialValue: widget.controller.values[index],
                    validator: widget.validator,
                    onChanged: (val) {
                      setState(() {
                        widget.controller.values[index] = val;
                      });
                    },
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
                      widget.controller.values.removeAt(index);
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
              widget.controller.values.add('');
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
