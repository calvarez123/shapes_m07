import 'package:editor_base/ShapeDrawing.dart';
import 'package:editor_base/app_click_selector.dart';
import 'package:flutter/material.dart';
import 'app_data_actions.dart';
import 'util_shape.dart';

class AppData with ChangeNotifier {
  // Access appData globaly with:
  // AppData appData = Provider.of<AppData>(context);
  // AppData appData = Provider.of<AppData>(context, listen: false)

  ActionManager actionManager = ActionManager();
  bool isAltOptionKeyPressed = false;
  double zoom = 95;
  Size docSize = const Size(500, 400);
  String toolSelected = "shape_drawing";
  Shape newShape = ShapeDrawing(); // AQUI PONER LA TOOL SELECCIONADA
  List<Shape> shapesList = [];
  bool hide = false;
  Color previousColor = Colors.black;
  Color previousFillColor = Colors.black;
  bool saveAs = false;
  String savedFilepath = "";

  bool isSwitched = false;
  bool hidefillcolor = false;

  double strokeWidth = 5;
  Color color1 = Colors.black;

  Color fillcolor = Colors.black;

  Color backgroundColor = Colors.black.withOpacity(0.0);

  void setBackgroundColor(Color value) {
    backgroundColor = value;
    notifyListeners();
  }

  void setFiledPath(String value) {
    savedFilepath = value;
    notifyListeners();
  }

  void setStrokeWidth(double value) {
    if (selectedShapeIndex >= 0 && selectedShapeIndex < shapesList.length) {
      shapesList[selectedShapeIndex].setStrokeWidth(value);
      actionManager.register(
          ActionWidthShape(this, strokeWidth, value, selectedShapeIndex));
    }
    strokeWidth = value;
    notifyListeners();
  }

  void setClosedSelectShape(bool value) {
    if (selectedShapeIndex >= 0 && selectedShapeIndex < shapesList.length) {
      shapesList[selectedShapeIndex].setclosed(value);
      actionManager.register(
          ActionClosedShape(this, isSwitched, value, selectedShapeIndex));
    }
    isSwitched = value;
    notifyListeners();
  }

  void setSelectedColor(Color value) {
    if (selectedShapeIndex >= 0 && selectedShapeIndex < shapesList.length) {
      shapesList[selectedShapeIndex].setColor(value);
    }
    if (hide == true) {
      actionManager.register(
          ActionColorShape(this, previousColor, value, selectedShapeIndex));
      hide = false;
    }
    color1 = value;
    notifyListeners();
  }

  void setSelectedFillColor(Color value) {
    if (selectedShapeIndex >= 0 && selectedShapeIndex < shapesList.length) {
      shapesList[selectedShapeIndex].setFillColor(value);
    }
    if (hidefillcolor == true) {
      actionManager.register(ActionFillColorShape(
          this, previousFillColor, value, selectedShapeIndex));
      hidefillcolor = false;
    }
    fillcolor = value;
    notifyListeners();
  }

  int selectedShapeIndex = -1;
  int shapeSelectedPrevious = -1;

  Future<void> selectShapeAtPosition(Offset docPosition, Offset localPosition,
      BoxConstraints constraints, Offset center) async {
    shapeSelectedPrevious = selectedShapeIndex;
    selectedShapeIndex = -1;
    selectShape(await AppClickSelector.selectShapeAtPosition(
        this, docPosition, localPosition, constraints, center));
  }

  bool readyExample = false;
  late dynamic dataExample;

  void forceNotifyListeners() {
    super.notifyListeners();
  }

  void setZoom(double value) {
    zoom = value.clamp(25, 500);
    notifyListeners();
  }

  void setZoomNormalized(double value) {
    if (value < 0 || value > 1) {
      throw Exception(
          "AppData setZoomNormalized: value must be between 0 and 1");
    }
    if (value < 0.5) {
      double min = 25;
      zoom = zoom = ((value * (100 - min)) / 0.5) + min;
    } else {
      double normalizedValue = (value - 0.51) / (1 - 0.51);
      zoom = normalizedValue * 400 + 100;
    }
    notifyListeners();
  }

  double getZoomNormalized() {
    if (zoom < 100) {
      double min = 25;
      double normalized = (((zoom - min) * 0.5) / (100 - min));
      return normalized;
    } else {
      double normalizedValue = (zoom - 100) / 400;
      return normalizedValue * (1 - 0.51) + 0.51;
    }
  }

  void setDocWidth(double value) {
    double previousWidth = docSize.width;
    actionManager.register(ActionSetDocWidth(this, previousWidth, value));
  }

  void setDocHeight(double value) {
    double previousHeight = docSize.height;
    actionManager.register(ActionSetDocHeight(this, previousHeight, value));
  }

  void setToolSelected(String name) {
    toolSelected = name;
    notifyListeners();
  }

  String getSelectedTool() {
    return toolSelected;
  }

  void addNewShape(Offset position) {
    newShape =
        ShapeDrawing(); // AQUI PONER LA TOOL SELECCIONADA podriamos hacer aqui la eleccion de shpape
    newShape.setPosition(position);
    newShape.addPoint(Offset(0, 0));
    newShape.setStrokeWidth(strokeWidth);
    newShape.setColor(color1);
    newShape.setclosed(isSwitched);
    notifyListeners();
  }

  void addRelativePointToNewShape(Offset point) {
    newShape.addRelativePoint(point);
    notifyListeners();
  }

  void addNewShapeToShapesList() {
    // Si no hi ha almenys 2 punts, no es podrà dibuixar res
    if (newShape.vertices.length >= 2) {
      double strokeWidthConfig = newShape.stroke;
      actionManager.register(ActionAddNewShape(this, newShape));
      newShape = ShapeDrawing(); // AQUI PONER LA TOOL SELECCIONADA
      newShape.setStrokeWidth(strokeWidthConfig);
    }
  }

  void setNewShapeStrokeWidth(double value) {
    newShape.setStrokeWidth(value);
    notifyListeners();
  }

  void selectShape(int index) {
    selectedShapeIndex = index;
    if (index >= 0 && index < shapesList.length) {
      Shape selectedShape = shapesList[index];
      setStrokeWidth(selectedShape.stroke);
      setSelectedColor(selectedShape.color);
      setSelectedFillColor(selectedShape.fillColor);
      isSwitched = selectedShape.closed;
      previousColor = selectedShape.color;
      previousFillColor = selectedShape.fillColor;
    }
    notifyListeners();
  }

  void setShapePosition(Offset newShapePosition) {
    if (selectedShapeIndex >= 0 && selectedShapeIndex < shapesList.length) {
      shapesList[selectedShapeIndex].setPosition(newShapePosition);
      notifyListeners();
    }
  }

  void updateShapePosition(Offset newShapePosition) {
    if (selectedShapeIndex >= 0 && selectedShapeIndex < shapesList.length) {
      shapesList[selectedShapeIndex].setPosition(newShapePosition);
      notifyListeners();
    }
  }
}
