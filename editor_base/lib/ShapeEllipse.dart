import 'dart:ui';

import 'package:editor_base/util_shape.dart';
import 'package:xml/src/xml/nodes/element.dart';
import 'package:xml/xml.dart' as xml;

class ShapeEllipse extends Shape {
  ShapeEllipse() : super();

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
      'type': 'shape_ellipse',
      'object': {
        'position': {'dx': position.dx, 'dy': position.dy},
        'vertices': vertices.map((v) => {'dx': v.dx, 'dy': v.dy}).toList(),
        'strokeWidth': stroke,
        'strokeColor': color.value,
        'fillColor': fillColor.value,
      }
    };
  }

  Shape fromMap(Map<String, dynamic> map) {
    if (map['type'] != 'shape_ellipse') {
      throw Exception('Type is not a shape_ellipse');
    }

    var objectMap = map['object'] as Map<String, dynamic>;
    var shape = ShapeEllipse()
      ..setPosition(
          Offset(objectMap['position']['dx'], objectMap['position']['dy']))
      ..setStrokeWidth(objectMap['strokeWidth'])
      ..setColor(Color(objectMap['strokeColor']))
      ..setFillColor(Color(objectMap['fillColor']));

    if (objectMap['vertices'] != null) {
      var verticesList = objectMap['vertices'] as List;
      shape.vertices =
          verticesList.map((v) => Offset(v['dx'], v['dy'])).toList();
    }

    return shape;
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

  @override
  xml.XmlElement mapShapeSVG() {
    Rect rect = Rect.fromPoints(vertices[0], vertices[1]);
    Offset temporalPosition;

    double width = rect.right - rect.left;
    double height = rect.bottom - rect.top;

    temporalPosition = getRectanglePositionSVG(vertices, width, height);

    double fillOpacity = fillColor.alpha / 255.0;
    double strokeOpacity = color.alpha / 255.0;

    var elipElement = xml.XmlElement(xml.XmlName('ellipse'), [
      xml.XmlAttribute(xml.XmlName('rx'), (rect.width / 2).toString()),
      xml.XmlAttribute(xml.XmlName('ry'), (rect.height / 2).toString()),
      xml.XmlAttribute(
          xml.XmlName('cy'), (temporalPosition.dy + height / 2).toString()),
      xml.XmlAttribute(
          xml.XmlName('cx'), (temporalPosition.dx + width / 2).toString()),
      xml.XmlAttribute(xml.XmlName('stroke'),
          'rgb(${color.red},${color.green},${color.blue})'),
      xml.XmlAttribute(xml.XmlName('stroke-opacity'), '$strokeOpacity'),
      xml.XmlAttribute(xml.XmlName('stroke-width'), stroke.toString()),
      xml.XmlAttribute(xml.XmlName('fill'),
          'rgb(${fillColor.red},${fillColor.green},${fillColor.blue})'),
      xml.XmlAttribute(xml.XmlName('fill-opacity'), '$fillOpacity'),
      xml.XmlAttribute(xml.XmlName('opacity'), "1.0")
    ]);

    return elipElement;
  }
}
