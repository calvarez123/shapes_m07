import 'dart:ui';

import 'package:editor_base/util_shape.dart';

class ShapeDrawing extends Shape {
  ShapeDrawing() : super();

  @override
  void setclosed(bool valor) {
    closed = valor;
  }

  @override
  void setColor(Color newColor) {
    color = newColor;
  }

  @override
  void setFillColor(Color newColor) {
    fillColor = newColor;
  }

  @override
  void setStrokeWidth(double size) {
    stroke = size;
  }

  @override
  void setPosition(Offset newPosition) {
    position = newPosition;
  }

  @override
  void setScale(Size newScale) {
    scale = newScale;
  }

  @override
  void setRotation(double newRotation) {
    rotation = newRotation;
  }

  @override
  void addPoint(Offset point) {
    vertices.add(Offset(point.dx, point.dy));
  }

  @override
  void addRelativePoint(Offset point) {
    vertices.add(Offset(point.dx - position.dx, point.dy - position.dy));
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'shape_drawing',
      'object': {
        'position': {'dx': position.dx, 'dy': position.dy},
        'vertices': vertices.map((v) => {'dx': v.dx, 'dy': v.dy}).toList(),
        'strokeWidth': stroke,
        'strokeColor': color.value,
      }
    };
  }

  Shape fromMap(Map<String, dynamic> map) {
    if (map['type'] != 'shape_drawing') {
      throw Exception('Type is not a shape_drawing');
    }

    var objectMap = map['object'] as Map<String, dynamic>;
    var shape = ShapeDrawing()
      ..setPosition(
          Offset(objectMap['position']['dx'], objectMap['position']['dy']))
      ..setStrokeWidth(objectMap['strokeWidth'])
      ..setColor(Color(objectMap['strokeColor']));

    if (objectMap['vertices'] != null) {
      var verticesList = objectMap['vertices'] as List;
      shape.vertices =
          verticesList.map((v) => Offset(v['dx'], v['dy'])).toList();
    }

    return shape;
  }
}
