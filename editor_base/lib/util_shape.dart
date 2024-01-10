import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

abstract class Shape {
  Offset position = const Offset(0, 0);
  Size scale = const Size(1, 1);
  double rotation = 0;
  List<Offset> vertices = [];

  double stroke = 1;
  Color color = Colors.black;

  bool closed = false;

  Color fillColor = Color(0x00000000);

  Shape();

  void setclosed(bool valor);

  void setColor(Color newColor);

  void setFillColor(Color newColor);

  void setStrokeWidth(double size);

  void setPosition(Offset newPosition);

  void setScale(Size newScale);

  void setRotation(double newRotation);

  void addPoint(Offset point);

  void addRelativePoint(Offset point);

  Map<String, dynamic> toMap();

  static Shape fromMap(Map<String, dynamic> map) {
    // TODO: implement fromMap
    throw UnimplementedError();
  }
}
