import 'package:editor_base/ShapeDrawing.dart';
import 'package:editor_base/ShapeEllipse.dart';
import 'package:editor_base/ShapeLine.dart';
import 'package:editor_base/ShapeMultiline.dart';
import 'package:editor_base/ShapeRectangle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;

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

  Map<String, dynamic> toMap() {
    return {
      'position': {'x': position.dx, 'y': position.dy},
      'scale': {'width': scale.width, 'height': scale.height},
      'rotation': rotation,
      'vertices':
          vertices.map((offset) => {'x': offset.dx, 'y': offset.dy}).toList(),
      'stroke': stroke,
      'color': color.value,
      'closed': closed,
      'fillColor': fillColor.value,
    };
  }

  static Shape fromMap(Map<String, dynamic> map) {
    Shape shape;
    switch (map['type']) {
      case 'shape_drawing':
        shape = ShapeDrawing();
        break;
      case 'shape_line':
        shape = ShapeLine();
        break;
      case 'shape_multiline':
        shape = ShapeMultiline();
        break;
      case 'shape_rectangle':
        shape = ShapeRectangle();
        break;
      case 'shape_ellipse':
        shape = ShapeEllipse();
        break;
      default:
        throw Exception('Type is not a known shape type');
    }

    var objectMap = map['object'] as Map<String, dynamic>;
    shape
      ..setPosition(Offset(objectMap['position']['dx'].toDouble(),
          objectMap['position']['dy'].toDouble()))
      ..setStrokeWidth(objectMap['strokeWidth'].toDouble())
      ..setColor(Color(objectMap['strokeColor']));

    if (objectMap['vertices'] != null) {
      var verticesList = objectMap['vertices'] as List<dynamic>;
      if (verticesList.isNotEmpty) {
        shape.vertices = verticesList.map((v) {
          if (v is Map<String, dynamic> && v['dx'] != null && v['dy'] != null) {
            return Offset(v['dx'].toDouble(), v['dy'].toDouble());
          }
          return Offset.zero; // Or any default value you prefer
        }).toList();
      }
    }

    return shape;
  }

  xml.XmlElement mapShapeSVG();
}
