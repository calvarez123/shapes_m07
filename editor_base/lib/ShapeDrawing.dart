import 'dart:ui';

import 'package:editor_base/util_shape.dart';
import 'package:xml/xml.dart' as xml;

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

  xml.XmlElement mapShapeSVG() {
    double strokeOpacity = color.alpha / 255.0;
    String path = "";

    Offset absoluteCurrentPosition;
    Rect rect = Rect.fromPoints(vertices[0], vertices[1]);
    double width = rect.right - rect.left;
    double height = rect.bottom - rect.top;

    absoluteCurrentPosition = getRectanglePositionSVG(vertices, width, height);

    for (int i = 0; i < vertices.length; i++) {
      if (i == 0) {
        path += "M${absoluteCurrentPosition.dx} ${absoluteCurrentPosition.dy}";
      } else if (vertices[i] == vertices.last && closed) {
        double diffX = vertices[i].dx - vertices[i - 1].dx;
        double diffY = vertices[i].dy - vertices[i - 1].dy;

        absoluteCurrentPosition = Offset(absoluteCurrentPosition.dx + diffX,
            absoluteCurrentPosition.dy + diffY);

        path +=
            " L${absoluteCurrentPosition.dx} ${absoluteCurrentPosition.dy} Z";
      } else {
        double diffX = vertices[i].dx - vertices[i - 1].dx;
        double diffY = vertices[i].dy - vertices[i - 1].dy;

        absoluteCurrentPosition = Offset(absoluteCurrentPosition.dx + diffX,
            absoluteCurrentPosition.dy + diffY);

        path += " L${absoluteCurrentPosition.dx} ${absoluteCurrentPosition.dy}";
      }
    }

    var attributes = [
      xml.XmlAttribute(xml.XmlName('d'), path),
      xml.XmlAttribute(xml.XmlName('stroke'),
          'rgb(${color.red},${color.green},${color.blue})'),
      xml.XmlAttribute(xml.XmlName('stroke-opacity'), '$strokeOpacity'),
      xml.XmlAttribute(xml.XmlName('stroke-width'), stroke.toString()),
      xml.XmlAttribute(xml.XmlName('opacity'), "1.0"),
      xml.XmlAttribute(xml.XmlName('fill'),
          'rgb(${fillColor.red},${fillColor.green},${fillColor.blue})')
    ];

    if (closed) {
      double fillOpacity = fillColor.alpha / 255.0;
      attributes
          .add(xml.XmlAttribute(xml.XmlName('fill-opacity'), '$fillOpacity'));
    } else {
      attributes.add(xml.XmlAttribute(xml.XmlName('fill-opacity'), '0.0'));
    }

    var pathElement = xml.XmlElement(xml.XmlName('path'), attributes);

    return pathElement;
  }

  Offset getRectanglePositionSVG(
      List<Offset> vertexs, double width, double height) {
    Offset temporalPosition;

    if (vertices[0].dx > vertices[1].dx) {
      if (vertices[0].dy < vertices[1].dy) {
        temporalPosition = Offset(position.dx - width, position.dy);
      } else {
        temporalPosition = Offset(position.dx - width, position.dy - height);
      }
    } else {
      if (vertices[0].dy > vertices[1].dy) {
        temporalPosition = Offset(position.dx, position.dy - height);
      } else {
        temporalPosition = position;
      }
    }

    return temporalPosition;
  }
}
