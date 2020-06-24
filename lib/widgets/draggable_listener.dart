import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class DraggableListener extends StatefulWidget {
  final Widget child;
  final Alignment alignment;
  final bool dragHorizontal;
  final bool dragVertical;
  final double triggeredDistance = 15.0;
  Function onDragEnd;

  DraggableListener({
    this.child,
    this.alignment = Alignment.center,
    this.dragHorizontal = true,
    this.dragVertical = true,
    this.onDragEnd,
  }) : super();

  @override
  _DraggableListenerState createState() => _DraggableListenerState();
}

class _DraggableListenerState extends State<DraggableListener> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  bool _hasBeenTriggered = false;

  /// The alignment of the card as it is dragged or being animated.
  ///
  /// While the card is being dragged, this value is set to the values computed
  /// in the GestureDetector onPanUpdate callback. If the animation is running,
  /// this value is set to the value of the [_animation].
  Alignment _dragAlignment;

  Animation<Alignment> _animation;

  /// Calculates and runs a [SpringSimulation].
  void _runAnimation(Offset pixelsPerSecond, Size size) {
    _animation = _controller.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: widget.alignment,
      ),
    );
    // Calculate the velocity relative to the unit interval, [0,1],
    // used by the animation controller.
    final unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(
      widget.dragHorizontal ? unitsPerSecondX : 0.0,
      widget.dragVertical ? unitsPerSecondY : 0.0,
    );
    final unitVelocity = unitsPerSecond.distance;

    const spring = SpringDescription(
      mass: 30,
      stiffness: 1,
      damping: 1,
    );

    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

    _controller.animateWith(simulation);
  }

  @override
  void initState() {
    super.initState();
    _dragAlignment = widget.alignment;
    _controller = AnimationController(vsync: this);

    _controller.addListener(() {
      setState(() {
        _dragAlignment = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onPanDown: (details) {
        _controller.stop();
      },
      onPanUpdate: (details) {
        setState(() {
          _dragAlignment += Alignment(
            widget.dragHorizontal ? details.delta.dx / (size.width / 2) : 0.0,
            widget.dragVertical ? details.delta.dy / (size.height / 2) : 0.0,
          );
          if (details.delta.distance > widget.triggeredDistance) {
            _hasBeenTriggered = true;
          }
        });
      },
      onPanEnd: (details) {
        if (widget.onDragEnd != null && _hasBeenTriggered) {
          widget.onDragEnd();
          setState(() {
            _hasBeenTriggered = false;
          });
        }
        _runAnimation(details.velocity.pixelsPerSecond, size);
      },
      child: Align(
        alignment: _dragAlignment,
        child: widget.child,
      ),
    );
  }
}

class Dg extends StatefulWidget {
  final Widget child;

  Dg({
    this.child,
  }) : super();

  @override
  _DgState createState() => _DgState();
}

class _DgState extends State<Dg> {
  @override
  Widget build(BuildContext context) {
    return Draggable(
      onDragCompleted: () {
        print('dragged');
      },
      onDragStarted: () {
        print('dragg started');
      },
      child: widget.child,
      feedback: Container(
        child: Text('feedback', style: TextStyle(color: Colors.white)),
      ),
      childWhenDragging: Text('ChildWhenDragging', style: TextStyle(color: Colors.white),),
    );
  }
}
