import 'package:flutter/cupertino.dart';

class Shape {
  Offset position = const Offset(0, 0);
  Size scale = const Size(1, 1);
  double rotation = 0;
  List<Offset> points = [];

  Shape();

  void setPosition(Offset newPosition) {
    position = newPosition;
  }

  void setScale(Size newScale) {
    scale = newScale;
  }

  void setRotation(double newRotation) {
    rotation = newRotation;
  }

  void addPoint(Offset point) {
    points.add(Offset(point.dx, point.dy));
  }

  void addRelativePoint(Offset point) {
    points.add(Offset(point.dx - position.dx, point.dy - position.dy));
  }
}
