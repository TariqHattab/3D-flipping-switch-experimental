import 'dart:math';

import 'package:flutter/material.dart';

class FlippingSwitch extends StatefulWidget {
  const FlippingSwitch({
    Key key,
    this.color,
    this.background,
    this.leftLabel,
    this.rightLabel,
  }) : super(key: key);

  final Color color;
  final Color background;
  final String leftLabel;
  final String rightLabel;

  @override
  _FlippingSwitchState createState() => _FlippingSwitchState();
}

class _FlippingSwitchState extends State<FlippingSwitch>
    with TickerProviderStateMixin {
  double _directionalMultiplayer = 1;
  double _maxTiltAngle = pi / 6;
  Animation _tiltAnimation;
  AnimationController _flipController;
  AnimationController _tiltController;

  @override
  void initState() {
    super.initState();

    _tiltController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      reverseDuration: Duration(milliseconds: 1500),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _tiltController.reverse();
        }
      });

    _tiltAnimation = CurvedAnimation(
      parent: _tiltController,
      curve: Curves.easeOut,
      reverseCurve: Curves.elasticOut.flipped,
    );

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    forceSide(true);
  }

  void forceSide(bool leftEnabled) {
    leftEnabled ? _flipController.value = 1 : _flipController.value = 0;
  }

  void switchSides() {
    if (_flipController.isCompleted) {
      _flipController.reverse();

      _directionalMultiplayer = -1;
      _tiltController.forward();
    } else {
      _flipController.forward();

      _directionalMultiplayer = 1;
      _tiltController.forward();
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _tiltController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _tiltAnimation,
      builder: (ctx, taps) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, .001)
            ..rotateY(
                _maxTiltAngle * _tiltAnimation.value * _directionalMultiplayer),
          alignment: FractionalOffset(.5, 1),
          child: taps,
        );
      },
      child: GestureDetector(
        onTap: switchSides,
        child: Stack(
          children: [
            buildBackgroundSwitch(),
            AnimatedBuilder(
              animation: _flipController,
              builder: (ctx, ch) {
                return buildActiveSwitch(pi * _flipController.value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBackgroundSwitch() {
    return Container(
        width: 220,
        height: 64,
        decoration: BoxDecoration(
          color: widget.background,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: widget.color, width: 3),
        ),
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  widget.leftLabel,
                  style: TextStyle(
                    color: widget.color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  widget.rightLabel,
                  style: TextStyle(
                    color: widget.color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ));
  }

  Widget buildActiveSwitch(double angle) {
    bool isLeft = angle > (pi / 2);
    double transformedAngle = isLeft ? angle - pi : angle;

    return Positioned(
      top: 0,
      bottom: 0,
      right: isLeft ? null : 0,
      left: isLeft ? 0 : null,
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, .002)
          ..rotateY(transformedAngle),
        alignment: isLeft ? FractionalOffset(1, 1) : FractionalOffset(0, 1),
        child: Container(
          width: 110,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.only(
              topRight: isLeft ? Radius.zero : Radius.circular(32),
              bottomRight: isLeft ? Radius.zero : Radius.circular(32),
              topLeft: isLeft ? Radius.circular(32) : Radius.zero,
              bottomLeft: isLeft ? Radius.circular(32) : Radius.zero,
            ),
            border: Border.all(color: widget.color, width: 3),
          ),
          child: Center(
            child: Text(
              isLeft ? widget.leftLabel : widget.rightLabel,
              style: TextStyle(
                color: widget.background,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
