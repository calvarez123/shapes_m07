import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'app_data.dart';
import 'layout_design_painter.dart';
import 'util_shape.dart';

class AppClickSelector {
  static Future<int> selectShapeAtPosition(AppData appData, Offset docPosition,
      Offset localPosition, BoxConstraints constraints, Offset center) async {
    for (var i = appData.shapesList.length - 1; i >= 0; i--) {
      Shape shape = appData.shapesList[i];
      if (_isPointInsideBoundingBox(docPosition, shape)) {
        if (i == appData.shapeSelectedPrevious) {
          return i;
        }
        if (await _isClickOnShape(
            appData, localPosition, shape, constraints, center)) {
          return i;
        }
      }
    }
    return -1;
  }

  static bool _isPointInsideBoundingBox(Offset point, Shape shape) {
    List<Offset> transformedVertices = _transformVertices(shape);
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (Offset vertex in transformedVertices) {
      minX = math.min(minX, vertex.dx);
      maxX = math.max(maxX, vertex.dx);
      minY = math.min(minY, vertex.dy);
      maxY = math.max(maxY, vertex.dy);
    }

    double strokeHalf = shape.stroke / 2;
    minX -= strokeHalf;
    minY -= strokeHalf;
    maxX += strokeHalf;
    maxY += strokeHalf;

    return point.dx >= minX &&
        point.dx <= maxX &&
        point.dy >= minY &&
        point.dy <= maxY;
  }

  static List<Offset> _transformVertices(Shape shape) {
    return shape.vertices.map((vertex) {
      // Aplica l'escalat i la translació
      return Offset(
        vertex.dx + shape.position.dx,
        vertex.dy + shape.position.dy,
      );
    }).toList();
  }

  static Future<bool> _isClickOnShape(AppData appData, Offset localPosition,
      Shape shape, BoxConstraints constraints, Offset center) async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    ui.Canvas canvas = ui.Canvas(recorder);

    _paintOffscreenCanvas(appData, canvas, constraints.biggest, shape, center);

    ui.Image image = await recorder
        .endRecording()
        .toImage(constraints.maxWidth.toInt(), constraints.maxHeight.toInt());

    if (localPosition.dx < 0 ||
        localPosition.dx >= constraints.maxWidth ||
        localPosition.dy < 0 ||
        localPosition.dy >= constraints.maxHeight) {
      return false;
    }

    ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.rawRgba);

    image.dispose();

    if (byteData != null) {
      int pixelIndex =
          ((localPosition.dy.round() * image.width + localPosition.dx.round()) *
                  4)
              .toInt();
      if (pixelIndex >= 0 && pixelIndex < byteData.lengthInBytes - 4) {
        // int red = byteData.getUint8(pixelIndex);
        // int green = byteData.getUint8(pixelIndex + 1);
        // int blue = byteData.getUint8(pixelIndex + 2);
        int alpha = byteData.getUint8(pixelIndex + 3);

        return alpha != 0;
      }
    }

    return false;
  }

  static void _paintOffscreenCanvas(
      AppData appData, Canvas canvas, Size size, Shape shape, Offset center) {
    // Guarda l'estat previ a l'escalat i translació
    canvas.save();

    // Calcula l'escalat basat en el zoom
    double scale = appData.zoom / 100;
    Size scaledSize = Size(size.width / scale, size.height / scale);
    canvas.scale(scale, scale);

    // Calcula la posició de translació per centrar el punt desitjat
    double translateX =
        (scaledSize.width / 2) - (appData.docSize.width / 2) - center.dx;
    double translateY =
        (scaledSize.height / 2) - (appData.docSize.height / 2) - center.dy;
    canvas.translate(translateX, translateY);

    // Per un si cas és transparent, forçe el color negre
    Color tmpStroke = shape.color;
    shape.color = Colors.black;

    Color tmpFill = shape.fillColor;
    if (tmpFill.alpha != 0) {
      print("entre");
      shape.fillColor = appData.fillcolor;
    }

    // Dibuixa el poligon que s'està afegint
    LayoutDesignPainter.paintShape(canvas, shape);

    shape.color = tmpStroke;
    double tmpStrokeWidth = shape.stroke;
    shape.fillColor = tmpFill;

    // Restaura l'estat previ
    canvas.restore();
  }
}
