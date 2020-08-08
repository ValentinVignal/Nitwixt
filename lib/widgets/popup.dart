import 'package:flutter/material.dart';

class Popup extends StatefulWidget {
  Popup({
    this.onOutsideTap,
    this.childBack,
    this.childFront,
    PopupController controller,
  }) : super() {
    _controller = controller ?? PopupController();
  }

  final void Function() onOutsideTap;
  final Widget childBack;
  final Widget childFront;
  PopupController _controller;

  PopupController get controller => _controller;

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
        widget.childBack,
        if (widget.controller.showPopup)
          Stack(
            alignment: Alignment.center,
            overflow: Overflow.visible,
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: Container(
                  height: double.maxFinite,
                  width: double.maxFinite,
                ),
                onTap: widget.onOutsideTap ??
                    () {
                      widget.controller.hide();
                    },
              ),
              widget.childFront,
            ],
          )
      ],
    );
  }
}

class PopupController {
  PopupController({
    this.showPopup = false,
    this.updateObject,
    this.object,
  }) {
    show = () {
      showPopup = true;
    };
    hide = () {
      showPopup = false;
    };
    toggle = () {
      showPopup = !showPopup;
    };
  }

  bool showPopup;
  Function show;
  Function hide;
  Function toggle;
  Function updateObject;
  Object object;

  void getPopupSetState(Function setState) {
    show = () {
      setState(() {
        showPopup = true;
      });
    };
    hide = () {
      setState(() {
        showPopup = false;
      });
    };
    toggle = () {
      setState(() {
        showPopup = !showPopup;
      });
    };
    updateObject = (Object obj) {
      setState(() {
        object = obj;
      });
    };
  }
}
