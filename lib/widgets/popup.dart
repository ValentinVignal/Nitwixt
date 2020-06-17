import 'package:flutter/material.dart';

class Popup extends StatefulWidget {
  Function onOustideTap;
  Widget childBack;
  Widget childFront;
  PopupController controller;

  Popup({
    this.onOustideTap,
    this.childBack,
    this.childFront,
    this.controller,
  }) : super() {
    if (this.controller == null) {
      this.controller = PopupController();
    }
  }

  static _PopupState of(BuildContext context) => context.findAncestorStateOfType<_PopupState>();


  @override
  _PopupState createState() => _PopupState();
}

class _PopupState extends State<Popup> {

  @override
  Widget build(BuildContext context) {
  widget.controller.getPopupSetState(setState);


    return Stack(
      children: <Widget>[
        this.widget.childBack,
        this.widget.controller.showPopup
            ? Stack(
          alignment: Alignment.center,
                overflow: Overflow.visible,
                children: <Widget>[
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: Container(
                      height: double.maxFinite,
                      width: double.maxFinite,
                    ),
                    onTap: widget.onOustideTap ?? () {
                      this.widget.controller.hide();
                    },
                  ),
                  this.widget.childFront,
                ],
              )
            : SizedBox(
                height: 0.0,
                width: 0.0,
              ),
      ],
    );
  }
}

class PopupController {
  bool showPopup;
  Function show;
  Function hide;
  Function toggle;
  Function updateObject;
  Object object;

  PopupController({
    this.showPopup = false,
    this.updateObject,
    this.object,
  }) {
    this.show = () {
      this.showPopup = true;
    };
    this.hide = () {
      this.showPopup = false;
    };
    this.toggle = () {
      this.showPopup = !this.showPopup;
    };
  }

  void getPopupSetState(Function setState) {
    this.show = () {
      setState(() {
        this.showPopup = true;
      });
    };
    this.hide = () {
      setState(() {
        this.showPopup = false;
      });
    };
    this.toggle = () {
      setState(() {
        this.showPopup = !this.showPopup;
      });
    };
    this.updateObject = (Object obj) {
      setState(() {
        this.object = obj;
      });
    };
  }


}
