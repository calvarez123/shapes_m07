import 'dart:async';
import 'dart:math';

import 'package:editor_base/ShapeLine.dart';
import 'package:editor_base/ShapeRectangle.dart';
import 'package:editor_base/app_data_actions.dart';
import 'package:editor_base/util_shape.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';
import 'layout_design_painter.dart';
import 'util_custom_scroll_vertical.dart';
import 'util_custom_scroll_horizontal.dart';

class LayoutDesign extends StatefulWidget {
  const LayoutDesign({super.key});

  @override
  LayoutDesignState createState() => LayoutDesignState();
}

class LayoutDesignState extends State<LayoutDesign> {
  final GlobalKey<UtilCustomScrollHorizontalState> _keyScrollX = GlobalKey();
  final GlobalKey<UtilCustomScrollVerticalState> _keyScrollY = GlobalKey();
  Offset _scrollCenter = const Offset(0, 0);
  bool _isMouseButtonPressed = false;
  final FocusNode _focusNode = FocusNode();
  Offset _dragStartPosition = Offset.zero;
  Offset _dragStartOffset = Offset.zero;
  Offset _startpoint = Offset.zero;

  bool paintingLine = false;
  int clickCount = 0;
  Timer? _doubleTapTimer;
  bool paintingEllipse = false;
  Offset _ellipseStartPoint = Offset.zero;
  bool _isDrawingEllipse = false;
  @override
  void initState() {
    super.initState();
    initShaders();
  }

  Future<void> initShaders() async {
    await LayoutDesignPainter.initShaders();
    setState(() {});
  }

  // Retorna l'area de scroll del document
  Size _getScrollArea(AppData appData) {
    return Size(((appData.docSize.width * appData.zoom) / 100) + 50,
        ((appData.docSize.height * appData.zoom) / 100) + 50);
    // Force 50 pixels padding (to show 25 pixels rulers)
  }

  // Retorna el desplacament del document respecte el centre de la pantalla
  Offset _getDisplacement(Size scrollArea, BoxConstraints constraints) {
    return Offset(((scrollArea.width - constraints.maxWidth) / 2),
        ((scrollArea.height - constraints.maxHeight) / 2));
  }

  // Retorna la posiciÃ³ x,y al document, respecte on s'ha fet click
  Offset _getDocPosition(
      Offset position,
      double zoom,
      double sizeWidth,
      double sizeHeight,
      double docSizeWidth,
      double docSizeHeight,
      double centerX,
      double centerY) {
    double scale = zoom / 100;
    double translateX =
        (sizeWidth / (2 * scale)) - (docSizeWidth / 2) - centerX;
    double translateY =
        (sizeHeight / (2 * scale)) - (docSizeHeight / 2) - centerY;
    double originalX = (position.dx / scale) - translateX;
    double originalY = (position.dy / scale) - translateY;

    return Offset(originalX, originalY);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      AppData appData = Provider.of<AppData>(context);
      CDKTheme theme = CDKThemeNotifier.of(context)!.changeNotifier;

      Size scrollArea = _getScrollArea(appData);
      Offset scrollDisplacement = _getDisplacement(scrollArea, constraints);

      double tmpScrollX = _scrollCenter.dx;
      double tmpScrollY = _scrollCenter.dy;
      if (_keyScrollX.currentState != null) {
        if (scrollArea.width < constraints.maxWidth) {
          _keyScrollX.currentState!.setOffset(0);
        } else {
          tmpScrollX = _keyScrollX.currentState!.getOffset() *
              (scrollDisplacement.dx * 100 / appData.zoom);
        }
      }

      if (_keyScrollY.currentState != null) {
        if (scrollArea.height < constraints.maxHeight) {
          _keyScrollY.currentState!.setOffset(0);
        } else {
          tmpScrollY = _keyScrollY.currentState!.getOffset() *
              (scrollDisplacement.dy * 100 / appData.zoom);
        }
      }

      _scrollCenter = Offset(tmpScrollX, tmpScrollY);

      return Stack(
        children: [
          GestureDetector(
            onPanEnd: (details) {
              _keyScrollX.currentState!.startInertiaAnimation();
              _keyScrollY.currentState!.startInertiaAnimation();
            },
            onPanUpdate: (DragUpdateDetails details) {
              if (!_isMouseButtonPressed) {
                if (appData.isAltOptionKeyPressed) {
                  appData.setZoom(appData.zoom + details.delta.dy);
                } else {
                  if (details.delta.dx != 0) {
                    _keyScrollX.currentState!
                        .setTrackpadDelta(details.delta.dx);
                  }
                  if (details.delta.dy != 0) {
                    _keyScrollY.currentState!
                        .setTrackpadDelta(details.delta.dy);
                  }
                }
              }
            },
            child: MouseRegion(
              cursor: _getCursorForTool(
                  appData.toolSelected, _isMouseButtonPressed),
              child: Listener(
                /*------------------------------------------------CLICK RATON------------------------------*/
                onPointerDown: (event) async {
                  _focusNode.requestFocus();
                  _isMouseButtonPressed = true;

                  Offset docPosition = _getDocPosition(
                    event.localPosition,
                    appData.zoom,
                    constraints.maxWidth,
                    constraints.maxHeight,
                    appData.docSize.width,
                    appData.docSize.height,
                    _scrollCenter.dx,
                    _scrollCenter.dy,
                  );
                  /*----------------------------DRAWING------------------------------*/
                  if (appData.toolSelected == "shape_drawing") {
                    Size docSize =
                        Size(appData.docSize.width, appData.docSize.height);
                    appData.addNewShape(_getDocPosition(
                        event.localPosition,
                        appData.zoom,
                        constraints.maxWidth,
                        constraints.maxHeight,
                        docSize.width,
                        docSize.height,
                        _scrollCenter.dx,
                        _scrollCenter.dy));
                    /*----------------------------lINEA------------------------------*/
                  } else if (appData.toolSelected == "shape_line") {
                    _startpoint = _getDocPosition(
                      event.localPosition,
                      appData.zoom,
                      constraints.maxWidth,
                      constraints.maxHeight,
                      appData.docSize.width,
                      appData.docSize.height,
                      _scrollCenter.dx,
                      _scrollCenter.dy,
                    );

                    // Inicializa la lista de puntos

                    paintingLine = true;
                    setState(() {});
                    /*----------------------------MULTIlINEA------------------------------*/
                  } else if (appData.toolSelected == "shape_multiline") {
                    if (paintingLine) {
                      // Agregar el punto actual a la lista de vértices
                      Offset currentPoint = _getDocPosition(
                        event.localPosition,
                        appData.zoom,
                        constraints.maxWidth,
                        constraints.maxHeight,
                        appData.docSize.width,
                        appData.docSize.height,
                        _scrollCenter.dx,
                        _scrollCenter.dy,
                      );
                      appData.newShape.vertices.add(currentPoint);
                    } else {
                      // Comenzar el dibujo de líneas múltiples
                      paintingLine = true;
                      appData.newShape.vertices
                          .clear(); // Limpiar la lista de vértices
                      // Agregar el primer punto a la lista de vértices
                      Offset startPoint = _getDocPosition(
                        event.localPosition,
                        appData.zoom,
                        constraints.maxWidth,
                        constraints.maxHeight,
                        appData.docSize.width,
                        appData.docSize.height,
                        _scrollCenter.dx,
                        _scrollCenter.dy,
                      );
                      appData.newShape.vertices.add(startPoint);
                    }
                    setState(() {});
                    /*----------------------------rectangle------------------------------*/
                  }
                  if (appData.toolSelected == "shape_rectangle") {
                    // Set the starting point for the rectangle
                    _startpoint = _getDocPosition(
                      event.localPosition,
                      appData.zoom,
                      constraints.maxWidth,
                      constraints.maxHeight,
                      appData.docSize.width,
                      appData.docSize.height,
                      _scrollCenter.dx,
                      _scrollCenter.dy,
                    );
                    paintingEllipse = true;
                    // Initialize the rectangle shape

                    setState(() {});
                  } else if (appData.toolSelected == "shape_ellipsis") {
                    _ellipseStartPoint = _getDocPosition(
                      event.localPosition,
                      appData.zoom,
                      constraints.maxWidth,
                      constraints.maxHeight,
                      appData.docSize.width,
                      appData.docSize.height,
                      _scrollCenter.dx,
                      _scrollCenter.dy,
                    );

                    // Set the starting point for the ellipse drawing
                    _isDrawingEllipse = true;
                    appData.newShape.setclosed(true);
                  } else if (appData.toolSelected == "pointer_shapes") {
                    await appData.selectShapeAtPosition(docPosition,
                        event.localPosition, constraints, _scrollCenter);

                    if (appData.selectedShapeIndex != -1) {
                      _dragStartPosition = appData
                          .shapesList[appData.selectedShapeIndex].position;
                      _dragStartOffset = docPosition - _dragStartPosition;
                    }
                  }
                  /*

                  */
                  setState(() {});
                },
                /*---------------------------------------MOVIMIENTO RATON------------------------------*/
                onPointerMove: (event) {
                  Offset docPosition = _getDocPosition(
                    event.localPosition,
                    appData.zoom,
                    constraints.maxWidth,
                    constraints.maxHeight,
                    appData.docSize.width,
                    appData.docSize.height,
                    _scrollCenter.dx,
                    _scrollCenter.dy,
                  );
                  if (_isMouseButtonPressed) {
                    /*----------------------------DRAWING------------------------------*/
                    if (appData.toolSelected == "shape_drawing") {
                      Size docSize =
                          Size(appData.docSize.width, appData.docSize.height);
                      appData.addRelativePointToNewShape(_getDocPosition(
                          event.localPosition,
                          appData.zoom,
                          constraints.maxWidth,
                          constraints.maxHeight,
                          docSize.width,
                          docSize.height,
                          _scrollCenter.dx,
                          _scrollCenter.dy));
                      /*----------------------------lINEA------------------------------*/
                    } else if (appData.toolSelected == "shape_line" &&
                        paintingLine == true) {
                      Offset currentPoint = _getDocPosition(
                        event.localPosition,
                        appData.zoom,
                        constraints.maxWidth,
                        constraints.maxHeight,
                        appData.docSize.width,
                        appData.docSize.height,
                        _scrollCenter.dx,
                        _scrollCenter.dy,
                      );

                      appData.newShape.vertices = [_startpoint, currentPoint];

                      appData.notifyListeners();
                      /*----------------------------MULTIlINEA------------------------------*/
                    } else if (appData.toolSelected == "shape_multiline" &&
                        paintingLine == true) {
                      Offset currentPoint = _getDocPosition(
                        event.localPosition,
                        appData.zoom,
                        constraints.maxWidth,
                        constraints.maxHeight,
                        appData.docSize.width,
                        appData.docSize.height,
                        _scrollCenter.dx,
                        _scrollCenter.dy,
                      );

                      appData.newShape.vertices.add(currentPoint);

                      appData.notifyListeners();
                      /*----------------------------rectangle------------------------------*/
                    } else if (paintingEllipse &&
                        appData.toolSelected == "shape_rectangle") {
                      // Get the current position in the document
                      Offset docPosition = _getDocPosition(
                        event.localPosition,
                        appData.zoom,
                        constraints.maxWidth,
                        constraints.maxHeight,
                        appData.docSize.width,
                        appData.docSize.height,
                        _scrollCenter.dx,
                        _scrollCenter.dy,
                      );

                      // Update the rectangle shape based on the current position
                      appData.newShape.vertices = [
                        _startpoint,
                        Offset(docPosition.dx, _startpoint.dy),
                        docPosition,
                        Offset(_startpoint.dx, docPosition.dy),
                        _startpoint,
                      ];

                      appData.notifyListeners();
                    } else if (_isDrawingEllipse &&
                        appData.toolSelected == "shape_ellipsis") {
                      Offset currentPoint = _getDocPosition(
                        event.localPosition,
                        appData.zoom,
                        constraints.maxWidth,
                        constraints.maxHeight,
                        appData.docSize.width,
                        appData.docSize.height,
                        _scrollCenter.dx,
                        _scrollCenter.dy,
                      );

                      double distance = sqrt(
                          pow(currentPoint.dx - _ellipseStartPoint.dx, 2) +
                              pow(currentPoint.dy - _ellipseStartPoint.dy, 2));

                      double sensitivity = 0.02;
                      double adjustedDistance = distance * sensitivity;

                      appData.newShape.vertices = _calculateEllipseVertices(
                        _ellipseStartPoint,
                        adjustedDistance,
                        appData.zoom,
                      );

                      appData.notifyListeners();
                    } else if (appData.toolSelected == "pointer_shapes" &&
                        appData.selectedShapeIndex != -1) {
                      Offset newShapePosition = docPosition - _dragStartOffset;
                      appData.updateShapePosition(newShapePosition);
                    }
                  }
                  if (_isMouseButtonPressed &&
                      appData.toolSelected == "view_grab") {
                    if (event.delta.dx != 0) {
                      _keyScrollX.currentState!
                          .setTrackpadDelta(event.delta.dx);
                    }
                    if (event.delta.dy != 0) {
                      _keyScrollY.currentState!
                          .setTrackpadDelta(event.delta.dy);
                    }
                  }
                },
                /*----------------------------DEJAR DE HACER CLICK AL RATON------------------------------*/
                onPointerUp: (event) {
                  _isMouseButtonPressed = false;

                  if (appData.toolSelected == "shape_drawing") {
                    appData.addNewShapeToShapesList();
                  } else if (appData.toolSelected == "shape_line" &&
                      paintingLine == true) {
                    Size docSize =
                        Size(appData.docSize.width, appData.docSize.height);
                    appData.addRelativePointToNewShape(_getDocPosition(
                        event.localPosition,
                        appData.zoom,
                        constraints.maxWidth,
                        constraints.maxHeight,
                        docSize.width,
                        docSize.height,
                        _scrollCenter.dx,
                        _scrollCenter.dy));
                    appData.addNewShapeToShapesList();
                    paintingLine = false;
                  } else if (appData.toolSelected == "shape_multiline" &&
                      paintingLine == true) {
                    if (_doubleTapTimer != null && _doubleTapTimer!.isActive) {
                      _doubleTapTimer!.cancel();
                      appData.addNewShapeToShapesList();
                      paintingLine = false; // Cambiar la variable a falso
                      clickCount = 0;
                    } else {
                      _doubleTapTimer = Timer(Duration(milliseconds: 300), () {
                        clickCount = 0;
                      });
                    }
                  } else if (paintingEllipse &&
                      appData.toolSelected == "shape_rectangle") {
                    // Finish drawing the rectangle
                    paintingEllipse = false;

                    // Optionally, add the rectangle shape to the shapes list
                    if (appData.newShape.vertices.length >= 4) {
                      appData.addNewShapeToShapesList();
                    }

                    setState(() {});
                  }
                  if (_isDrawingEllipse &&
                      appData.toolSelected == "shape_ellipsis") {
                    // Finish drawing the ellipse
                    _isDrawingEllipse = false;

                    // Optionally, add the ellipse shape to the shapes list
                    if (appData.newShape.vertices.length >= 4) {
                      appData.addNewShapeToShapesList();
                    }

                    setState(() {});
                  } else if (appData.toolSelected == "pointer_shapes" &&
                      appData.selectedShapeIndex != -1) {
                    Size docSize =
                        Size(appData.docSize.width, appData.docSize.height);
                    Offset docPosition = _getDocPosition(
                        event.localPosition,
                        appData.zoom,
                        constraints.maxWidth,
                        constraints.maxHeight,
                        docSize.width,
                        docSize.height,
                        _scrollCenter.dx,
                        _scrollCenter.dy);
                    Offset newShapePosition = docPosition - _dragStartOffset;

                    if (_dragStartPosition != newShapePosition) {
                      appData.setShapePosition(newShapePosition);
                    }
                    ActionMoveShape action = ActionMoveShape(
                      appData,
                      appData.selectedShapeIndex,
                      _dragStartPosition,
                      newShapePosition,
                    );
                    appData.actionManager.register(action);
                  }

                  // Finish drawing multiline when right mouse button is clicked
                  if (appData.toolSelected == "shape_multiline" &&
                      event.buttons == 2) {
                    appData.addNewShapeToShapesList();
                    paintingLine = false;
                  }

                  setState(() {});
                },
                onPointerSignal: (pointerSignal) {
                  if (pointerSignal is PointerScrollEvent) {
                    if (!_isMouseButtonPressed) {
                      if (appData.isAltOptionKeyPressed) {
                        appData.setZoom(
                            appData.zoom + pointerSignal.scrollDelta.dy);
                      } else {
                        _keyScrollX.currentState!
                            .setWheelDelta(pointerSignal.scrollDelta.dx);
                        _keyScrollY.currentState!
                            .setWheelDelta(pointerSignal.scrollDelta.dy);
                      }
                    }
                  }
                },
                child: CustomPaint(
                  painter: LayoutDesignPainter(
                    appData: appData,
                    theme: theme,
                    centerX: _scrollCenter.dx,
                    centerY: _scrollCenter.dy,
                  ),
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                ),
              ),
            ),
          ),
          UtilCustomScrollHorizontal(
            key: _keyScrollX,
            size: constraints.maxWidth,
            contentSize: scrollArea.width,
            onChanged: (value) {
              setState(() {});
            },
          ),
          UtilCustomScrollVertical(
            key: _keyScrollY,
            size: constraints.maxHeight,
            contentSize: scrollArea.height,
            onChanged: (value) {
              setState(() {});
            },
          ),
        ],
      );
    });
  }

  SystemMouseCursor _getCursorForTool(
      String toolSelected, bool isMouseButtonPressed) {
    switch (toolSelected) {
      case "pointer_shapes":
        return SystemMouseCursors.basic;
      case "shape_drawing":
        return SystemMouseCursors.precise;
      case "view_grab":
        return isMouseButtonPressed
            ? SystemMouseCursors.grabbing
            : SystemMouseCursors.grab;
      case "shape_line":
        return SystemMouseCursors.precise; // Cambiado a precise
      case "shape_multiline":
        return SystemMouseCursors.precise; // Cambiado a precise
      case "shape_rectangle":
        return SystemMouseCursors.precise; // Cambiado a precise
      case "shape_ellipsis":
        return SystemMouseCursors.precise; // Cambiado a precise
      default:
        return SystemMouseCursors.click; // Cursor predeterminado
    }
  }

  List<Offset> _calculateEllipseVertices(
    Offset center,
    double radius,
    double zoom,
  ) {
    List<Offset> vertices = [];

    int segments = 36;

    for (int i = 0; i < segments; i++) {
      double angle = (2 * 3.14159265358979323846 * i) / segments;
      double x = center.dx + radius * zoom * cos(angle);
      double y = center.dy + radius * zoom * sin(angle);
      vertices.add(Offset(x, y));
    }

    return vertices;
  }
}
